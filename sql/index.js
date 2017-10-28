'use strict';
const express = require('express');
const body = (req) => Object.assign(req.body, req.query, req.params);

module.exports = function(db) {
  const x = express();
  const fn = (req, res, next) => {
    const value = body(req).value||'SELECT * FROM "food"';
    var qry = value.split(';')[0];
    if(!qry.toUpperCase().startsWith('SELECT ') ||
      qry.toUpperCase().includes('INTO'))
      throw new Error('bad query');
    db.query(qry).then((ans) => res.send(ans.rows||[]), next)
  };
  x.get('/', fn);
  x.get('/:value', fn);
  console.log('sql: setup');
  return x;
};
