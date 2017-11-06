'use strict';
const express = require('express');
const searchall = require('nutritionvalue-searchall');
const body = (req) => Object.assign(req.body, req.query);

const convert = function(a) {
  // 1. get object key (id)
  const i = Object.keys(a)[0];
  if(!i) return a;
  // 2. convert object to row format
  return Object.assign(a[i], {'Id': i});
};

module.exports = function(dst) {
  const x = express();
  // 1. setup get from nutritionvalue-searchall
  x.get('/:id', (req, res, next) => searchall(req.params.id).then((ans) => {
    res.json(convert(ans));
  }, next));
  // 2. setup insert using nutritionvalue-searchall
  x.post('/', (req, res, next) => searchall(body(req).id).then((ans) => {
    if(!Object.keys(ans).length) return next(new Error('not available'));
    dst.insertOne(convert(ans)).then((ans) => res.json(ans), next);
  }, next));
  return x;
};
