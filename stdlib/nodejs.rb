require 'nodejs/runtime.js'
require 'nodejs/file'
require 'nodejs/dir'

class LoadError < ScriptError; end

module IO::Writable
  def puts(*args)
    write args.map { |arg| String(arg) }.join($/)+$/
  end
end

$stdout = IO.new
$stderr = IO.new
STDOUT = $stdout
STDERR = $stderr

def $stdout.write(string)
  `process.stdout.write(#{string})`
  string.size
end

def $stderr.write(string)
  `process.stderr.write(string)`
  string.size
end

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

ENV = Object.new
def ENV.[]= name, value
  `process.env[#{name.to_s}] = #{value.to_s}`
end

def ENV.[] name
  `process.env[#{name}]`
end
