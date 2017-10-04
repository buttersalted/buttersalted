// 1. define global variables
var Html = document.querySelector('html');
var Editor = ace.edit('sql-value');
var Header = document.querySelector('header');
var Navs = document.querySelectorAll('nav li > a');
var Sections = document.querySelectorAll('section');
var Thead = document.querySelector('#ans thead');
var Tbody = document.querySelector('#ans tbody');
var Types = document.querySelector('#types');
var FoodInputs = document.querySelector('#food form .inputs');
var Forms = {
  'sql': document.querySelector('#sql form'),
  'pipe': document.querySelector('#pipe form'),
  'food': document.querySelector('#food form'),
  'group': document.querySelector('#group form'),
  'term': document.querySelector('#term form'),
  'type': document.querySelector('#type form'),
  'unit': document.querySelector('#unit form')
};

var objTruthy = function(a) {
  // 1. get object with only truthy values
  var z = {};
  for(var k in a)
    if(a[k]) z[k] = a[k];
  return z;
};

var locationSet = function(hsh) {
  // 1. replace temp handler only if hash changed
  var fn = window.onhashchange;
  if(hsh!==location.hash) window.onhashchange = function() {
    window.onhashchange = fn;
  };
  // 2. update location
  location.href = location.origin+'/'+hsh;
};

var ajaxReq = function(mth, url, dat) {
  // 1. make an ajax request
  return m.request({'method': mth, 'url': url, 'data': dat});
};

var ansRender = function(ans) {
  console.log('ansRender');
  // 1. set table head, body from data
  var zk = [], zv = [];
  for(var k in ans[0])
    zk.push(m('th', k));
  for(var r=0, rv=[], R=ans.length; r<R; r++) {
    for(var c in ans[r])
      rv.push(m('td', ans[r][c]));
    zv.push(m('tr', rv));
  }
  m.render(Thead, ans.length? m('tr', zk) : null);
  m.render(Tbody, ans.length? zv : null);
  // 2. show toast message (if empty)
  if(!ans.length) iziToast.warning({'title': 'Empty Query', 'message': 'no values returned'});
};

var ansError = function(err) {
  console.log('ansError');
  // 1. clear table
  m.render(Thead, null);
  m.render(Tbody, null);
  // 2. show toast message
  iziToast.error({'title': 'Query Error', 'message': err.message});
};

var actRender = function(ans) {
  console.log('actRender');
  // 1. show toast message
  iziToast.info({'title': 'Action successful', 'message': ans});
};

var actError = function(err) {
  console.log('actError');
  // 1. show toast message
  iziToast.error({'title': 'Action failed', 'message': err.message});
};

var formGet = function(frm) {
  // 1. set object from form elements
  var E = frm.elements, z = {};
  for(var i=0, I=E.length; i<I; i++)
    if(E[i].name) z[E[i].name] = E[i].value;
  return z;
};

var formSet = function(frm, val) {
  // 1. set form elements from object
  var E = frm.elements;
  for(var i=0, I=E.length; i<I; i++)
    if(E[i].name && val[E[i].name]) E[i].value = val[E[i].name];
  return frm;
};

var inpKv = function(e, key, val, katt, vatt) {
  // 1. setup component (empty, yet need to refer it)
  var comp = {};
  // 2. this handles key change
  var onkey = function() {
    // a. get new key
    var k = this.value;
    // b. created if filled, delete if emptied
    if(k && !key) e.create(comp);
    if(!k && key) e.delete(comp);
    // c. update key
    key = k;
  };
  // 3. this handles value change
  var onval = function() {
    // a. update value
    val = this.value;
  };
  // 4. return component
  return Object.assign(comp, {'view': function() { return m('fieldset', [
    m('input', Object.assign({'value': key, 'onchange': onkey}, katt)),
    m('input', Object.assign({'name': key, 'value': val, 'onchange': onval}, vatt))
  ]); }});
};

var formKv = function(el, katt, vatt, val) {
  console.log('formKv');
  // 1. define components
  var Comps = new Set();
  // 2. handle create and delete of components
  var e = {
    'create': function(c) { Comps.add(inpKv(e, '', '', katt, vatt)); },
    'delete': function(c) { Comps.delete(c); }
  };
  // 3. initialize components from input
  val = Object.assign(val||{}, {'': ''});
  for(var k in val)
    Comps.add(inpKv(e, k, val[k], katt, vatt));
  // 4. mount combined component to form
  var z = {
    'view': function() {
      var z = [];
      for(var c of Comps)
        z.push(c.view());
      return z;
    },
    'onreset': function() {
      Comps.clear();
      e.create();
      m.redraw(this);
    }
  };
  m.mount(el, z);
  return z;
};

