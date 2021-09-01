# use_strict: true
# frozen_string_literal: true

# parser uses String#unpack
require 'corelib/string/unpack'

require 'opal/compiler'
require 'opal/erb'
require 'opal/version'

module Kernel
  def eval(str, binding = nil, file = nil, line = nil)
    str = Opal.coerce_to!(str, String, :to_str)
    default_eval_options = { file: file || '(eval)', eval: true }
    compiling_options = __OPAL_COMPILER_CONFIG__.merge(default_eval_options)
    code = `Opal.compile(str, compiling_options)`
    if binding
      binding.js_eval(code)
    else
      %x{
        return (function(self) {
          return eval(#{code});
        })(self)
      }
    end
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
    try {
      str = #{Opal.coerce_to!(`str`, String, :to_str)}
      if (options) options = Opal.hash(options);
      return Opal.Opal.$compile(str, options);
    }
    catch (e) {
      if (e.$$class === Opal.Opal.SyntaxError) {
        var err = Opal.SyntaxError.$new(e.message);
        err.$set_backtrace(e.$backtrace());
        throw(err);
      }
      else { throw e; }
    }
  };

  Opal['eval'] = function(str, options) {
   return eval(Opal.compile(str, options));
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
