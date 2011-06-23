require 'opal/ruby/parser'

module Opal

  def self.compile(source)
    res = Opal::RubyParser.new(source).parse!.generate_top :debug => true
    res
  end

  def self.run_ruby_content(source, filename = "(opal)")
    js = compile source
    `var exec = new Function('$rb', 'self', '__FILE__', js);
    return exec($rb, $rb.top, filename);`
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

`var repl_running = false;

opal.browser_repl = function() {
  if (repl_running) return;
  repl_running = true;

  var html = '<div id="opal-repl" style="position: fixed; width: 100%; height: '
           +     '230px; bottom: 0px; overflow: scroll; border-top: 4px solid'
           +     '#A5A5A5; left: 0px; padding: 4px; background-color: #E5E5E5;">'

           +   '<div id="opal-stdout" style="font-family: \'Bitstream Vera Sans'
           +       'Mono\', \'Courier\', monospace; font-size: 12px"></div>'

           +   '<span style="float: left; display: block; font-family: \'Bitst'
           +       'ream Vera Sans Mono\', \'Courier\', monospace; font-size: '
           +       '12px">&gt;&gt;&nbsp;</span>'

           +   '<input id="opal-stdin" type="text" style="position: relative;'
           +       'float: left; right: 0px; width: 500px; font-family: \'Bit'
           +       'stream Vera Sans Mono\', \'Courier\', monospace;'
           +       'font-size: 12px; outline-width: 0; outline: none; border:'
           +       '0px; padding: 0px; margin: 0px; background: none" />'

           + '</div>';

  var host = document.createElement('div');
  host.innerHTML = html;
  document.body.appendChild(host);
  var opal_repl = document.getElementById('opal-repl');

  var stdout = document.getElementById('opal-stdout');
  var stdin = document.getElementById('opal-stdin');
  var history = [], history_idx = 0;
  setTimeout(function() { stdin.focus(); }, 0);

  var puts_content = function(str) {
    var elem = document.createElement('div');
    elem.textContent == null ? elem.innerText = str : elem.textContent = str;
    stdout.appendChild(elem);
  };

  var stdin_keydown = function(evt) {
    if (evt.keyCode == 13) {
      var ruby = stdin.value;

      history.push(stdin.value);
      history_idx = history.length;
      stdin.value = '';
      puts_content(">> " + ruby);

      try {
        puts_content("=> " + #{Opal.run_ruby_content(`ruby`, '(irb)').inspect}.toString());
      }
      catch (err) {
        // if (err.stack) puts_content(err.stack);
        //else puts_content("=> " + err.message);
        puts_content("=> " + err.message);
      }

      opal_repl.scrollTop = opal_repl.scrollHeight;
    }
    else if (evt.keyCode == 38) {
      if (history_idx > 0) {
        history_idx -= 1;
        stdin.value = history[history_idx];
      }
    }
    else if (evt.keyCode == 40) {
      if (history_idx < history.length - 1) {
        history_idx += 1;
        stdin.value = history[history_idx];
      }
    }
  };

  if (stdin.addEventListener) {
    stdin.addEventListener('keydown', stdin_keydown, false);
  } else {
    stdin.attachEvent('onkeydown', stdin_keydown);
  }

  #{
  def $stdout.puts(*a)
    `for (var i = 0, ii = a.length; i < ii; i ++) {
      puts_content(#{`a[i]`.to_s}.toString());
    }`
    nil
  end
  };

  puts_content("opal REPL! Type command then <enter>.");
};`

