require 'opal/compiler'
require 'opal/builder'
require 'opal/erb'
require 'opal/version'

module Kernel
  def eval(str)
    code = Opal.compile str
    `eval(#{code})`
  end
end

%x{
  Opal.compile = function(str, options) {
    if (options) {
      options = Opal.hash(options);
    }
    return Opal.Opal.$compile(str, options);
  };

  Opal.eval = function(str, options) {
   return eval(Opal.compile(str, options));
  };

  function run_ruby_scripts() {
    var tags = document.getElementsByTagName('script');

    for (var i = 0, len = tags.length; i < len; i++) {
      if (tags[i].type === "text/ruby") {
        Opal.eval(tags[i].innerHTML);
      }
    }
  }

  if (typeof(document) !== 'undefined') {
    if (window.addEventListener) {
      window.addEventListener('DOMContentLoaded', run_ruby_scripts, false);
    }
    else {
      window.attachEvent('onload', run_ruby_scripts);
    }
  }
}
