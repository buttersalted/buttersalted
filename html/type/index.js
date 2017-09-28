const dosubmit = function() {
  this.form[this.name].value = this.value;
};
for(var e in document.querySelectorAll('form [type=submit]'))
  e.onclick = dosubmit;

document.querySelector('form').onsubmit = function() {
  console.log(this.submitted);
  return false;
};
