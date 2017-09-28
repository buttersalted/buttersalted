document.querySelector('form').onsubmit = function() {
  console.log(this.submitted);
  return false;
};
