require 'opal/ruby/parser'

module Opal

  def self.compile(source)
    res = Opal::RubyParser.new(source).parse!.generate_top #:debug => true
    res
  end

  def self.run_ruby_content(source, filename = "(opal)")
    js = compile source
    puts js
    `var exec = new Function('$runtime', 'self', '__FILE__', js);
    exec($runtime, $runtime.top, filename);`
    nil
  end

  # Load the ruby code at the remote url, parse and run it. This is typically
  # used when loading a script tag of type text/ruby. The filename given in the
  # tag is used as the actual filename
  #
  # @param [String] filename
  def self.run_remote_content(filename)
    `var xhr;

    if (window.ActiveXObject)
      xhr = new window.ActiveXObject('Microsoft.XMLHTTP');
    else
      xhr = new XMLHttpRequest();

    xhr.open('GET', filename, true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        if (xhr.status == 0 || xhr.status == 200) {
          #{ run_ruby_content `xhr.responseText`, filename };
        } else {
          #{ raise "LoadError: Cannot load: #{filename}" };
        }
      }
    };
    xhr.send(null);`
    nil
  end

  def self.run_script_tags
    `var scripts = document.getElementsByTagName('script');

    for (var i = 0, ii = scripts.length; i < ii; i++) {
      var script = scripts[i];

      if (script.type == "text/ruby") {
        if (script.src) {
          #{ run_remote_content `script.src` };
        } else {
          #{ run_ruby_content `script.innerHTML`, "(script-tag)" };
        }
      }
    }`

    nil
  end
end

`opal.compile = function(source, options) {
  console.log("need to compile some code");
  return #{ Opal.compile `source` };
};`

`if (typeof window !== 'undefined') {
  var runner = function() { #{ Opal.run_script_tags }; };

  if (window.addEventListener) {
    window.addEventListener('DOMContentLoaded', runner, false);
  } else {
    window.attachEvent('onload', runner);
  }
}`

