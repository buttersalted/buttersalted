'use strict';
const fs = require('fs');
const http = require('http');
const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');
const pgconfig = require('pg-connection-string');
const Data = require('./data');
const FoodJson = require('./json/food');
const GroupJson = require('./json/group');
const TermJson = require('./json/term');
const TypeJson = require('./json/type');
const Sql = require('./sql');

const E = process.env;
const X = express();
const server = http.createServer(X);
const dbpool = new pg.Pool(pgconfig(E.DATABASE_URL));
const data = new Data(dbpool);
const jfood = new FoodJson(data.food);
const jgroup = new GroupJson(data.group);
const jterm = new TermJson(data.term);
const jtype = new TypeJson(data.type);
const sql = new Sql(dbpool);
server.listen(E.PORT||80);
data.setup();

X.use(bodyParser.json());
X.use(bodyParser.urlencoded({'extended': true}));
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
- UPDATE KEY-TAGS
- UPDATE VIEWS (NEW COLUMNS)
- RAW THINGS LOOK GOOD
- WRITE MORE, IN ONE PAGE
- MORE UNITS
- TRANSFORMATIONS
- EVEN MORE TOOLS
- MORE DATABASE
- USE LIMITS
- FACE THE ROOKIES
*/
