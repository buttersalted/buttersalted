'use strict';
const express = require('express');
const usdaNdb = require('usda-ndb');
const body = (req) => Object.assign(req.body, req.query, req.params);

const convert = function(a) {
  // 1. get object key (id, name)
  const k = Object.keys(a)[0];
  if(!k) return a;
  // 2. convert object to row format
  const Id = parseInt(k.substring(0, k.indexOf(',')));
  const Name = k.substring(k.indexOf(',')+1).trim();
  return Object.assign({Id, Name}, a[k]);
};

module.exports = function(dst) {
  const x = express();
  // 1. setup get from usda-ndb
  const get = (req, res, next) => usdaNdb(body(req).id).then((ans) => {
    res.json(convert(ans));
  }, next);
  x.get('/', get);
  x.get('/:id', get);
  // 2. setup insert using usda-ndb
  const post = (req, res, next) => usdaNdb(body(req).id).then((ans) => {
    if(!Object.keys(ans).length) return next(new Error('not available'));
    dst.insertOne(convert(ans)).then((ans) => res.json(ans), next);
  }, next);
  x.post('/', post);
  x.post('/:id', post);
  return x;
};
