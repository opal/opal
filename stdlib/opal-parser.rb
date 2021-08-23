# parser uses String#unpack
require 'corelib/string/unpack'

require 'opal/compiler'
require 'opal/erb'
require 'opal/version'

module Kernel
  def eval(str)
    str = Opal.coerce_to!(str, String, :to_str)
    default_eval_options = { file: '(eval)', eval: true }
    compiling_options = __OPAL_COMPILER_CONFIG__.merge(default_eval_options)
    code = Opal.compile str, compiling_options
    %x{
      return (
        Function(
          "return function(self) { return (" + #{code} + "); }"
        )()(self)
      )
    }
  end

  def require_remote(url)
    %x{
      var r = new XMLHttpRequest();
      r.open("GET", url, false);
      r.send('');
    }
    eval `r.responseText`
  end
end

%x{
  Opal.compile = function(str, options) {
    if (options) {
      options = Opal.hash(options);
    }
    return Opal.Opal.$compile(str, options);
  };

  Opal['eval'] = function(str, options) {
    return Function(Opal.compile(str, options))();
  };

  function run_ruby_scripts() {
    var tag, tags = document.getElementsByTagName('script');

    for (var i = 0, len = tags.length; i < len; i++) {
      tag = tags[i];
      if (tag.type === "text/ruby") {
        if (tag.src)       Opal.Kernel.$require_remote(tag.src);
        if (tag.innerHTML) Opal.Kernel.$eval(tag.innerHTML);
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
