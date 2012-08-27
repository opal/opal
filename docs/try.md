<div class="row-fluid" id="wrapper">
  <div id="editor_wrapper" class="span6">
    <div id="editor"></div>
    <br />
    <a href="#" id="run_code" class="btn btn-primary">Run</a>
    <a href="#" id="link_code" class="btn">Link</a>
  </div>
  <div id="viewer_wrapper" class="span6">
    <div class="tabbable">
      <ul class="nav nav-tabs">
        <li class="active"><a href="#tab1" data-toggle="tab">Output</a></li>
        <li><a href="#tab2" data-toggle="tab">Compiled Javascript</a></li>
      </ul>
      <div class="tab-content">
        <div class="tab-pane active" id="tab1">
          <div id="output">
          </div>
        </div>
        <div class="tab-pane" id="tab2">
          <div id="viewer">
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="/javascripts/codemirror.js"></script>
<script src="/javascripts/ruby.js"></script>
<script src="/javascripts/javascript.js"></script>
<link href="/stylesheets/codemirror.css" rel="stylesheet">

<script src="/javascripts/jquery.js"></script>
<script src="/javascripts/bootstrap.min.js"></script>

<script src="/opal.min.js"></script>
<script src="/opal-parser.min.js"></script>

<script>
  var output = CodeMirror(document.getElementById("output"), {
      lineNumbers: false,
      mode: "javascript",
      readOnly: true
    });

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
    var flush   = [];
    Opal.puts = function(a) {
      flush.push(a);
      output.setValue(flush.join("\n"));
    };

    output.setValue('');

    try {
      var code = Opal.Opal.Parser.$new().$parse(editor.getValue());
      viewer.setValue(code);
      eval('(' + code + ')()');
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