// global variables
const Html = document.querySelector('html');
const Editor = ace.edit('sql-value');
const Header = document.querySelector('header');
const Navs = document.querySelectorAll('nav li > a');
const Sections = document.querySelectorAll('section');
const Sql = document.querySelector('#sql');
const Thead = document.querySelector('#ans thead');
const Tbody = document.querySelector('#ans tbody');

const stringBefore = function(str, sep) {
  const i = str.search(sep);
  return i>=0? str.substring(0, i) : str;
};

const stringAfter = function(str, sep) {
  const i = str.search(sep);
  return i>=0? str.substring(i+1) : str;
};

const dequery = function (a) {
  if(a.indexOf('?') > -1) a = a.split('?')[1];
  var kvs = a.split('&');
  var z = {};
  kvs.forEach((pair) => {
    pair = pair.split('=');
    z[pair[0]] = decodeURIComponent(pair[1]||'');
  });
  return z;
}

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

const setupSql = function() {
  const qry = url.split('?')[1]||'';

};

const setupPage = function(e) {
  // 1. get path, prefix, and query
  const path = stringAfter(location.hash.replace(/\/#?\!?\/?/, ''), '/');
  const pre = stringBefore(path, /[\/\?]/).toLowerCase()||'sql';
  const sqry = stringAfter(path, /\?/)||'';
  const qry = sqry? dequery(sqry) : {};
  // 2. update html class list (updates ui)
  Html.classList.value = pre;
  if(sqry) Html.classList.add('query');
  if(e) return;
  // 3. submit form if just loaded
  if(pre==='sql') Editor.setValue(qry.value||'');
  if(sqry) document.querySelector(`#${pre} form`).submit();
};

const formSql = function() {
  Html.classList.add('query');
  const value = Editor.getValue();
  location.hash = `#!/?value=${value}`;
  m.request({'method': 'GET', 'url': `/sql/${value}`}).then((ans) => {
    if(ans.length) ansRender(ans);
    else ansEmpty();
  }, ansError);
  return false;
};

const setup = function() {
  // 1. enable form multi submit
  const submit = document.querySelectorAll('form [type=submit]');
  for(var i=0, I=submit.length; i<I; i++)
    submit[i].onclick = function() { this.form.submitted = this.name; };
  // 2. setup ace editor
  Editor.setTheme('ace/theme/sqlserver');
  Editor.getSession().setMode('ace/mode/pgsql');
  // 3. setup sql interface
  Sql.onsubmit = formSql;
  // 4. setup page
  window.addEventListener('hashchange', setupPage);
  setupPage();
};

setup();
