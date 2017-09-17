'use strict';
const pg = require('pg');
const http = require('http');
const express = require('express');
const bodyParser = require('body-parser');
const FoodData = require('./data/food');
const GroupData = require('./data/group');
const NameData = require('./data/name');
const TypeData = require('./data/type');

const E = process.env;
const X = express();
const server = http.createServer(X);
const dbpool = new pg.Pool(pgconfig(E.DATABASE_URL));
const food = new FoodData(dbpool);
const group = new GroupData(dbpool);
const name = new NameData(dbpool);
const type = new TypeData(dbpool);
server.listen(E.PORT||80);

X.use(bodyParser.json());
X.use(bodyParser.urlencoded({'extended': true}));
X.use((req, res, next) => {
  req.body = Object.assign(req.body, req.query);
  next();
});
X.use((req, res) => {
  res.send('Haaarrry Ppottterrr ...');
});
// product
// ingredient
