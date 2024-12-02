# backtick_javascript: true

class ::IO
  self::SEEK_SET = 0
  self::SEEK_CUR = 1
  self::SEEK_END = 2
  self::SEEK_DATA = 3
  self::SEEK_HOLE = 4

  self::READABLE = 1
  self::WRITABLE = 4

  attr_reader :eof

  attr_accessor :read_proc,  :sync, :tty, :write_proc

  def initialize(fd, flags = 'r')
    @fd = fd
    @flags = flags
    @eof = false

    if flags.include?('r') && !flags.match?(/[wa+]/)
      @closed = :write
    elsif flags.match?(/[wa]/) && !flags.match?(/[r+]/)
      @closed = :read
    end
  end

  def fileno
    @fd
  end

  def tty?
    `self.tty == true`
  end

  def write(string)
    `self.write_proc(string)`
    string.size
  end

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
        args[i] = #{::Kernel.String(`args[i]`)}
      }
      self.$write(args.join(#{$,}));
    }
    nil
  end

  def puts(*args)
    %x{
      var line
      if (args.length === 0) {
        #{write "\n"};
        return nil;
      } else {
        for (var i = 0, ii = args.length; i < ii; i++) {
          if (args[i].$$is_array){
            var ary = #{`args[i]`.flatten}
            if (ary.length > 0) #{puts(*`ary`)}
          } else {
            if (args[i].$$is_string) {
              line = args[i].valueOf();
            } else {
              line = #{::Kernel.String(`args[i]`)};
            }
            if (!line.endsWith("\n")) line += "\n"
            #{write `line`}
          }
        }
      }
    }
    nil
  end

  # Reading

  def getc
    @read_buffer ||= ''
    parts = ''

    # Will execure at most twice - one time reading from a buffer
    # second time executing read proc
    begin
      @read_buffer += parts
      if @read_buffer != ''
        ret = @read_buffer[0]
        @read_buffer = @read_buffer[1..-1]
        return ret
      end
    end while parts = sysread_noraise(1)

    nil
  end

  def getbyte
    getc&.ord
  end

  def readbyte
    readchar.ord
  end

  def readchar
    getc || ::Kernel.raise(::EOFError, 'end of file reached')
  end

  def readline(*args)
    gets(*args) || ::Kernel.raise(::EOFError, 'end of file reached')
  end

  def gets(sep = false, limit = nil, opts = {})
    if `sep.$$is_number` && !limit
      sep, limit, opts = false, sep, limit
    end
    if `sep instanceof Map` && !limit && opts == {}
      sep, limit, opts = false, nil, sep
    elsif `limit instanceof Map` && opts == {}
      sep, limit, opts = sep, nil, limit
    end

    orig_sep = sep

    sep = $/ if sep == false
    sep = /\r?\n\r?\n/ if sep == ''
    sep ||= ''
    sep = sep.to_str unless orig_sep == ''

    # Try to deduce length of a regexp
    seplen = orig_sep == '' ? 2 : sep.length

    sep = / / if sep == ' ' # WTF is this, String#split(" ") matches all whitespaces???

    @read_buffer ||= ''
    data = ''
    ret = nil

    begin
      @read_buffer += data
      if sep != '' && (`sep.$$is_regexp` ? @read_buffer.match?(sep) : @read_buffer.include?(sep))
        orig_buffer = @read_buffer
        ret, @read_buffer = @read_buffer.split(sep, 2)
        ret += orig_buffer[ret.length, seplen] if ret != orig_buffer
        break
      end
    end while data = sysread_noraise(sep == '' ? 65_536 : 1)

    unless ret
      ret, @read_buffer = @read_buffer || '', ''
      ret = nil if ret == ''
    end

    if ret
      if limit
        ret = ret[0...limit]
        @read_buffer = ret[limit..-1] + @read_buffer
      end
      ret = ret.sub(/\r?\n\z/, '') if opts[:chomp]
      ret = ret.sub(/\A[\r\n]+/, '') if orig_sep == ''
    end

    $_ = ret if orig_sep == false
    ret
  end

  # This method is to be overloaded, or read_proc can be changed
  def sysread(integer)
    `self.read_proc(integer)` || begin
      @eof = true
      ::Kernel.raise ::EOFError, 'end of file reached'
    end
  end

  # @private
  def sysread_noraise(integer)
    sysread(integer)
  rescue ::EOFError
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
    end while parts = sysread_noraise(integer || 65_536)

    ret, @read_buffer = @read_buffer, ''
    ret
  end

  # Eaches

  def readlines(separator = $/)
    each_line(separator).to_a
  end

  def each(sep = $/, *args, &block)
    return enum_for :each, sep, *args unless block_given?

    while (s = gets(sep, *args))
      yield(s)
    end

    self
  end

  def each_byte(&block)
    return enum_for :each_byte unless block_given?

    while (s = getbyte)
      yield(s)
    end

    self
  end

  def each_char(&block)
    return enum_for :each_char unless block_given?

    while (s = getc)
      yield(s)
    end

    self
  end

  # Closedness

  def close
    @closed = :both
  end

  def close_read
    if @closed == :write
      @closed = :both
    else
      @closed = :read
    end
  end

  def close_write
    if @closed == :read
      @closed = :both
    else
      @closed = :write
    end
  end

  def closed?
    @closed == :both
  end

  def closed_read?
    @closed == :read || @closed == :both
  end

  def closed_write?
    @closed == :write || @closed == :both
  end

  # @private
  def check_writable
    if closed_write?
      ::Kernel.raise ::IOError, 'not opened for writing'
    end
  end

  # @private
  def check_readable
    if closed_read?
      ::Kernel.raise ::IOError, 'not opened for reading'
    end
  end

  alias each_line each
  alias eof? eof
end

::STDIN  = $stdin  = ::IO.new(0, 'r')
::STDOUT = $stdout = ::IO.new(1, 'w')
::STDERR = $stderr = ::IO.new(2, 'w')

`var console = Opal.global.console`
::STDOUT.write_proc = `typeof(process) === 'object' && typeof(process.stdout) === 'object' ? function(s){process.stdout.write(s)} : function(s){console.log(s)}`
::STDERR.write_proc = `typeof(process) === 'object' && typeof(process.stderr) === 'object' ? function(s){process.stderr.write(s)} : function(s){console.warn(s)}`

::STDIN.read_proc = `function(s) { var p = prompt(); if (p !== null) return p + "\n"; return nil; }`
