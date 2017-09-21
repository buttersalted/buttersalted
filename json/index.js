'use strict';
const express = require('express');
const food = require('./food');
const group = require('./group');
const term = require('./term');
const type = require('./type');

module.exports = function Json(src) {
  const x = express();
  x.use('/food', food(src.food));
  x.use('/group', group(src.group));
  x.use('/term', term(src.term));
  x.use('/type', type(src.type));
  return x;
};
