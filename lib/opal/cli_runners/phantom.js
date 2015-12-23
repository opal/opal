var page   = require('webpage').create();
var fs     = require('fs');
var system = require('system');

page.onConsoleMessage = function(msg) {
  system.stdout.write(msg);
};

var opal_code = fs.read('/dev/stdin');

/*
 * Exit phantom instance "safely" see - https://github.com/ariya/phantomjs/issues/12697
 * https://github.com/nobuoka/gulp-qunit/commit/d242aff9b79de7543d956e294b2ee36eda4bac6c
 */
function phantom_exit(code) {
  page.close();
  setTimeout(function () { phantom.exit(code); }, 0);
}

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
  default:
    console.error('Unknown callback data: ', data);
  }
};

page.onError = function(msg, trace) {
  trace = (trace && trace.length) ? trace : [];

  var format_trace = function(trace) {
    var file = trace.file || trace.sourceURL,
        line = trace.line,
        method = trace['function'];
    method = method ? "`"+method+"'" : '~unknown~';
    return file+': '+line+':in '+method;
  };

  var msgStack = [format_trace(trace[0])+': '+msg];

  trace.slice(1).forEach(function(t) {
    msgStack.push("	from "+format_trace(t));
  });

  system.stderr.write(msgStack.join('\n')+'\n');
  phantom_exit(1);
};

page.onInitialized = function() {
  page.evaluate('function(code) {window.eval(code)}', opal_code)
};

page.setContent("<!doctype html>\n"+
                "<html>"+
                "<head><meta charset='utf-8'/></head><body>"+
                "</body></html>",
                'http://www.example.com');

