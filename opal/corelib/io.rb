class IO
  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2

  def tty?
    `self.tty == true`
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
      %x{
        for (var i = 0, ii = args.length; i < ii; i++) {
          args[i] = #{String(`args[i]`)}
        }
        self.$write(args.join(#{$,}));
      }
      nil
    end

    def puts(*args)
      %x{
        for (var i = 0, ii = args.length; i < ii; i++) {
          args[i] = #{String(`args[i]`).chomp}
        }
        self.$write(args.concat([nil]).join(#{$/}));
      }
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

`var console = Opal.global.console`
STDOUT.write_proc = `typeof(process) === 'object' && typeof(process.stdout) === 'object' ? function(s){process.stdout.write(s)} : function(s){console.log(s)}`
STDERR.write_proc = `typeof(process) === 'object' && typeof(process.stderr) === 'object' ? function(s){process.stderr.write(s)} : function(s){console.warn(s)}`

STDOUT.extend(IO::Writable)
STDERR.extend(IO::Writable)
