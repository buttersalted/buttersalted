'use strict';
const fs = require('fs');
const _format = require('object-format');

const _read = (p) => fs.readFileSync(__dirname+'/'+p);
const SQL_CREATE = _read('create.sql');
const SQL_SELECT = _read('select.sql');
const SQL_UPDATE = _read('update.sql');
const SQL_INSERTONE = _read('insertone.sql');
const SQL_UPSERTONE = _read('upsertone.sql');
const SQL_DELETEONE = _read('deleteone.sql');

const $ = function TypeData(db) {
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
  const q = SQL_SELECT+(q? ' WHERE '+q : '')+(l!=null? 'LIMIT '+l : '');
  return this._db.query(q, p);
};

_.update = function(a, b) {
  const p = [], q = _format(a, '"%k" LIKE $%i', ' AND ', p, 1);
  const s = _format(b, '"%k"=$%i', ' AND ', p, p.length+1);
  return this._db.query(SQL_UPDATE+(s? ' SET '+s : '')+(q? ' WHERE '+q : ''));
};

_.selectOne = function(a) {
  return {'id': a.id, 'value': this._map.get(a.id)};
};

_.insertOne = function(a) {
  return this._db.query(SQL_INSERTONE, [a.id, a.value]).then((ans) => {
    this._map.set(a.id, a.value);
    return ans;
  });
};

_.upsertOne = function(a) {
  return this._db.query(SQL_UPSERTONE, [a.id, a.value]).then((ans) => {
    this._map.set(a.id, a.value);
    return ans;
  });
};

_.deleteOne = function(a) {
  return this._db.query(SQL_DELETEONE, [a.id]).then((ans) => {
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
