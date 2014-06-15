require 'nodejs/runtime.js'
require 'nodejs/file'
require 'nodejs/dir'

class LoadError < ScriptError; end

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

module Kernel
  def exit
    `process.exit()`
  end
end

module NodeJS
  def self.require name
    `OpalNode.node_require(#{name})`
  end
end

ARGV = `process.argv`
p ARGV
ENV = Object.new
def ENV.[]= name, value
  `process.env[#{name.to_s}] = #{value.to_s}`
end

def ENV.[] name
  `process.env[#{name}] || nil`
end
