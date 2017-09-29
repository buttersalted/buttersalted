const dosubmit = function() {
  this.form.submitted = this.value;
};
for(var e of document.querySelectorAll('form [type=submit]'))
  e.onclick = dosubmit;

const onrequest = function(ans) {
  console.log(ans);
  const thead = document.querySelector('thead');
  const tbody = document.querySelector('tbody');
  if(!(ans instanceof Array)) return m.render(thead, m('tr', m('th', ans)));
  m.render(thead, m('tr', Object.keys(ans[0]).map((k) => m('th', k))));
  m.render(tbody, ans.map((r) => m('tr', Object.values(r).map((v) => m('td', v)))));
};

document.querySelector('form').onsubmit = function() {
  const submit = this.submitted;
  const data = {'id': this.elements.id.value, 'value': this.elements.value.value};
  if(submit==='select') m.request({'method': 'GET', 'url': '/json/type', 'data': data}).then(onrequest);
  else if(submit==='insert') m.request({'method': 'POST', 'url': '/json/type', 'data': data}).then(onrequest);
  else if(submit==='upsert') m.request({'method': 'PATCH', 'url': `/json/type/${data.id}`, 'data': data}).then(onrequest);
  else if(submit==='delete') m.request({'method': 'DELETE', 'url': `/json/type/${data.id}`}).then(onrequest);
  return false;
};
