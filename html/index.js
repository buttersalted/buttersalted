// global variables
const Editor = ace.edit('sql-value');
const Header = document.querySelector('header');
const Navs = document.querySelectorAll('nav li a');
const Divs = document.querySelectorAll('main > div');

const urlSetup = function(url) {
  // 1. get url path (form a full url)
  url = url.replace(location.origin, '');
  url = url.replace('/#!/', '');
  url = url.startsWith('/')? url.substring(1) : url;
  // 2. get path prefix
  const pre = url.split('/')[0];
  // 3. update navigation menu
  for(var i=0, I=Navs.length; i<I; i++) {
    if(Navs[i].id===pre) Navs[i].setAttribute('active', '');
    else Navs[i].removeAttribute('active');
  }
  // 4, update main view
  for(var i=0, I=Divs.length; i<I; i++) {
    if(Divs[i].id===pre) Divs[i].hidden = false;
    else Divs[i].hidden = true;
  }
  // 5.set the location (and live happily ever after)
  location.href = location.origin+(url? '/#!/'+url : '');
};



const renderTable = function(ans) {
  const thead = document.querySelector('#sql-ans thead');
  const tbody = document.querySelector('#sql-ans tbody');
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

const setup = function() {
  // 1. setup ace editor
  Editor.setTheme('ace/theme/sqlserver');
  Editor.getSession().setMode('ace/mode/pgsql');

  /*
  // 2. setup sql get on click
  const sqlGet = document.getElementById('sql-get')
  sqlGet.onclick = function() {
    const value = sqlValue.getValue();
    m.request({'method': 'GET', 'url': `/sql/${value}`}).then(renderTable, renderTable);
  };
  */
  // 2. setup url
  urlSetup(location.href);
};

setup();
