const renderTable = function(ans) {
  const thead = document.querySelector('#sql-ans thead');
  const tbody = document.querySelector('#sql-ans tbody');
  if(ans instanceof Array && ans.length) {
    m.render(thead, m('tr', Object.keys(ans[0]).map((k) => m('th', k))));
    m.render(tbody, ans.map((r) => m('tr', Object.values(r).map((v) => m('td', v)))));
  }
  else {
    if(!(ans instanceof Array)) m.render(thead, m('tr', m('th', ans)));
    else m.render(thead, m('tr', m('th', 'no results.')));
    m.render(tbody, null);
  }
};

const onready = function() {
  // 1. setup sql value editor
  const sqlValue = ace.edit('sql-value');
  sqlValue.setTheme('ace/theme/sqlserver');
  sqlValue.getSession().setMode('ace/mode/pgsql');

  // 2. setup sql get on click
  const sqlGet = document.getElementById('sql-get')
  sqlGet.onclick = function() {
    const value = sqlValue.getValue();
    m.request({'method': 'GET', 'url': `/sql/${value}`}).then(renderTable, renderTable);
  };
};

onready();
