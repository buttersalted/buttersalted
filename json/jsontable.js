'use strict';
const express = require('express');
const body = (req) => Object.assign(req.body, req.query, req.params);

module.exports = function JsonTable(src) {
  const x = express();
  x.get('/', (req, res, next) => src.select(body(req)).then((ans) => res.json(ans.rows||[]), next));
  x.post('/', (req, res, next) => src.insertOne(body(req)).then((ans) => res.json(1), next));
  x.get('/:id', (req, res, next) => src.selectOne(body(req)).then((ans) => res.json(ans.rows||[]), next));
  x.patch('/:id', (req, res, next) => src.upsertOne(body(req)).then((ans) => res.json(1), next));
  x.delete('/:id', (req, res, next) => src.deleteOne(body(req)).then((ans) => res.json(1), next));
  return x;
};
