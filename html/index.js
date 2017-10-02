// global variables
const Html = document.querySelector('html');
const Editor = ace.edit('sql-value');
const Header = document.querySelector('header');
const Navs = document.querySelectorAll('nav li > a');
const Sections = document.querySelectorAll('section');
const Sql = document.querySelector('#sql');
const Thead = document.querySelector('#ans thead');
const Tbody = document.querySelector('#ans tbody');
const Types = document.querySelector('#types');

const stringBefore = function(str, sep) {
  const i = str.search(sep);
  return i>=0? str.substring(0, i) : str;
};

const stringAfter = function(str, sep) {
  const i = str.search(sep);
  return i>=0? str.substring(i+1) : str;
};

const ansRender = function(ans) {
  console.log('ansRender');
  // 1. set table head, body from data
  m.render(Thead, ans.length? m('tr', Object.keys(ans[0]).map((k) => m('th', k))) : null);
  m.render(Tbody, ans.length? ans.map((r) => m('tr', Object.values(r).map((v) => m('td', v)))) : null);
  // 3. show toast message (if empty)
  if(!ans.length) iziToast.info({'title': 'Empty Query', 'message': 'no values returned'});
};

const ansError = function(err) {
  console.log('ansError');
  // 1. clear table
  m.render(Thead, null);
  m.render(Tbody, null);
  // 2. show toast message
  iziToast.error({'title': 'Query Error', 'message': err.message});
};

const setupPage = function(e) {
  console.log('setupPage');
  // 1. get path, prefix, and query
  const path = stringAfter(location.hash.replace(/\/?#?\!?\/?/, ''), '/');
  const pre = stringBefore(path, /[\/\?]/).toLowerCase()||'sql';
  const sqry = path.split('?')[1]||'';
  console.log('sqry', sqry);
  const qry = sqry? dequery(sqry) : {};
  // 2. update html class list (updates ui)
  Html.classList.value = pre;
  if(sqry) Html.classList.add('query');
  if(e) return;
  // 3. submit form if just loaded
  if(pre==='sql') Editor.setValue(qry.value||'');
  if(sqry) document.querySelector(`#${pre} form`).submit();
};

const formGet = function(frm) {
  // 1. set object from form elements
  const E = frm.elements, z = {};
  for(var i=0, I=E.length; i<I; i++)
    if(E[i].name) z[E[i].name] = E[i].value;
  return z;
};

const formSet = function(frm, val) {
  // 1. set form elements from object
  const E = frm.elements;
  for(var i=0, I=E.length; i<I; i++)
    if(E[i].name) E[i].value = val[E[i].name];
  return frm;
};

const formSerialize = function(val) {
  // 1. serialize object as key=value&...
  var z = '';
  for(var k in val)
    z += k+'='+encodeURIComponent(val[k])+'&';
  return z? z.slice(0, -1) : z;
};

const formDeserialize = function(str) {
  // 1. deserialize object from key=value&...
  const z = {};
  for(var kv of str.split('&')) {
    var p = kv.split('=');
    z[p[0]] = decodeURIComponent(p[1]||'');
  }
  return z;
};

const formSql = function() {
  console.log('formSql');
  Html.classList.add('query');
  const value = Editor.getValue();
  location.hash = '#!/?value='+value;
  m.request({'method': 'GET', 'url': '/sql/'+value}).then(ansRender, ansError);
  return false;
};

const formFood = function() {
  console.log('formFood');
  Html.classList.add('query');
  const data = formGet(this);
  location.hash = '#!/food?'+formSerialize(data);
  m.request({'method': 'GET', 'url': '/json/food', 'data': data}).then(ansRender, ansError);
  return false;
};

const formGroup = function() {
  console.log('formGroup');
  Html.classList.add('query');
  const data = formGet(this);
  location.hash = '#!/group?'+formSerialize(data);
  m.request({'method': 'GET', 'url': '/json/group', 'data': data}).then(ansRender, ansError);
  return false;
};

const formTerm = function() {
  console.log('formTerm');
  Html.classList.add('query');
  const data = formGet(this);
  location.hash = '#!/term?'+formSerialize(data);
  m.request({'method': 'GET', 'url': '/json/term', 'data': data}).then(ansRender, ansError);
  return false;
};

const formType = function() {
  console.log('formType');
  Html.classList.add('query');
  const data = formGet(this);
  location.hash = '#!/type?'+formSerialize(data);
  m.request({'method': 'GET', 'url': '/json/type', 'data': data}).then(ansRender, ansError);
  return false;
};

const formUnit = function() {
  console.log('formUnit');
  Html.classList.add('query');
  const data = formGet(this);
  location.hash = '#!/unit?'+formSerialize(data);
  m.request({'method': 'GET', 'url': '/json/unit', 'data': data}).then(ansRender, ansError);
  return false;
};

const setup = function() {
  console.log('setup');
  // 1. enable form multi submit
  const submit = document.querySelectorAll('form [type=submit]');
  for(var i=0, I=submit.length; i<I; i++)
    submit[i].onclick = function() { this.form.submitted = this.name; };
  // 2. setup types data list
  m.request({'method': 'GET', 'url': '/json/type'}).then((ans) => {
    m.render(Types, ans.map((r) => m('option', r.id)));
  });
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
