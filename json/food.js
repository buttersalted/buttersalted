'use strict';
const express = require('express');

module.exports = function(src) {
  const x = express();
  x.get('/', (req, res) => src.select(req.body).then((ans) => res.send(ans.rows||[])));
  x.post('/', (req, res) => src.insertOne(req.body).then((ans) => res.send(1)));
  x.get('/:id', (req, res) => src.selectOne(req.body).then((ans) => res.send(ans.rows||[])));
  x.patch('/:id', (req, res) => src.upsertOne(req.body).then((ans) => res.send(1)));
  x.delete('/:id', (req, res) => src.deleteOne(req.body).then((ans) => res.send(1)));
  x.get('/:id/execute', (req, res) => src.executeOne(req.body).then((ans) => res.send(1)));
  x.get('/:id/unexecute', (req, res) => src.unexecuteOne(req.body).then((ans) => res.send(1)));
  x.get('/pending', (req, res) => src.pendingInsert(req.body).then((ans) => res.send(1)));
  x.delete('/pending/:id', (req, res) => src.pendingDeleteOne(req.body).then(ans) => res.send(1));
  return x;
};
