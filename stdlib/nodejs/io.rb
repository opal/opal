module IO::Writable
  def puts(*args)
    write args.map { |arg| String(arg) }.join($/)+$/
  end
end

STDERR = $stderr = IO.new
STDIN  = $stdin  = IO.new
STDOUT = $stdout = IO.new

$stdout.write_proc = -> (string) {`process.stdout.write(#{string})`}
$stderr.write_proc = -> (string) {`process.stderr.write(string)`}

$stdout.extend(IO::Writable)
$stderr.extend(IO::Writable)

