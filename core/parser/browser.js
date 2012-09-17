(function() {
  // quick exit if not insde browser
  if (typeof(window) === 'undefined' || typeof(document) === 'undefined') {
    return;
  }

  function findRubyScripts() {
    var all = document.getElementsByTagName('script');
    for (var i = 0, script; i < all.length; i++) {
      script = all[i];
      if (script.type === 'text/ruby') {
        if (script.src) {
          request(script.src, function(result) {
            runRuby(result);
          });
        }
        else {
          runRuby(script.innerHTML);
        }
      }
      else if (script.type === 'text/erb') {
        runERB(script.innerHTML);
      }
    }
  }

  function runRuby(source) {
    var js = Opal.Opal.Parser.$new().$parse(source);
    eval('(' + js + ')()');
  }

  function request(url, callback) {
    var xhr = new (window.ActiveXObject || XMLHttpRequest)('Microsoft.XMLHTTP');
    xhr.open('GET', url, true);
    if ('overrideMimeType' in xhr) {
      xhr.overrideMimeType('text/plain');
    }
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        if (xhr.status === 0 || xhr.status === 200) {
          callback(xhr.responseText);
        }
        else {
          throw new Error('Could not load ruby at: ' + url);
        }
      }
    };
    xhr.send(null);
  }

  if (window.addEventListener) {
    window.addEventListener('DOMContentLoaded', findRubyScripts, false);
  }
  else {
    window.attachEvent('onload', findRubyScripts);
  }
})();