var formSql = function() {
  console.log('formSql');
  // 1. switch to query mode, and get form data
  Html.classList.add('query');
  var value = Editor.getValue();
  // 2. update location, and make ajax request
  locationSet('#!/?'+m.buildQueryString({'value': value}));
  ajaxReq('GET', '/sql/'+value).then(ansRender, ansError);
  return false;
};

var loopAsync = function(fn, bgn, end) {
  // 1. an asynchronous begin to end loop
  if(bgn<end) fn(bgn).then(function() {
    loopAsync(fn, ++bgn, end);
  });
};

var formPipe = function() {
  console.log('formPipe');
  // 1. switch to query mode, and get form data
  Html.classList.add('query');
  var data = formGet(this), z = [];
  var url = '/pipe/'+data.source+'/';
  var sbt = this.submitted;
  // 2. update location
  locationSet('#!/?'+m.buildQueryString(data));
  // 3. if submit is get, render results (yay async)
  if(sbt==='get') loopAsync(function(i) {
    return ajaxReq('GET', url+i).then(function(ans) {
      z.push(ans);
      ansRender(z);
    });
  }, parseInt(data.start), parseInt(data.stop));
  // 4. if submit is post, render status (yay async again)
  else if(sbt==='post') loopAsync(function(i) {
    return ajaxReq('POST', url+i).then(function(ans) {
      z.push({'id': i, 'status': ans});
      ansRender(z);
    }, function(err) {
      z.push({'id': i, 'status': err.message});
      ansRender(z);
    });
  }, parseInt(data.start), parseInt(data.stop));
  return false;
};

var formJson = function() {
  console.log('formJson');
  // 1. switch to query mode, and get form data
  Html.classList.add('query');
  var data = formGet(this);
  var sbt = this.submitted;
  var tab = this.parentElement.id;
  var id = data.id||data.Id;
  data = tab!=='food'? objTruthy(data) : data;
  // 2. update location, and make ajax request (4 options)
  locationSet('#!/'+tab+'?'+m.buildQueryString(data));
  if(sbt==='select') ajaxReq('GET', '/json/'+tab, data).then(ansRender, ansError);
  else if(sbt==='insert') ajaxReq('POST', '/json/'+tab, data).then(actRender, actError);
  else if(sbt==='update') ajaxReq('PATCH', '/json/'+tab+'/'+id, data).then(actRender, actError);
  else if(sbt==='delete') ajaxReq('DELETE', '/json/'+tab+'/'+id, data).then(actRender, actError);
  return false;
};

var setupPage = function(e) {
  console.log('setupPage');
  // 1. define food key, value attributes
  var katt = {'list': 'types', 'placeholder': 'Column name, like: Id'};
  var vatt = {'type': 'text', 'placeholder': 'Value, like: 1001'};
  // 2. get path, prefix, and query
  var path = location.hash.replace(/#?\!?\/?/, '')
  var pre = path.split(/[\/\?]/)[0].toLowerCase()||'sql';
  var sqry = path.split('?')[1]||'';
  var qry = sqry? m.parseQueryString(sqry) : {};
  // 3. update html class list (updates ui)
  Html.classList.value = pre;
  if(sqry) Html.classList.add('query');
  // 4. prepare forms if just loaded
  if(pre==='sql') Editor.setValue(qry.value||'');
  else if(pre!=='food') formSet(Forms[pre], qry);
  var kv = formKv(FoodInputs, katt, vatt, pre==='food'? qry : {});
  Forms.food.onreset = kv.onreset;
  // 5. submit form if have query
  if(sqry) Forms[pre].onsubmit();
};

var setup = function() {
  console.log('setup');
  // 1. enable form multi submit
  var submit = document.querySelectorAll('form [type=submit]');
  for(var i=0, I=submit.length; i<I; i++)
    submit[i].onclick = function() { this.form.submitted = this.value; };
  // 2. setup types data list
  ajaxReq('GET', '/json/type').then(function(ans) {
    for(var i=0, z=[], I=ans.length; i<I; i++)
      z[i] = m('option', ans[i].id);
    m.render(Types, z);
  });
  // 2. setup ace editor
  Editor.setTheme('ace/theme/sqlserver');
  Editor.getSession().setMode('ace/mode/pgsql');
  Editor.focus();
  // 3. setup sql interface
  for(var k in Forms)
    Forms[k].onsubmit = formJson;
  Forms.sql.onsubmit = formSql;
  Forms.pipe.onsubmit = formPipe;
  // 4. setup page
  window.onhashchange = setupPage;
  setupPage();
};

// 2. begin setup
setup();
