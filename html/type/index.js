document.querySelector('form').onsubmit = function() {
  console.log(this.elements.http.value);
  return false;
};
