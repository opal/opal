STDOUT.write_proc = -> (string) {`process.stdout.write(string)`}
STDERR.write_proc = -> (string) {`process.stderr.write(string)`}

STDOUT.tty = true
STDERR.tty = true
