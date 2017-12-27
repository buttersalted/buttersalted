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
  ['infinite', Infinity]
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

function NlpNumber() {
  var state = [], sign = -1;

  function value() {
    var z = 0;
    for(var i=0, I=state.length; i<I; i++)
      z += state[i];
    state.length = 0;
    return z;
  };
  function update(val) {
    console.log(state);
    if(val<100 || state.length===0) return state.push(val);
    for(var i=state.length-2; i>=0 && state[i]<state[i+1]*val; i--)
      state[i] += state.pop();
    state[++i] *= val;
  };
  function parse(str) {
    var d = isDigit(str), n = isName(str);
    if(!d && !n) return state.length>0? value():null;
    if(str.startsWith('-')) { sign = -sign; str = str.substr(1); }
    update(d? parseFloat(str):NAMES.get(str));
    return NaN;
  };

  return {parse};
};
// 20+4+(9*100+40+5)
// (5*100000+(9*100+40+2)*100+70+8)*10000000
// (5*100+90+4)*1000000+(2*100+70+8)*1000+(40+5)

/*
CONCATENATION EXAMPLES:
- two two = 22
- twenty twenty = 2020
- two hundred two hundred = 200200
- two thousand two thousand = 20002000
- two zero two != 22

CONCATENATION INFERENCES:
- done when numbers clash
- zero if given also clash

CONCATENATION CLASH CHECK:
-
*/
module.exports = NlpNumber;
