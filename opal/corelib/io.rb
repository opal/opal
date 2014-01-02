class IO
  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2

  module Writable
    def <<(string)
      write(string)

      self
    end

    def print(*args)
      write args.map { |arg| String(arg) }.join($,)
    end

    def puts(*args)
      write args.map { |arg| String(arg) }.join($/)
    end
  end

  module Readable
    def readbyte
      getbyte
    end

    def readchar
      getc
    end

    def readline(sep = $/)
      raise NotImplementedError
    end

    def readpartial(integer, outbuf = nil)
      raise NotImplementedError
    end
  end
end

STDERR = $stderr = IO.new
STDIN  = $stdin  = IO.new
STDOUT = $stdout = IO.new

def $stdout.write(string)
  `console.log(#{string.to_s});`
  nil
end

def $stderr.write(string)
  `console.warn(#{string.to_s});`
  nil
end

$stdout.extend(IO::Writable)
$stderr.extend(IO::Writable)
