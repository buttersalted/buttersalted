'use strict';
const http = require('http');
const express = require('express');

const E = process.env;
const X = express();
const server = http.createServer(X);
server.listen(E.PORT||80);

X.use((req, res) => {
  res.send('System.out.println("Hello NITIANS!");');
});
