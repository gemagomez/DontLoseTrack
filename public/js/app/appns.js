define(['jquery', 'text!../tmpl/all.templates'], function($, templates) {
  $("body").append(templates);

  App = {};
  return App;
});
