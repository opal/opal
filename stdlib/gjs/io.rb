`/* global imports */`

# Basic version, appends \n:
# $stdout.write_proc = `function(s){print(s)}`
# $stderr.write_proc = `function(s){printerr(s)}`

# Advanced version:
%x{
  var GLib = imports.gi.GLib;
  var ByteArray = imports.byteArray;

  var stdin = GLib.IOChannel.unix_new(0);
  var stdout = GLib.IOChannel.unix_new(1);
  var stderr = GLib.IOChannel.unix_new(2);

  Opal.gvars.stdout.write_proc = function(s) {
    var buf = ByteArray.fromString(s);
    stdout.write_chars(buf, buf.length);
    stdout.flush();
  }

  Opal.gvars.stderr.write_proc = function(s) {
    var buf = ByteArray.fromString(s);
    stderr.write_chars(buf, buf.length);
    stderr.flush();
  }

  Opal.gvars.stdin.read_proc = function(_s) {
    var out = stdin.read_line();
    if (out[0] == GLib.IOStatus.EOF) return nil;
    return out[1].toString();
  }
}
