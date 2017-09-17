'use strict';
const fs = require('fs');
const _format = require('object-format');

const _read = (p) => fs.readFileSync(__dirname+'/'+p);
const SQL_CREATE = _read('create.sql');
const SQL_SELECT = 'SELECT * FROM "name"';
const SQL_UPDATE = 'UPDATE "name"';
const SQL_INSERTONE = 'SELECT name_insertone($1)';
const SQL_UPSERTONE = 'SELECT name_upsertone($1)';
const SQL_DELETEONE = 'SELECT name_deleteone($1)';

const $ = function NameData(db) {
  this._db = db;
  this._map = new Map();
};
module.exports = $;

const _ = $.prototype;

_.create = function() {
  return this._db.query(SQL_CREATE);
};

_.select = function(a, l) {
  const p = [], w = _format(a, '"%k" LIKE $%i', ' AND ', p, 1);
  const q = SQL_SELECT+(w? ' WHERE '+w : '')+(l!=null? ' LIMIT '+l : '');
  return this._db.query(q, p);
};

_.update = function(a, b) {
  const p = [], w = _format(a, '"%k" LIKE $%i', ' AND ', p, 1);
  const s = _format(b, '"%k"=$%i', ' AND ', p, p.length+1);
  const q = SQL_UPDATE+(s? ' SET '+s : '')+(w? ' WHERE '+w : '');
  return this._db.query(q, p);
};

_.selectOne = function(a) {
  return {'id': a.id, 'value': this._map.get(a.id)};
};

_.insertOne = function(a) {
  return this._db.query(SQL_INSERTONE, [a]).then((ans) => {
    this._map.set(a.id, a.value);
    return ans;
  });
};

_.upsertOne = function(a) {
  return this._db.query(SQL_UPSERTONE, [a]).then((ans) => {
    this._map.set(a.id, a.value);
    return ans;
  });
};

_.deleteOne = function(a) {
  return this._db.query(SQL_DELETEONE, [a]).then((ans) => {
    this._map.delete(a.id);
    return ans;
  });
};

_.setup = function() {
  return this.create().then(() => {
    return this.select({});
  }).then((ans) => {
    for(var i=0, I=ans.rowCount, R=ans.rows; i<I; i++)
      this._map.set(R[i].id, R[i].value);
  });
};
