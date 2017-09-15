'use strict';
const fs = require('fs');
const lo = require('lodash');
const _format = require('object-format');

const _read = (p) => fs.readFileSync(__dirname+'/'+p);
const SQL_CREATE = _read('create.sql');
const SQL_SELECT = _read('select.sql');
const SQL_INSERTONE = _read('insertone.sql');
const SQL_DELETEONE = _read('deleteone.sql');

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
  const q = SQL_SELECT+(q? ' WHERE '+q : '')+(l!=null? 'LIMIT '+l : '');
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
  return this._db.query(SQL_INSERTONE, [a.id, a.key, a.tag, a.value]);
};

_.upsertOne = function(a) {
  return this.selectOne(a).then((ans) => {
    return this.deleteOne(a).then(() => ans);
  }).then((ans) => this.insertOne(lo.assign(ans, a)));
};

_.deleteOne = function(a) {
  return this._db.query(SQL_DELETEONE, [a.id]);
};

_.setup = function() {
  return this.create();
};
