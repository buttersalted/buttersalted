'use strict';
const fs = require('fs');
const stream = require('stream');
stream.is = require('is-stream');
stream.toString = require('stream-string');
const _format = require('object-format');

const _read = (p) => fs.readFileSync(__dirname+'/'+p, 'utf8');
const SQL_CREATE = _read('create.sql');
const SQL_SELECT = 'SELECT * FROM "type"';
const SQL_UPDATE = 'UPDATE "type"';
const SQL_INSERTONE = 'SELECT type_insertone($1)';
const SQL_UPSERTONE = 'SELECT type_upsertone($1)';
const SQL_DELETEONE = 'SELECT type_deleteone($1)';

const $ = function TypeData(db, opt) {
  this._db = db;
  this._opt = opt;
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
  // 1. get setup sql command (opt.setup = string/stream)
  return Promise.resolve(this._opt.setup).then((ans) => {
    return stream.is(ans)? stream.toString(ans) : ans;
  // 2. run the setup commnds (just crash if its garbage $)
  }).then((ans) => {
    return this._db.query(ans);
  // 3. get a map if its required (opt.map = true)
  }).then((ans) => {
    return !this._opt.map? ans : this.select({}).then((ans) => {
      const map = this._map = new Map();
      for(var i=0, I=ans.rowCount, R=ans.rows; i<I; i++)
        map.set(R[i].id, R[i].value);
    });
  });
};
