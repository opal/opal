# helpers: call, raise
# backtick_javascript: true

# parser uses String#unpack
require 'corelib/string/unpack'

require 'opal/compiler'
require 'opal/erb'
require 'opal/version'

module Kernel
  def eval(str, binding = nil, file = nil, line = nil)
    str = ::Opal.coerce_to!(str, String, :to_str)
    default_eval_options = { file: file || '(eval)', eval: true }
    compiling_options = __OPAL_COMPILER_CONFIG__.merge(default_eval_options)
    compiler = Opal::Compiler.new(str, compiling_options)
    code = compiler.compile
    code += compiler.source_map.to_data_uri_comment unless compiling_options[:no_source_map]
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
  var $has_own = Object.hasOwn || $call.bind(Object.prototype.hasOwnProperty);

  Opal.hash = function() {
    var arguments_length = arguments.length, args, hash, i, length, key, value;

    if (arguments_length === 1 && arguments[0].$$is_hash) {
      return arguments[0];
    }

    hash = new Map();

    if (arguments_length === 1) {
      args = arguments[0];

      if (arguments[0].$$is_array) {
        length = args.length;

        for (i = 0; i < length; i++) {
          if (args[i].length !== 2) {
            $raise(Opal.ArgumentError, "value not of length 2: " + args[i].$inspect());
          }

          key = args[i][0];
          value = args[i][1];

          Opal.hash_put(hash, key, value);
        }

        return hash;
      }
      else {
        args = arguments[0];
        for (key in args) {
          if ($has_own(args, key)) {
            value = args[key];

            Opal.hash_put(hash, key, value);
          }
        }

        return hash;
      }
    }

    if (arguments_length % 2 !== 0) {
      $raise(Opal.ArgumentError, "odd number of arguments for Hash");
    }

    for (i = 0; i < arguments_length; i += 2) {
      key = arguments[i];
      value = arguments[i + 1];

      Opal.hash_put(hash, key, value);
    }

    return hash;
  };

  Opal.compile = function(str, options) {
    try {
      str = #{::Opal.coerce_to!(`str`, String, :to_str)}
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
