'use strict';
const fs = require('fs');
const DbTable = require('./dbtable');
const rstream = (f) => fs.createReadStream(__dirname+'/'+f, 'utf8');

const $ = function Data(db) {
  // 1. setup food table (this is the big one)
  this.food = new DbTable('food', db, {
    'setup': rstream('food.sql')
  });
  // 2. this is to list maintain groups
  this.group = new DbTable('group', db, {
    'setup': rstream('group.sql')
  });
  // 3. we can store some alternate terms here
  this.term = new DbTable('term', db, {
    'setup': rstream('term.sql'),
    'map': true
  });
  // 4. to store basic data type info
  this.type = new DbTable('type', db, {
    'setup': rstream('type.sql'),
    'map': true
  });
};
module.exports = $;

const _ = $.prototype;

_.setup = function() {
  return Promise.all([
  // 1. setup food, group, type concurrently
    this.food.setup(),
    this.group.setup(),
    this.type.setup().then(() => (
  // 2. setup term after type (dependencies first)
      this.term.setup()
    ))
  ]);
};
