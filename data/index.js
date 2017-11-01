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
  this.fillin = new DbTable('fillin', db, {
    'setup': rstream('fillin.sql'),
    'map': true
  });
  // 3. to store basic data type info
  this.field = new DbTable('field', db, {
    'setup': rstream('field.sql'),
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
    'rename': this.fillin._map
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
    this.unit.setup()).then(() =>
    this.field.setup()).then(() =>
    this.fillin.setup()).then(() =>
    this.group.setup()).then(() =>
    //this.food.setup()).then(() =>
    //this.values.setup()).then(() =>
  // 2. fill up the maps (order, uhunhh)
    this.unit.select({})).then(() =>
    this.field.select({})).then(() =>
    //this.fillin.select({})
    {}
  );
};
