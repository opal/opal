if (typeof opal === 'undefined') {
  opal = {}
}
/**
  All dev tools go into the opal.dev namespace.
  Dp name is for minimizing.
*/
var Dp = opal.dev = {};

// $runtime.require('dev/string_scanner');
// $runtime.require('dev/ruby_parser');
// $runtime.require('dev/parser');
// $runtime.require('dev/nodes');

Dp.parse = opal.compile = function(source, options) {
  var parser = new Dp.RubyParser();
  var nodes = parser.parse(source);
  var res = nodes.generateTop();
  return res;
};

function runRubyContent(source, options) {
  if (!options) options = {};
  if (!options.filename) options.filename = '(script-tag)';
  var js = Dp.parse(source, options);
  console.log(js);
  var exec = new Function('$runtime', 'self', '__FILE__', js);
  exec(opal.runtime, opal.runtime.top, options.filename);
};

/**
  Load the ruby code at the remote url, parse and run it. This is typically
  used when loading a script tag of type text/ruby. The filename given in the
  tag is used as the actual filename

  @param {String} filename
*/
function runRemoteContent(filename) {
  var xhr;

  if (window.ActiveXObject)
    xhr = new window.ActiveXObject('Microsoft.XMLHTTP');
  else
    xhr = new XMLHttpRequest();

  xhr.open('GET', filename, true);
  xhr.onreadystatechange = function() {
    if (xhr.readyState == 4) {
      if (xhr.status == 0 || xhr.status == 200)
        runRubyContent(xhr.responseText, { filename: filename });
      else
        throw new Error("LoadError: Cannot load: " + filename);
    }
  };
  xhr.send(null);
};

function runScriptTags() {
  var scripts = document.getElementsByTagName('script');
  for (var i = 0, ii = scripts.length; i < ii; i++) {
    var script = scripts[i];

    if (script.type == 'text/ruby') {
      if (script.src) {
        runRemoteContent(script.src);
      } else {
        runRubyContent(script.innerHTML, { filename: '(script-tag)'});
      }
    }
  }
};

if (typeof window !== 'undefined') {
  if (window.addEventListener) {
    window.addEventListener('DOMContentLoaded', runScriptTags, false);
  } else {
    window.attachEvent('onload', runScriptTags);
  }
}

