'use strict';
const fs = require('fs');
const DbTable = require('./dbtable');
const rstream = (f) => fs.createReadStream(__dirname+'/'+f, 'utf8');

const $ = function Data(db) {
  // 1. this is to list maintain groups
  this.group = new DbTable('group', db, {
    'setup': rstream('group.sql')
  });
  // 2. we can store some alternate terms here
  this.term = new DbTable('term', db, {
    'setup': rstream('term.sql'),
    'map': true
  });
  // 3. to store basic data type info
  this.type = new DbTable('type', db, {
    'setup': rstream('type.sql'),
    'map': true
  });
  // 4. units to convert input to food
  this.unit = new DbTable('unit', db, {
    'setup': rstream('unit.sql'),
    'map': true
  });
  // 5. junkyard wars between functions
  this.utility = new DbTable('utility', db, {
    'setup': rstream('utility.sql')
  });
  // 6. setup food table (this is the big one)
  this.food = new DbTable('food', db, {
    'setup': rstream('food.sql'),
    'rename': this.term._map
  });
  // 7. all the default values
  this.values = new DbTable('values', db, {
    'setup': rstream('values.sql')
  });
};
module.exports = $;

const _ = $.prototype;

_.setup = function() {
  // 1. setup in sequence (order, order)
  return this.utility.setup().then(() =>
    this.type.setup()).then(() =>
    this.unit.setup()).then(() =>
    this.term.setup()).then(() =>
    this.food.setup()).then(() =>
    this.group.setup()).then(() =>
    this.values.setup()).then(() =>
  // 2. fill up the maps (order, uhunhh)
    this.type.select({})).then(() =>
    this.unit.select({})).then(() =>
    this.term.select({})).then(() =>
    console.log('data: setup')
  );
};
