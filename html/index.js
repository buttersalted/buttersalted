// global variables
const Editor = ace.edit('sql-value');
const Header = document.querySelector('header');
const Navs = document.querySelectorAll('nav li > a');
const Forms = document.querySelectorAll('main > form');
const Sql = document.querySelector('#sql');
const Thead = document.querySelector('#ans thead');
const Tbody = document.querySelector('#ans tbody');

const ansRender = function(ans) {
  // 1. set table head from data columns
  m.render(Thead, m('tr', Object.keys(ans[0]).map((k) => m('th', k))));
  // 2. set table body from data rows
  m.render(Tbody, ans.map((r) => m('tr', Object.values(r).map((v) => m('td', v)))));
};

const ansEmpty = function() {
  // 1. clear table
  m.render(Thead, null);
  m.render(Tbody, null);
  // 2. show toast message
  iziToast.info({'title': 'Empty Query', 'message': 'no values returned'});
};

const ansError = function(err) {
  // 1. clear table
  m.render(Thead, null);
  m.render(Tbody, null);
  // 2. show toast message
  iziToast.error({'title': 'Query Error', 'message': err.message});
};

const setupPage = function() {
  // 1. get url path, and prefix
  url = location.href;
  url = url.replace(location.origin, '').replace(/\/#?\!?\/?/, '');
  url = url.startsWith('/')? url.substring(1) : url;
  const pre = url.split('/')[0]||'sql';
  console.log('pre', pre);
  // 2. update navigation menu
  for(var i=0, I=Navs.length; i<I; i++) {
    var id = Navs[i].textContent.toLowerCase();
    if(id===pre) Navs[i].setAttribute('active', '');
    else Navs[i].removeAttribute('active');
  }
  // 3. update main view
  for(var i=0, I=Forms.length; i<I; i++) {
    if(Forms[i].id===pre) Forms[i].hidden = false;
    else Forms[i].hidden = true;
  }
};

const setup = function() {
  // 1. enable form multi submit
  const submit = document.querySelectorAll('form [type=submit]');
  for(var i=0, I=submit.length; i<I; i++)
    submit[i].onclick = () => this.form.submitted = this.name;
  // 2. setup ace editor
  Editor.setTheme('ace/theme/sqlserver');
  Editor.getSession().setMode('ace/mode/pgsql');
  // 3. setup sql interface
  Sql.onsubmit = function() {
    const value = Editor.getValue();
    m.request({'method': 'GET', 'url': `/sql/${value}`}).then((ans) => {
      if(ans.length) ansRender(ans);
      else ansEmpty();
    }, ansError);
    return false;
  };
  // 4. setup page
  window.addEventListener('hashchange', setupPage);
  setupPage();
};

setup();
