const dosubmit = function() {
  console.log('name', this.name);
  console.log('value', this.value);
  this.form[this.name].value = this.value;
  console.log('set value', this.form[this.name].value);

};
for(var e of document.querySelectorAll('form [type=submit]'))
  e.onclick = dosubmit;

document.querySelector('form').onsubmit = function() {
  console.log(this.elements.http.value);
  return false;
};
