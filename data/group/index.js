'use strict';
const fs = require('fs');
const _format = require('object-format');

const _read = (p) => fs.readFileSync(__dirname+'/'+p);
const SQL_CREATE = _read('create.sql');
const SQL_SELECT = 'SELECT * FROM "group"';
const SQL_INSERTONE = 'SELECT group_insertone($1)';
const SQL_DELETEONE = 'SELECT group_deleteone($1)';

const $ = function NameData(db) {
  this._db = db;
};
module.exports = $;

const _ = $.prototype;

_.create = function() {
  return this._db.query(SQL_CREATE);
};

_.select = function(a, l) {
  const p = [], w = _format(a, '"%k" LIKE $%i', ' AND ', p, 1);
  const q = SQL_SELECT+(w? ' WHERE '+w : '')+(l!=null? 'LIMIT '+l : '');
  return this._db.query(q, p);
};

_.update = function(a, b) {
  return this.select(a).then((ans) => {
    for(var i=0, I=ans.rowCount, R=ans.rows, p=[]; i<I; i++)
      p.push(this.upsertOne(R, b));
    return Promise.all(p);
  });
};

_.selectOne = function(a) {
  return this.select({'id': a.id});
};

_.insertOne = function(a) {
  return this._db.query(SQL_INSERTONE, [a]);
};

_.upsertOne = function(a) {
  return this.selectOne(a).then((ans) => {
    return this.deleteOne(a).then(() => ans);
  }).then((ans) => this.insertOne(Object.assign(ans, a)));
};

_.deleteOne = function(a) {
  return this._db.query(SQL_DELETEONE, [a]);
};

_.setup = function() {
  return this.create();
};
