'use strict';
const express = require('express');

module.exports = function(src) {
  const x = express();
  x.get('/', (req, res, next) => src.select(req.body).then((ans) => res.json(ans.rows||[]), next));
  x.post('/', (req, res, next) => src.insertOne(req.body).then((ans) => res.json(1), next));
  x.get('/:id', (req, res, next) => src.selectOne(req.body).then((ans) => res.json(ans.rows||[]), next));
  x.patch('/:id', (req, res, next) => src.upsertOne(req.body).then((ans) => res.json(1), next));
  x.delete('/:id', (req, res, next) => src.deleteOne(req.body).then((ans) => res.json(1), next));
  x.get('/:id/execute', (req, res, next) => src.executeOne(req.body).then((ans) => res.json(1), next));
  x.get('/:id/unexecute', (req, res, next) => src.unexecuteOne(req.body).then((ans) => res.json(1), next));
  return x;
};
