'use strict';
const express = require('express');
const usdaNdb = require('usda-ndb');
const body = (req) => Object.assign(req.body, req.query, req.params);

const convert = function(a) {
  // 1. convert object to row format
  const k = Object.keys(a)[0], v = a[k];
  v['Id'] = parseInt(k.substring(0, k.indexOf(',')));
  v['Name'] = k.substring(k.indexOf(',')+1).trim();
  return v;
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
    dst.insertOne(convert(ans)).then((ans) => res.json(ans), next);
  }, next);
  x.post('/', post);
  x.post('/:id', post);
  return x;
};
