document.querySelector('#sql').onsubmit = function() {
  console.log(this);
  return false;
};

m.request({'method': 'GET', 'url': '/json/type'}).then((ans) => {
  const thead = document.querySelector('thead');
  m.render(thead, m('tr', ans.map((a) => m('th', a.id))));
});
m.request({'method': 'GET', 'url': '/json/food'}).then((ans) => {
  const tbody = document.querySelector('tbody');
  m.render(tbody, ans.map((a) => m('tr', Object.keys(a).map((k) => m('td', a[k])))));
});
