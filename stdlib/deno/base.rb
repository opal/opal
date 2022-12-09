module Deno
  VERSION = `Deno.version.deno`
end

`Opal.exit = Deno.exit`

ARGV = `Deno.args.slice(2)`
ARGV.shift if ARGV.first == '--'

STDOUT.write_proc = ->(string) { `Deno.stdout.write(new TextEncoder().encode(string))` }
STDERR.write_proc = ->(string) { `Deno.stderr.write(new TextEncoder().encode(string))` }

STDIN.read_proc = %x{function(_count) {
  // Ignore count, return as much as we can get
  var buf = new Uint8Array(65536), count;
  try {
    count = Deno.stdin.readSync(buf);
  }
  catch (e) { // Windows systems may raise EOF
    return nil;
  }
  if (count == 0) return nil;
  return buf.toString('utf8', 0, count);
}}

STDIN.tty = true
STDOUT.tty = true
STDERR.tty = true
