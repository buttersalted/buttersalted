'use strict';
const express = require('express');
const Parser = require('flora-sql-parser').Parser;
const body = (req) => Object.assign(req.body, req.query, req.params);

function sqlDecomment(txt) {
  // 1. remove multi-line, single-line comments
  txt = txt.replace(/\/\*.*?\*\//g, '');
  txt = txt.replace(/--.*/gm, '');
  return txt.trim();
};

function sqlUpdate(txt) {
  // 1. make sure its a select query
  txt = sqlDecomment(txt);
  txt = txt.endsWith(';')? txt.slice(0, -1) : txt;
  if(txt.includes(';')) throw new Error('too many queries');
  const p = new Parser(), ast = p.parse(txt);
  if(ast.type!=='select') throw new Error('only SELECT query supported');
  
};

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
  return x;
};
