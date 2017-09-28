const dosubmit = function() {
  this.form[this.name].value = this.value;
};
for(var e of document.querySelectorAll('form [type=submit]'))
  e.onclick = dosubmit;

document.querySelector('form').onsubmit = function() {
  console.log(this.elements.http.value);
  return false;
};
