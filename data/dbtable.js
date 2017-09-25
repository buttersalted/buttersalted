'use strict';
const stream = require('stream');
stream.is = require('is-stream');
stream.toString = require('stream-string');
const format = require('object-format');

const $ = function DbTable(id, db, opt) {
  this._id = id;
  this._db = db;
  this._opt = opt||{};
};
module.exports = $;

const _ = $.prototype;

_.select = function(a, l) {
  // 1. get where with like, limit
  const p = [], w = format(a, '"%k" LIKE $%i', ' AND ', 1, p);
  const q = (w? ' WHERE '+w : '')+(l!=null? ' LIMIT '+l : '');
  // 2. execute the query (if its still valid)
  return this._db.query(`SELECT * FROM "${this._id}"`+q, p);
};

_.insert = function(a) {
  // 1. get columns and values (to insert)
  const p = [], c = format(a, '"%k"', ',', 1, p), v = format(a, '$%i', ',', 1);
  // 2. execute an insert query (lets fight)
  return this._db.query(`INSERT INTO "${this._id}" (${c}) VALUES (${v})`, p);
};

_.delete = function(a) {
  // 1. get where with like
  const p = [], w = format(a, '"%k" LIKE $%i', ' AND ', 1, p);
  // 2. execute the query (ready for disaster?)
  return this._db.query(`DELETE FROM "${this._id}"`+(w? ' WHERE '+w : ''), p);
};

_.update = function(a, b) {
  // 1. prepare the update conditions (where, set)
  const p = [], w = format(a, '"%k" LIKE $%i', ' AND ', 1, p);
  const s = format(b, '"%k"=$%i', ' AND ', p.length+1, p);
  const q = (s? ' SET '+s : '')+(w? ' WHERE '+w : '');
  // 2. query to run (and possible do some valid update)
  return this._db.query(`UPDATE "${this._id}"`+q, p);
};

_.selectOne = function(a) {
  // 1. if map we have, get from it using "id"
  if(this._map) return this._map.get(a.id);
  // 2. instead of direct code, lets call a function
  return this._db.query(`SELECT * FROM ${this._id}_selectone($1) t`, [a]);
};

_.insertOne = function(a) {
  // 1. insert new row into the table
  return this._db.query(`SELECT ${this._id}_insertone($1)`, [a]).then((ans) => {
  // 2. if map exists, then add it there too
    if(this._map) this._map.set(a.id, a);
    return ans;
  });
};

_.upsertOne = function(a) {
  // 1. insert or update row to table
  return this._db.query(`SELECT ${this._id}_upsertone($1)`, [a]).then((ans) => {
  // 2. if map exists, then add it there
    if(this._map) this._map.set(a.id, a);
    return ans;
  });
};

_.deleteOne = function(a) {
  // 1. delete row from table
  return this._db.query(`SELECT ${this._id}_deleteone($1)`, [a]).then((ans) => {
  // 2. if map exists, then why still keep it there?
    if(this._map) this._map.delete(a.id);
    return ans;
  });
};

_.call = function(fn, args) {
  // 1. generate argument list
  const a = format(args||[], '$%i', ',', 1);
  // 2. make a function call with arguments (for those extra secretives)
  return this._db.query(`SELECT ${fn}(${a})`, args||[]);
};

_.setup = function() {
  // 1. get setup sql command (opt.setup = string/stream)
  return Promise.resolve(this._opt.setup||'').then((ans) => {
    return stream.is(ans)? stream.toString(ans) : ans;
  // 2. run the setup commands (just crash if its garbage $)
  }).then((ans) => {
    return this._db.query(ans);
  // 3. get a map if its required (opt.map = true)
  }).then((ans) => {
    return !this._opt.map? ans : this.select({}).then((ans) => {
      const map = this._map = new Map();
      for(var i=0, I=ans.rowCount, R=ans.rows; i<I; i++)
        map.set(R[i].id, R[i]);
    });
  });
};
