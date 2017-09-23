'use strict';
const express = require('express');
const body = (req) => Object.assign(req.body, req.query, req.params);

module.exports = function(db) {
  const x = express();
  x.get('/:val', (req, res, next) => db.query(body(req)).then((ans) =>
    res.send(ans.rows||[]), next)
  );
  return x;
};
