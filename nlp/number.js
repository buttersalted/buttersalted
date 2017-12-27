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
  ['minus', -1],
  ['negative', -1]
]);

function is(a) {
  if(a.search(/^[\d\-\.]/)===0) return true;
  for(var k of NAMES.keys())
    if(a.startsWith(k)) return true;
  return false;
};
