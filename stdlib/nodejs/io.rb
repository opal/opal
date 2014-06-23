$stdout.write_proc = -> (string) {`process.stdout.write(#{string})`}
$stderr.write_proc = -> (string) {`process.stderr.write(string)`}
