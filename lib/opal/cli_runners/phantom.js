var page   = require('webpage').create();
var fs     = require('fs');
var system = require('system');

page.onConsoleMessage = function(msg) {
  system.stdout.write(msg);
};

var opal_code = fs.read('/dev/stdin');

page.onCallback = function(data) {
  switch (data[0]) {
  case 'exit':
    var status = data[1] || 0;
    phantom.exit(status);
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
