<div class="row-fluid" id="wrapper">
  <div id="editor_wrapper" class="span6">
    <div id="editor"></div>
    <br />
    <a href="#" id="run_code" class="btn btn-primary">Run</a>
    <a href="#" id="link_code" class="btn">Link</a>
  </div>

  <div id="viewer_wrapper" class="span6">
    <div id="viewer"></div>
  </div>
</div>

<script src="/javascripts/codemirror.js"></script>
<script src="/javascripts/ruby.js"></script>
<script src="/javascripts/javascript.js"></script>
<link href="/stylesheets/codemirror.css" rel="stylesheet">
<script src="/opal.js"></script>
<script src="/opal-parser.js"></script>

<script>
  var viewer = CodeMirror(document.getElementById("viewer"), {
      lineNumbers: true,
      mode: "javascript",
      readOnly: true
    });
    var editor = CodeMirror(document.getElementById("editor"), {
      lineNumbers: true,
      mode: "ruby",
      tabMode: "shift"
    });

    var run = document.getElementById('run_code');
    var link = document.getElementById('link_code');

    if (run.addEventListener) {
      run.addEventListener('click', compile, false);
    }
    else {
      run.attachEvent('onclick', compile);
    }

    // Functions to update editor and viewer content
    function compile() {
      var old_puts = Opal.puts;
      var output   = [];
      Opal.puts = function(a) {
        output.push(a);
        viewer.setValue(output.join("\n"));
      };

      viewer.setValue('');

      try {
        var code = Opal.Opal.Parser.$new().$parse(editor.getValue());
        eval('(' + code + ')()');
        // viewer.setValue(Opal.Opal.Parser.$new().$parse(editor.getValue()));
      }
      catch (err) { 
        Opal.puts('' + err + "\n" + err.stack);
      }

      Opal.puts = old_puts;
      link.href = '#code:' + encodeURIComponent(editor.getValue());
      return false;
    }

    var hash = decodeURIComponent(location.hash);
    if (hash.indexOf('#code:') === 0) {
      editor.setValue(hash.substr(6));
    }
    else {
      editor.setValue("[1, 2, 3, 4].each do |a|\n  puts a\nend\n\nclass Foo\n  attr_accessor :name\nend\n\nadam = Foo.new\nadam.name = 'Adam Beynon'\nputs adam.name");
    }

    compile();
</script>