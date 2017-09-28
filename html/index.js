m.request({'method': 'GET', 'url': '/json/type'}).then((ans) => {
  m.render(document.querySelector('thead'), ans.map((a) => m('th', a.id)));
});
