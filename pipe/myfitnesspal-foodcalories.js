'use strict';
const express = require('express');
const foodcalories = require('myfitnesspal-foodcalories');
const body = (req) => Object.assign(req.body, req.query);

const convert = function(a) {
  // 1. get object key (id)
  const i = Object.keys(a)[0];
  if(!i) return a;
  // 2. convert object to row format
  return Object.assign({'Id': i}, a[i]);
};

module.exports = function(dst) {
  const x = express();
  // 1. setup get from myfitnesspal-foodcalories
  x.get('/:id', (req, res, next) => foodcalories(req.params.id).then((ans) => {
    res.json(convert(ans));
  }, next));
  // 2. setup insert using myfitnesspal-foodcalories
  x.post('/', (req, res, next) => foodcalories(body(req).id).then((ans) => {
    if(!Object.keys(ans).length) return next(new Error('not available'));
    dst.insertOne(convert(ans)).then((ans) => res.json(ans), next);
  }, next));
  return x;
};
