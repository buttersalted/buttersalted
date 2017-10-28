'use strict';
const fs = require('fs');
const path = require('path');
const http = require('http');
const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');
const pgconfig = require('pg-connection-string');
const Data = require('./data');
const Json = require('./json');
const Pipe = require('./pipe')
const Sql = require('./sql');

const E = process.env;
const X = express();
const HTML = path.join(__dirname, 'html');
const server = http.createServer(X);
const dbpool = new pg.Pool(pgconfig(E.DATABASE_URL));
const data = new Data(dbpool);
const json = Json(data);
const pipe = Pipe(data);
const sql = new Sql(dbpool);
server.listen(E.PORT||80);
data.setup().catch((err) => {
  console.error(err);
});

X.use(bodyParser.json());
X.use(bodyParser.urlencoded({'extended': true}));
X.use('/json', json);
X.use('/pipe', pipe);
X.use('/sql', sql);
X.use('/', express.static(HTML, {'extensions': ['html']}));
X.use((err, req, res, next) => {
  res.status(400).send(err.message);
  console.error(err);
});
console.log('server: setup');
// product
// ingredient
/*
- ADD LOGS TO SERVER CODE
- DEFINE A WAY TO COMPARE VALUES RECEIVED FROM PIPE
- DEFINE A WAY TO REJECT UNNECESSARY COLUMNS
- PIPE ACCEPT MULTIPLE SOURCES (ID, NAME, SOURCE)
- SHOW UNITS FOR EACH COLUMN IN TABLE
- CHANGE IN SETTINGS UNIT SHOW
- QUERY / ACTION TRACKING (AND STOP)
- ALLOW INSERTING INTO GROUP DIRECTLY
- PHOTOS SEARCH
- INDIVIDUAL FOOD PAGE
- LINK TO AMAZON
- ADD FOOD FROM AMAZON PANTRY
- ACCEPT NATURAL LANGUAGE
- HELP LINKS TO README
- ACCEPT SIMPLER SQL COMMANDS (NOT FULL SQL)
- FORM TO BUTTON GAP CAN BE INCREASED
- NEED TO SEE ID, NAME ALWAYS IN TABLE?
- FOOD RESULTS TOO MANY TO SEE, HARD SCROLL
- BASE UNIT NOT SPECIFIED?
- TERM CAN BE USED FROM LOWER TO UPPER
- DATA FROM DIFFERENT SOURCES CAN BE DIFFERENT (AVERAGE AND KEEP)
- MAKE SURE DATA ALREADY NOT EXISTS
- ONLY ONE PIPE, TRY ADDING MORE
- PAGE URL DOES NOT CHANGE ON ADD? IS INTENTIONAL
- PAGE TITLE NEVER CHANGES, HARD TO USE BACK
- IT IS POSSIBLE TO USE ONE COLUMN FOR GROUP
- ACTION SUCCESSFUL: BUT WHICH ACTION?
- ADDING GROUP IS A TIME TAKING PROCESS
- SEPARATE TABLES FOR EACH TAB
- ABILITY TO SEE STATUS OF QUERY (AND STOP)
- REPLACE TERMS SQL
- USE LIMITS
*/
