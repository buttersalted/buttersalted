'use strict';
const express = require('express');
const body = (req) => Object.assign(req.body, req.query);

module.exports = function JsonTable(src) {
  const x = express();
  x.get('/', (req, res, next) => src.select(body(req)).then((ans) => res.json(ans.rows||[]), next));
  x.post('/', (req, res, next) => src.insertOne(body(req)).then((ans) => res.json(1), next));
  x.get('/:id', (req, res, next) => src.selectOne(req.params).then((ans) => res.json(ans.rows||[]), next));
  x.patch('/:id', (req, res, next) => src.updateOne(req.params, body(req)).then((ans) => res.json(1), next));
  x.delete('/:id', (req, res, next) => src.deleteOne(req.params).then((ans) => res.json(1), next));
  return x;
};
