'use strict';
const express = require('express');
const body = (req) => Object.assign(req.body, req.query, req.params);

module.exports = function(db) {
  const x = express();
  x.get('/:value', (req, res, next) => db.query(body(req).value).then((ans) =>
    res.send(ans.rows||[]), next)
  );
  return x;
};
