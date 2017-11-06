'use strict';
const express = require('express');
const ndb = require('usda-ndb');
const body = (req) => Object.assign(req.body, req.query);

const convert = function(a) {
  // 1. get object key (id, name)
  const v = Object.values(a)[0];
  if(!v) return a;
  // 2. convert object to row format
  const n = v.Name;
  const Id = parseInt(n.substring(0, n.indexOf(',')));
  const Name = n.substring(n.indexOf(',')+1).trim();
  return Object.assign(v, {Id, Name});
};

module.exports = function(dst) {
  const x = express();
  // 1. setup get from usda-ndb
  x.get('/:id', (req, res, next) => ndb(req.params.id).then((ans) => {
    res.json(convert(ans));
  }, next));
  // 2. setup insert using usda-ndb
  x.post('/', (req, res, next) => ndb(body(req).id).then((ans) => {
    if(!Object.keys(ans).length) return next(new Error('not available'));
    dst.insertOne(convert(ans)).then((ans) => res.json(ans), next);
  }, next));
  return x;
};
