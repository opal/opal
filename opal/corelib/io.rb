class IO
  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2
  SEEK_DATA = 3
  SEEK_HOLE = 4

  READABLE = 1
  WRITABLE = 4

  def initialize(fd, mode = 'r')
    @fd = fd
    @mode = mode
  end

  def tty?
    `self.tty == true`
  end

  def closed?
    @closed
  end

  attr_accessor :write_proc
  attr_accessor :read_proc

  def write(string)
    `self.write_proc(string)`
    string.size
  end

  attr_accessor :sync, :tty

  def flush
    # noop
  end

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

  def getc
    @read_buffer ||= ''
    parts = ''

    # Will execure at most twice - one time reading from a buffer
    # second time
    begin
      @read_buffer += parts
      if @read_buffer != ''
        ret = @read_buffer[0]
        @read_buffer = @read_buffer[1..-1]
        return ret
      end
    end while parts = sysread_noraise(65_536)

    nil
  end

  def getbyte
    getc&.ord
  end

  def readbyte
    readchar.ord
  end

  def readchar
    getc || raise(EOFError, 'end of file reached')
  end

  def readline(sep = $/, limit = nil)
    gets(sep, limit) || raise(EOFError, 'end of file reached')
  end

  def gets(sep = $/, limit = nil)
    @read_buffer ||= ''
    data = ''

    begin
      @read_buffer += data
      if @read_buffer.include? sep
        orig_buffer = @read_buffer
        ret, @read_buffer = @read_buffer.split(sep, 2)
        ret += sep if ret != orig_buffer
        if limit
          ret = ret[0...limit]
          @read_buffer = ret[limit..-1] + @read_buffer
        end
        return ret
      end
    end while data = sysread_noraise(65_536)

    ret, @read_buffer = @read_buffer, ''
    ret = nil if ret == ''
    ret
  end

  # This method is to be overloaded, or read_proc can be changed
  def sysread(integer)
    `self.read_proc(integer)` || begin
      raise EOFError, 'end of file reached'
    end
  end

  # @private
  def sysread_noraise(integer)
    sysread(integer)
  rescue EOFError
    nil
  end

  def readpartial(integer)
    @read_buffer ||= ''
    part = sysread(integer)
    ret, @read_buffer = @read_buffer + (part || ''), ''
    ret = nil if ret == ''
    ret
  end

  def read(integer = nil)
    @read_buffer ||= ''
    parts = ''
    ret = nil

    begin
      @read_buffer += parts
      if integer && @read_buffer.length > integer
        ret, @read_buffer = @read_buffer[0...integer], @read_buffer[integer..-1]
        return ret
      end
    end while parts = sysread_noraise(65_536)

    ret, @read_buffer = @read_buffer, ''
    ret
  end

  def readlines(separator = $/)
    each_line(separator).to_a
  end

  def each_line(separator = $/, &block)
    return enum_for :each_line, separator unless block_given?

    while (s = gets(separator))
      yield(s)
    end
  end
end

STDIN  = $stdin  = IO.new(0, 'r')
STDOUT = $stdout = IO.new(1, 'w')
STDERR = $stderr = IO.new(2, 'w')

`var console = Opal.global.console`
STDOUT.write_proc = `typeof(process) === 'object' && typeof(process.stdout) === 'object' ? function(s){process.stdout.write(s)} : function(s){console.log(s)}`
STDERR.write_proc = `typeof(process) === 'object' && typeof(process.stderr) === 'object' ? function(s){process.stderr.write(s)} : function(s){console.warn(s)}`

STDIN.read_proc = `function(s) { var p = prompt(); if (p !== null) return p + "\n"; return nil; }`
