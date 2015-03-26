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

page.content =  '<!doctype html>'+
                '<html>'+
                '  <head><meta charset="utf-8"/></head>'+
                "  <body><script>//<![CDATA[\n"+
                opal_code+
                "  //]]></script>"+
                '  <script>callPhantom(["exit", 0]);</script></body>\n'+
                '  </body>'+
                '</html>';
