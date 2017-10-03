'use strict';
const express = require('express');
const body = (req) => Object.assign(req.body, req.query, req.params);

module.exports = function(db) {
  const x = express();
  const fn = (req, res, next) => {
    const qry = body(req).value||'';
    if(qry.includes(';') ||
      !qry.toUpperCase().startsWith('SELECT ') ||
      qry.toUpperCase().includes('INTO'))
      throw new Error('bad query');
    db.query(qry).then((ans) => res.send(ans.rows||[]), next)
  };
  x.get('/', fn);
  x.get('/:value', fn);
  return x;
};
