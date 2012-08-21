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
        runRuby(script.innerHTML);
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

  if (window.addEventListener) {
    window.addEventListener('DOMContentLoaded', findRubyScripts, false);
  }
  else {
    window.attachEvent('onload', findRubyScripts);
  }
})();