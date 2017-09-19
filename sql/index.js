'use strict';
const express = require('express');

module.exports = function(db) {
  const x = express();
  x.get('/:val', (req, res, next) => db.query(req.params.val).then((ans) => res.send(ans.rows||[]), next));
  return x;
};
