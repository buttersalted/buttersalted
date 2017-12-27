'use strict';
const NAMES = new Map([
  ['zero', 0],
  ['one', 1],
  ['two', 2],
  ['three', 3],
  ['four', 4],
  ['five', 5],
  ['six', 6],
  ['seven', 7],
  ['eight', 8],
  ['nine', 9],
  ['ten', 10],
  ['eleven', 11],
  ['twelve', 12],
  ['thirteen', 13],
  ['fourteen', 14],
  ['fifteen', 15],
  ['sixteen', 16],
  ['seventeen', 17],
  ['eighteen', 18],
  ['nineteen', 19],
  ['twenty', 20],
  ['thirty', 30],
  ['forty', 40],
  ['fifty', 50],
  ['sixty', 60],
  ['seventy', 70],
  ['eighty', 80],
  ['ninety', 90],
  ['hundred', 1e+2],
  ['thousand', 1e+3],
  ['lakh', 1e+5],
  ['million', 1e+6],
  ['crore', 1e+7],
  ['billion', 1e+9],
  ['trillion', 1e+12],
  ['infinity', Infinity],
  ['infinite', Infinity],
  ['negative', -1]
]);

function isDigit(a) {
  return a.search(/^-?\d(\.\d)?/)===0;
};

function isName(a) {
  if(a.startsWith('-')) a = a.substr(1);
  for(var k of NAMES.keys())
    if(a===k) return true;
  return false;
};

function is(a) {
  return isDigit(a)||isName(a);
};

function update(v) {

};
20+4+(9*100+40+5)
(5*100000+(9*100+40+2)*100+70+8)*10000000
(5*100+90+4)*1000000+(2*100+70+8)*1000+(40+5)
function NumberParser() {
  var state = NaN, sign = 1;

  function update(s) {
    if(s<0) sign = -sign;
    else if(state===NaN) state = s;
    else if(s % 100===0) state *= s;

  };
  function parse(a) {
    var d = isDigit(a), n = isName(a);
    if(!d && !n) processState();
    if(a.startsWith('-')) { sign = -sign; a = a.substr(1); }
    var s = d? parseFloat(a):NAMES.get(a);

  };
  return {parse};
};
