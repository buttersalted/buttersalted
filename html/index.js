document.querySelector('#sql').onsubmit = function() {
  const value = this.elements.value;
  const thead = document.querySelector('thead');
  const tbody = document.querySelector('tbody');
  m.request({'method': 'GET', 'url': '/json/type'}).then((ans) => {
    if(!ans.length) return;
    const cols = Object.keys(ans[0]);
    m.render(thead, m('tr', cols.map((k) => m('th', k))));
    m.render(tbody, ans.map((r) => m('tr', Object.values(r).map((v) => m('td', v)))));
  });
  return false;
};
