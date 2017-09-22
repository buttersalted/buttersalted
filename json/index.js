'use strict';
const express = require('express');
const JsonTable = require('./jsontable');

module.exports = function Json(src) {
  const x = express();
  x.use('/food', JsonTable(src.food));
  x.use('/group', JsonTable(src.group));
  x.use('/term', JsonTable(src.term));
  x.use('/type', JsonTable(src.type));
  x.use('/unit', JsonTable(src.unit));
  return x;
};
