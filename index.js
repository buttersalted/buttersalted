'use strict';
const http = require('http');
const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');
const pgconfig = require('pg-connection-string');
const FoodData = require('./data/food');
const GroupData = require('./data/group');
const NameData = require('./data/name');
const TypeData = require('./data/type');
const FoodJson = require('./json/food');
const GroupJson = require('./json/group');
const NameJson = require('./json/name');
const TypeJson = require('./json/type');
const Sql = require('./sql');

const E = process.env;
const X = express();
const server = http.createServer(X);
const dbpool = new pg.Pool(pgconfig(E.DATABASE_URL));
const dfood = new FoodData(dbpool);
const dgroup = new GroupData(dbpool);
const dname = new NameData(dbpool);
const dtype = new TypeData(dbpool);
const jfood = new FoodJson(dfood);
const jgroup = new GroupJson(dgroup);
const jname = new NameJson(dname);
const jtype = new TypeJson(dtype);
const sql = new Sql(dbpool);
server.listen(E.PORT||80);
dtype.setup();
dname.setup();
dgroup.setup();
dfood.setup();

X.use(bodyParser.json());
X.use(bodyParser.urlencoded({'extended': true}));
X.use((req, res, next) => {
  req.body = Object.assign(req.body, req.query);
  next();
});
X.use('/json/type', jtype);
X.use('/json/name', jname);
X.use('/json/group', jgroup);
X.use('/json/food', jfood);
X.use('/sql', sql);
X.use('/', (req, res) => {
  res.send('Haaarrry Ppottterrr ...');
});
X.use((err, req, res, next) => {
  res.status(400).send(err.message);
  console.error(err);
});
// product
// ingredient
/*
- RAW THINGS LOOK GOOD
- WRITE MORE, IN ONE PAGE
- MORE UNITS
- TRANSFORMATIONS
- EVEN MORE TOOLS
- MORE DATABASE
- USE LIMITS
- FACE THE ROOKIES
*/
