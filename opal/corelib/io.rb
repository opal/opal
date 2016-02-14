class IO
  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2

  attr_reader :eof
  attr_reader :lineno

  def initialize(fd, mode = 'r')
    @eof = false
    @lineno = 0
  end

  def read
    if @eof
      ''
    else
      res = File.read(@path)
      @eof = true
      @lineno = res.size
      res
    end
  end

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

  attr_accessor :sync, :tty

  def flush
    # noop
  end

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

STDOUT.write_proc = `typeof(process) === 'object' ? function(s){process.stdout.write(s)} : function(s){console.log(s)}`
STDERR.write_proc = `typeof(process) === 'object' ? function(s){process.stderr.write(s)} : function(s){console.warn(s)}`

STDOUT.extend(IO::Writable)
STDERR.extend(IO::Writable)
