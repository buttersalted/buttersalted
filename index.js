'use strict';
const fs = require('fs');
const path = require('path');
const http = require('http');
const uuidv1 = require('uuid/v1');
const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');
const pgconfig = require('pg-connection-string');
const Data = require('./data');
const Json = require('./json');
const Pipe = require('./pipe')
const Sql = require('./sql');

// I. global variables
const E = process.env;
const X = express();
const HTML = path.join(__dirname, 'docs');
const server = http.createServer(X);
const dbpool = new pg.Pool(pgconfig(E.DATABASE_URL));
const data = new Data(dbpool);
const json = Json(data);
const pipe = Pipe(data);
const sql = new Sql(dbpool, data);

function reqLog(req, res, next) {
  // 1. log request details
  const {port, family, address} = req.socket.address();
  const from = req.headers['x-forwarded-for']||`${address}:${port} (${family})`;
  const proto = req.headers['x-forwarded-proto']||'http';
  const start = req.headers['x-request-start']||`${Date.now()}`;
  const length = req.headers['content-length']||'?';
  req.id = req.headers['x-request-id']||uuidv1();
  console.log(`T${start}: id:${req.id} ${from} -> ${proto} ${req.method} ${req.url} length:${length}`);
  next();
};

// II. setup server
server.listen(E.PORT||80);
server.on('listening', () => {
  const {port, family, address} = server.address();
  console.log(`server: listening on ${address}:${port} (${family})`);
});

// III. setup database
data.setup().then(
  () => console.log('data: setup done'),
  (err) => console.error('data:', err)
);

// IV. setup express
X.use(reqLog);
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
// product
// ingredient
// TERM: ID TYPE/VALUE -> NULL / '' (REJECT COLUMN)
// TYPE: ID VALUE UNIT / UNIT: ID TO_BASE VALUE

/*
- DEFINE A WAY TO COMPARE VALUES RECEIVED FROM PIPE
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
- NEED TO SEE ID, NAME ALWAYS IN TABLE?
- FOOD RESULTS TOO MANY TO SEE, HARD SCROLL
- UNIT CONVERSION X -> INT -> Y FULL TABLE
- TERM CAN BE USED FROM LOWER TO UPPER
- DATA FROM DIFFERENT SOURCES CAN BE DIFFERENT (AVERAGE AND KEEP)
- MAKE SURE DATA ALREADY NOT EXISTS
- ONLY ONE PIPE, TRY ADDING MORE
- ADDING GROUP IS A TIME TAKING PROCESS
- ABILITY TO SEE STATUS OF QUERY (AND STOP)
- RUN SQL QUERY, SQL OPERATIONS, AND USER OPERATIONS IN SEPARATE USERS
- MAKE SURE GROUP ALWAYS CREATES VIEW ON FOOD TABLE ONLY
*/
