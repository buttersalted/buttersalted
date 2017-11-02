'use strict';
const express = require('express');
const foodcalories = require('./myfitnesspal-foodcalories');
const searchall = require('./nutritionvalue-searchall');
const ndb = require('./usda-ndb');

module.exports = function(dst) {
  const x = express();
  x.use('/myfitnesspal-foodcalories', foodcalories(dst.food));
  x.use('/nutritionvalue-searchall', searchall(dst.food));
  x.use('/usda-ndb', ndb(dst.food));
  return x;
};
