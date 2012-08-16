<div class="row-fluid" id="wrapper">
  <div id="editor_wrapper" class="span6">
    <div id="editor"></div>
    <br />
    <a href="#" id="run_code" class="btn btn-primary">Compile</a>
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

    if (run.addEventListener) {
      run.addEventListener('click', compile, false);
    }
    else {
      run.attachEvent('onclick', compile);
    }
    // Initialize
    editor.setValue("[1, 2, 3, 4].each do |a|\n  puts a\nend\n\nclass Foo\n  attr_reader :name\nend\n\nadam = Foo.new\nadam.name = 'Adam Beynon'\nputs adam.name");
    // Functions to update editor and viewer content
    function compile() {
      try {
        viewer.setValue(Opal.Opal.Parser.$new().$parse(editor.getValue()));
      }
      catch (err) { 
      }
      return false;
    }
</script>
