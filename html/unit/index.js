const render = function(ans) {
  const tbody = document.querySelector('#unitans tbody');
  if(ans instanceof Array && ans.length) {
    m.render(thead, m('tr', Object.keys(ans[0]).map((k) => m('th', k))));
    m.render(tbody, ans.map((r) => m('tr', Object.values(r).map((v) => m('td', v)))));
  }
  else {
    if(ans instanceof Error) m.render(thead, m('tr', m('th', ans.message)));
    else m.render(thead, m('tr', m('th', 'no results.')));
    m.render(tbody, null);
  }
};

const onready = function() {
  // 1. setup form usage
  const unit = document.getElementById('unit')
  unit.onsubmit = function() {
    const id = this.elements.id.value;
    const value = this.elements.value.value;
    const data = {'id': id, 'value': value};
    m.request({'method': 'GET', 'url': '/json/unit', 'data': data}).then(render, render);
  };
};

onready();
