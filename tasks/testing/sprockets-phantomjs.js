/*
 * Test runner for phantomjs
 */
var system = require('system');
var args = phantom.args ? phantom.args : system.args.slice(1);
var page = require('webpage').create();
var url  = args[0];


/*
 * Exit phantom instance "safely" see - https://github.com/ariya/phantomjs/issues/12697
 * https://github.com/nobuoka/gulp-qunit/commit/d242aff9b79de7543d956e294b2ee36eda4bac6c
 */
function phantom_exit(code) {
  page.close();
  setTimeout(function () { phantom.exit(code); }, 0);
}

page.onConsoleMessage = function(msg) {
  console.log(msg);
};

page.onInitialized = function() {
  page.evaluate(function () {
    window.OPAL_SPEC_PHANTOM = true;
  });
};

page.onCallback = function(data) {
  switch (data[0]) {
  case 'exit':
    var status = data[1] || 0;
    phantom_exit(status);
  case 'stdout':
    system.stdout.write(data[1] || '');
    break;
  case 'stderr':
    system.stderr.write(data[1] || '');
    break;
  case 'env':
    return JSON.stringify(system.env);
  case 'argv':
    return JSON.stringify(system.args.slice(1));
  default:
    console.error('Unknown callback data: ', data);
  }
};

page.open(url, function(status) {
  if (status !== 'success') {
    console.error("Cannot load: " + url);
    phantom_exit(1);
  }
});
