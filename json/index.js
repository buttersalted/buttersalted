'use strict';
const express = require('express');
const JsonTable = require('./jsontable');

module.exports = function Json(src) {
  const x = express();
  x.use('/food', JsonTable(src.food));
  x.use('/group', JsonTable(src.group));
  x.use('/fillin', JsonTable(src.fillin));
  x.use('/field', JsonTable(src.field));
  x.use('/unit', JsonTable(src.unit));
  return x;
};
