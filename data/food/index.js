'use strict';
const fs = require('fs');
const _format = require('object-format');

const _read = (p) => fs.readFileSync(__dirname+'/'+p);
const SQL_CREATE = _read('create.sql');
const SQL_SELECT = 'SELECT * FROM "food"';
const SQL_UPDATE = 'UPDATE "food"';
const SQL_INSERTONE = 'SELECT food_insertone($1)';
const SQL_DELETEONE = 'SELECT food_deleteone($1)';
const SQL_PENDINGINSERT = 'SELECT food_pendinginsert()';
const SQL_PENDINGDELETEONE = 'SELECT food_pendingdeleteone($1)';
const SQL_UPSERTONE = _read('upsertone.sql');

const $ = function FoodData(db) {
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
  const p = [], w = _format(a, '"%k" LIKE $%i', ' AND ', p, 1);
  const s = _format(b, '"%k"=$%i', ' AND ', p, p.length+1);
  const q = SQL_UPDATE+(s? ' SET '+s : '')+(w? ' WHERE '+w : '');
  return this._db.query(q, p);
};

_.selectOne = function(a) {
  return this.select({'id': a.id});
};

_.insertOne = function(a) {
  return this._db.query(SQL_INSERTONE, [a]);
};

_.updateOne = function(a) {
  return this.update({'id': a.id}, a);
};

_.upsertOne = function(a) {
  return this.selectOne(a).then((ans) => {
    return ans.rowCount? this.updateOne(a) : this.insertOne(a);
  });
};

_.deleteOne = function(a) {
  return this._db.query(SQL_DELETEONE, [a]);
};

_.pendingInsert = function() {
  return this._db.query(SQL_PENDINGINSERT);
};

_.pendingDeleteOne = function(a) {
  return this._db.query(SQL_PENDINGDELETEONE, [a]);
};

_.setup = function() {
  return this.create();
};
