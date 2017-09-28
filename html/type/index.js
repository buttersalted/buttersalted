document.querySelector('form').onsubmit = function() {
  console.log(this.elements.http);
  return false;
};
