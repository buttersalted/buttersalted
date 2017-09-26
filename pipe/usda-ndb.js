'use strict';
const express = require('express');
const usdaNdb = require('usda-ndb');
const body = (req) => Object.assign(req.body, req.query, req.params);

const each = function(a, fn) {
  // 1. get start, stop, step
  const inc = Math.sign(a.step||1);
  const start = a.start||0, stop = a.stop||start+1, step = a.step||1;
  const fetch = (id) => pro.then(() => usdaNdb(id)).then(fn);
  // 2. get object for every id, and call the callback fn
  for(var i=start, pro=Promise.resolve(); i!==stop;) {
    for(var I=Math.min(stop, i+step), p=[]; i!==I; i+=inc)
      p.push(fetch(i));
    pro = Promise.all(p);
  }
  // 3. return all objects got promise
  return pro;
};

const convert = function(a) {
  // 1. convert object to row format
  return Object.keys(a).map((k) => Object.assign(a[k], {
    'Id': parseInt(k.substring(0, k.indexOf(','))),
    'Name': k.substring(k.indexOf(',')+1).trim()
  }));
};

module.exports = function(dst) {
  const x = express();
  // 1. setup get from usda-ndb
  x.get('/', (req, res, next) => {
    const z = [];
    each(body(req), (ans) => z.push(convert(ans))).then(() => res.json(z), next);
  });
  // 2. setup insert using usda-ndb
  x.post('/', (req, res, next) => {
    var z = [], p = [], e = 0;
    // 1. get all objects and insert as rows
    each(body(req), (ans) => {
      const row = convert(ans);
      p.push(dst.insertOne(row).then(
        (ans) => z[row.Id] = ans.rowCount,
        (err) => {e = 1; return z[row.Id] = err.message;}
      ));
    // 2. return status of each insert
    }).then(() => Promise.all(p)).then(() => {
      (e? res.status(400) : res).json(z);
    }, next);
  });
  return x;
};
