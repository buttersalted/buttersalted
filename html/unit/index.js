const ontrclick = function() {

};

const render = function(ans) {
  const tbody = document.querySelector('#unitans tbody');
  m.render(tbody, ans.map((r) => m('tr', {onclick: ontrclick}, Object.values(r).map((v) => m('td', v)))));
};

const errornotify = function(err) {
  iziToast.error({'title': 'Serach Error', 'message': err.message});
};

const onready = function() {
  // 1. setup form usage
  const unit = document.getElementById('unit')
  unit.onsubmit = function() {
    var id = this.elements.id.value;
    var value = this.elements.value.value;
    const data = {'id': id, 'value': value};
    m.request({'method': 'GET', 'url': '/json/unit', 'data': data}).then(render, errornotify);
    return false;
  };
};

onready();
