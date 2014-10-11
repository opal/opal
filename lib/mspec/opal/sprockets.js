/*
 * Test runner for phantomjs
 */
var args = phantom.args;
var page = require('webpage').create();

page.onConsoleMessage = function(msg) {
  console.log(msg);
};

page.onInitialized = function() {
  page.evaluate(function () {
    window.OPAL_SPEC_PHANTOM = true;
  });
};

var system = require('system');
page.onCallback = function(data) {
  switch (data[0]) {
  case 'exit':
    var status = data[1] || 0;
    phantom.exit(status);
  case 'stdout':
    system.stdout.write(data[1] || '');
    break;
  case 'stderr':
    system.stderr.write(data[1] || '');
    break;
  default:
    console.error('Unknown callback data: ', data);
  }
};

page.open(args[0], function(status) {
  if (status !== 'success') {
    console.error("Cannot load: " + args[0]);
    phantom.exit(1);
  } else {
    var timeout = parseInt(args[1] || 60000, 10);
    var start = Date.now();
    var interval = setInterval(function() {
      if (Date.now() > start + timeout) {
        console.error("Specs timed out");
        phantom.exit(124);
      } else {
        var code = page.evaluate(function() {
          return window.OPAL_SPEC_CODE;
        });

        if (code === 0 || code === 1) {
          clearInterval(interval);
          phantom.exit(code);
        }
      }
    }, 500);
  }
});
