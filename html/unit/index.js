const wildcard = function(a) {
  return a.replace(/\*/g, '%').replace(/\?/g, '_');
};

const render = function(ans) {
  const tbody = document.querySelector('#unitans tbody');
  m.render(tbody, ans.map((r) => m('tr', Object.values(r).map((v) => m('td', v)))));
};

const errornotify = function(err) {
  iziToast.error({'title': 'Serach Error', 'message': err.message});
};

const onready = function() {
  // 1. setup form usage
  const unit = document.getElementById('unit')
  unit.onsubmit = function() {
    const id = wildcard(this.elements.id.value||'*');
    const value = wildcard(this.elements.value.value||'*');
    const data = {'id': id, 'value': value};
    m.request({'method': 'GET', 'url': '/json/unit', 'data': data}).then(render, errornotify);
    return false;
  };
};

onready();
