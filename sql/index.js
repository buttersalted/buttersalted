'use strict';
const express = require('express');

module.exports = function(db) {
  const x = express();
  x.get('/:val', (req, res) => {
    console.log(req.body.val);
    db.query(req.body.val, []).then((ans) => res.send(ans.rows||[]));
  });
  return x;
};
