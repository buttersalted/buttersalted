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
  // 5. units to convert input to food
  this.unit = new DbTable('unit', db, {
    'setup': rstream('unit.sql'),
    'map': true
  });
  // 6. junkyard wars between functions
  this.utility = new DbTable('utility', db, {
    'setup': rstream('utility.sql')
  });
};
module.exports = $;

const _ = $.prototype;

_.setup = function() {
  // 1. setup utility functions
  return this.utility.setup().then(() => (
  // 2. setup type (dependencies first)
    this.type.setup()
  )).then(Promise.all([
  // 3. setup food, group, term, unit concurrently
    // this.food.setup(),
    // this.group.setup(),
    // this.term.setup(),
    this.unit.setup()
  ]));
};
