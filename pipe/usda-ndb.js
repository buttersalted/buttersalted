'use strict';
const express = require('express');
const usdaNdb = require('usda-ndb');
const src = (a) => usdaNdb(a.start, a.stop, a.step);
const body = (req) => Object.assign(req.body, req.query, req.params);

const convert = function(a) {
  return Object.keys(a).map((k) => Object.assign(a[k], {
    'Id': parseInt(k.substring(k.lastIndexOf(',')+1)),
    'Name': k.substring(0, k.lastIndexOf(','))
  }));
};

module.exports = function(dst) {
  const x = express();
  x.get('/', (req, res, next) => src(body(req)).then((ans) => {
    res.json(convert(ans));
  }, next));
  x.post('/', (req, res, next) => src(body(req)).then((ans) => {
    var a = convert(ans), p = [], z = {}, e = 0;
    const insert = (v) => dst.insertOne(v).then(
      (ans) => z[v.Id] = ans.rowCount,
      (err) => {e = 1; return z[v.Id] = err.message;}
    );
    for(var v in a) p.push(insert(v));
    Promise.all(p).then(() => (e? res.status(400) : res).json(z));
  }, next));
};
