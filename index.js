'use strict';
const http = require('http');
const express = require('express');
const NameData = require('./data/name');
const TypeData = require('./data/type');

const E = process.env;
const X = express();
const server = http.createServer(X);
server.listen(E.PORT||80);

X.use((req, res) => {
  res.send('Haaarrry Ppottterrr ...');
});
// food
// product
// ingredient
// group
