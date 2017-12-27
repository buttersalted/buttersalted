var NlpNumber = require('./number');

var str = 'twenty crore crore .';
var nlp = new NlpNumber();
for(var t of str.split(' '))
  console.log(nlp.parse(t));
