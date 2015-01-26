class IO
  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2

  def tty?
    @tty
  end

  def closed?
    @closed
  end

  attr_accessor :write_proc

  def write(string)
    `self.write_proc(string)`
    string.size
  end

  attr_accessor :sync

  module Writable
    def <<(string)
      write(string)
      self
    end

    def print(*args)
      write args.map { |arg| String(arg) }.join($,)
      nil
    end

    def puts(*args)
      newline = $/
      if args.empty?
        write $/
      else
        write args.map { |arg| String(arg).chomp }.concat([nil]).join(newline)
      end
      nil
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


$stdout.write_proc = `typeof(process) === 'object' ? function(s){process.stdout.write(s)} : function(s){console.log(s)}`
$stderr.write_proc = `typeof(process) === 'object' ? function(s){process.stderr.write(s)} : function(s){console.warn(s)}`

$stdout.extend(IO::Writable)
$stderr.extend(IO::Writable)
