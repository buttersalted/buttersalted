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

function strRename(val, map) {
  // 1. rename string using a map
  val = val.toLowerCase();
  return map.get(val)||val;
};

function sqlRenameId(ast, map) {
  // 1. rename identifier using a map
  if(ast.db) ast.db = null;
  if(ast.table) ast.table = strRename(ast.table, map);
  if(ast.column) ast.column = strRename(ast.column, map);
};

function sqlRenameExp(ast, map) {
  // 1. rename expression using a map
  if(!ast || typeof ast!=='object') return ast;
  if(ast instanceof Array) for(var a of ast)
    sqlRenameExp(a, map);
  else if(!ast.table) for(var k in ast)
    sqlRenameExp(ast[k], map);
  else sqlRenameId(ast, map);
};

function sqlRename(ast, map) {
  // 1. rename sql statement using map
  if(typeof ast.columns!=='string') for(var a of ast)
    sqlRenameExp(a.expr, map);
  if(ast.from) for(var a of ast.from)
    sqlRenameExp(a, map);
  if(ast.where) sqlRenameExp(ast.where);
  if(ast.having) sqlRenameExp(ast.having);
  if(ast.orderby) for(var a of ast.orderby)
    sqlRenameExp(a.expr, map);
  if(ast.groupby) for(var a of ast.groupby)
    sqlRenameExp(a, map);
};

function sqlLimit(sql, val) {
  // 1. set limit to a maximum value
  if(ast.limit && ast.limit[1].value>64) ast.limit[1].value = 64;
  else ast.limit = [{'type': 'number', 'value': 0}, {'type': 'number', 'value': 0}];
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
