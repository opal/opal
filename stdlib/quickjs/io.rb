`/* global std */`

%x{
  Opal.gvars.stdout.write_proc = function(s) {
    std.out.printf("%s", s);
    std.out.flush();
  }

  Opal.gvars.stderr.write_proc = function(s) {
    std.err.printf("%s", s);
    std.err.flush();
  }

  Opal.gvars.stdin.read_proc = function(s) {
    if (std.in.eof()) {
      return nil;
    }
    else {
      return std.in.readAsString(s);
    }
  }
}
