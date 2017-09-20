'use strict';
const fs = require('fs');
const http = require('http');
const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');
const pgconfig = require('pg-connection-string');
const FoodData = require('./data/food');
const GroupData = require('./data/group');
// const TermData = require('./data/term');
// const TypeData = require('./data/type');
const DbTable = require('./data');
const FoodJson = require('./json/food');
const GroupJson = require('./json/group');
const TermJson = require('./json/term');
const TypeJson = require('./json/type');
const Sql = require('./sql');

const E = process.env;
const X = express();
const server = http.createServer(X);
const dbpool = new pg.Pool(pgconfig(E.DATABASE_URL));
const dfood = new FoodData(dbpool);
const dgroup = new GroupData(dbpool);
// const dname = new TermData(dbpool);
// const dtype = new TypeData(dbpool);
const dtype = new DbTable('type', dbpool, {
  'setup': fs.createReadStream(__dirname+'/data/type.sql', 'utf8'),
  'map': true
});
const dterm = new DbTable('term', dbpool, {
  'setup': fs.createReadStream(__dirname+'/data/term.sql', 'utf8'),
  'map': true
});
const jfood = new FoodJson(dfood);
const jgroup = new GroupJson(dgroup);
const jterm = new TermJson(dterm);
const jtype = new TypeJson(dtype);
const sql = new Sql(dbpool);
server.listen(E.PORT||80);
dtype.setup();
dterm.setup();
dgroup.setup();
dfood.setup();

X.use(bodyParser.json());
X.use(bodyParser.urlencoded({'extended': true}));
X.use((req, res, next) => {
  req.body = Object.assign(req.body, req.query);
  next();
});
X.use('/json/type', jtype);
X.use('/json/term', jterm);
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
