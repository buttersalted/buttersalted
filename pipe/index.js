'use strict';
const express = require('express');
const usdaNdb = require('./usda-ndb');

module.exports = function(dst) {
  const x = express();
  x.use('/usda-ndb', usdaNdb(dst.food));
  console.log('pipe: setup');
  return x;
};
