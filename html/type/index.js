const dosubmit = function() {
  this.form.submitted = this.value;
};
for(var e of document.querySelectorAll('form [type=submit]'))
  e.onclick = dosubmit;

document.querySelector('form').onsubmit = function() {
  console.log(this.submitted);
  return false;
};
