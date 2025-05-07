# backtick_javascript: true
# ::ARGF is a instance of this anonymous class, note the .new(ARGV) at the bottom
::ARGF = Class.new do
  include Enumerable

  def initialize(*args)
    @argv = args[0].is_a?(Array) ? args[0] : args
    @lineno = 0
    @processed = false
    @binmode = false
  end

  # Returns the ARGV array, which contains the arguments passed to your script, one per element.
  attr_reader :argv

  def binmode
    # Puts ARGF into binary mode. Once a stream is in binary mode, it cannot be reset to non-binary mode.
    @binmode = true
    file.binmode
    self
  end

  # Returns true if ARGF is being read in binary mode; false otherwise.
  def binmode?
    @binmode
  end

  def close
    # Closes the current file and skips to the next file in ARGV.
    return self if @file == $stdin
    next_filename = argv.shift
    if !next_filename && !@file
      next_filename = '-'
    elsif next_filename && next_filename != '-'
      next_filename = argv.shift while next_filename && next_filename[0] == '-'
    end
    @file.close if @file
    return self unless next_filename
    $FILENAME = @filename = next_filename
    @file = nil
    self
  end

  def closed?
    # Returns true if the current file has been closed; false otherwise.
    !file || file.closed?
  end

  def each(sep = $/, limit = nil, chomp: false)
    # Returns an enumerator which iterates over each line (separated by sep,
    # which defaults to your platform’s newline character) of each file in ARGV.
    # If a block is supplied, each line in turn will be yielded to the block,
    # otherwise an enumerator is returned.
    return enum_for(:each, sep, limit, chomp: chomp) unless block_given?
    @processed = true
    while ln = gets(sep, limit, chomp: chomp)
      yield ln
    end
    self
  end

  def each_byte(&block)
    # Iterates over each byte of each file in ARGV. A byte is returned as an Integer in the range 0..255.
    return enum_for(:each_byte) unless block_given?
    last = nil
    @processed = true
    while last != file
      file.each_byte(&block)
      last = file
      close
    end
    self
  end

  def each_char(&block)
    # Iterates over each character of each file in ARGF.
    return enum_for(:each_char) unless block_given?
    last = nil
    @processed = true
    while last != file
      file.each_char(&block)
      last = file
      close
    end
    self
  end

  def each_codepoint(&block)
    # Iterates over each codepoint of each file in ARGF.
    return enum_for(:each_codepoint) unless block_given?
    last = nil
    @processed = true
    while last != file
      file.each_codepoint(&block)
      last = file
      close
    end
    self
  end

  alias each_line each

  def eof
    # Returns true if the current file in ARGF is at end of file, i.e. it has no data to read.
    !file || file.eof?
  end

  alias eof? eof

  def external_encoding
    # Returns the external encoding for files read from ARGF as an Encoding object.
    file.external_encoding
  end

  def file
    # Returns the current file as an IO or File object.
    return @file if @file
    fn = filename
    @file = fn == '-' ? $stdin : File.open(fn, 'r')
    @file.binmode if binmode?
    @file
  end

  # Returns the current filename. “-” is returned when the current file is STDIN.
  def filename
    close unless @filename
    @filename
  end

  def fileno
    # Returns an integer representing the numeric file descriptor for the current file
    file.fileno
  rescue IOError => e
    e = ::ArgumentError.new('closed stream') if e.message == 'closed stream'
    raise e
  end

  def getbyte
    # Gets the next 8-bit byte (0..255) from ARGF. Returns nil if called at the end of the stream.
    @processed = true
    byte = file.getbyte
    unless file == $stdin
      last = nil
      while byte.nil?
        last = file
        close
        return byte if last == file
        byte = file.getbyte
      end
    end
    byte
  end

  def getc
    # Gets the next 8-bit byte (0..255) from ARGF. Returns nil if called at the end of the stream.
    @processed = true
    char = file.getc
    unless file == $stdin
      while char.nil?
        last = file
        close
        return char if last == file
        char = file.getc
      end
    end
    char
  rescue IOError => e
    return nil if e.message.include? 'closed '
    raise e
  end

  def gets(sep = $/, limit = nil, chomp: false)
    # Returns the next line from the current file in ARGF.
    @processed = true
    ln = file.gets(sep, limit, chomp: chomp)
    unless file == $stdin
      while ln.nil?
        last = file
        close
        return ln if last == file
        ln = file.gets(sep, limit, chomp: chomp)
      end
      @lineno += 1 if ln
    end
    ln
  rescue IOError => e
    return nil if e.message.include? 'closed '
    raise e
  end

  # Returns the file extension appended to the names of backup copies of modified files under in-place edit mode.
  attr_reader :inplace_mode

  def inplace_mode=(ext)
    # Sets the filename extension for in-place editing mode to the given String.
    # The backup copy of each file being edited has this value appended to its filename.
    @inplace_mode = ext
  end

  def inspect
    'ARGF'
  end

  def internal_encoding
    # Returns the internal encoding for strings read from ARGF as an Encoding object.
    file&.internal_encoding || Encoding.internal_encoding
  end

  # Returns the current line number of ARGF as a whole.
  attr_reader :lineno

  def lineno=(int)
    # Sets the line number of ARGF as a whole to the given Integer.
    @lineno = int
  end

  alias path filename

  def pos
    # Returns the current offset (in bytes) of the current file in ARGF.
    file.pos
  rescue IOError => e
    e = ::ArgumentError.new('closed stream') if e.message == 'closed stream'
    raise e
  end

  def pos=(int)
    # Seeks to the position given by position (in bytes) in ARGF.
    file.pos = int
  end

  def print(*objects)
    # Writes the given objects to the stream; returns nil.
    # Appends the output record separator $OUTPUT_RECORD_SEPARATOR ($\), if it is not nil. See Line IO.
    file.print(*objects)
  end

  def printf(format_string, *objects)
    # Formats and writes objects to the stream.
    file.printf(format_string, *objects)
  end

  def putc(object)
    # Writes a character to the stream.
    file.putc(object)
  end

  def puts(object)
    # Writes the given objects to the stream, which must be open for writing; returns nil.
    file.puts(object)
  end

  def read(len = nil, out_string = nil)
    # Reads length bytes from ARGF. The files named on the command line are concatenated
    # and treated as a single file by this method, so when called without arguments the
    # contents of this pseudo file are returned in their entirety.
    if out_string
      # requires mutable Strings
      raise NotImplementedError, 'out_string buffer is currently not supported'
    end
    @processed = true
    enc = binmode? ? ::Encoding::US_ASCII : external_encoding
    res = `Opal.str('', enc)`
    last = nil
    while last != file
      r = file.read(len)
      if r
        res += r
        len -= r.bytesize if len
      end
      break if len && len <= 0
      last = file
      close
    end
    res
  end

  # Reads at most maxlen bytes from the ARGF stream in non-blocking mode.
  alias read_nonblock __not_implemented__

  def readbyte
    @processed = true
    file.readbyte
  end

  def readchar
    @processed = true
    file.readchar
  end

  def readline(sep = $/, limit = nil, chomp: false)
    # Returns the next line from the current file in ARGF.
    @processed = true
    begin
      ln = file.readline(sep, limit, chomp: chomp)
    rescue EOFError => e
      raise e if argv.empty?
      close
      ln = file.readline(sep, limit, chomp: chomp)
    end
    ln
  end

  def readlines(sep = $/, limit = nil, chomp: false)
    # Reads each file in ARGF in its entirety, returning an Array containing lines from the files.
    each(sep, limit, chomp: chomp).to_a
  end

  def readpartial(len, out_string = nil)
    # Reads at most maxlen bytes from the ARGF stream.
    if out_string
      # requires mutable Strings
      raise NotImplementedError, 'out_string buffer is currently not supported'
    end
    @processed = true
    begin
      file.readpartial(len)
    rescue EOFError => e
      raise e if argv.empty?
      close
      ''
    end
  end

  def rewind
    # Positions the current file to the beginning of input, resetting ARGF.lineno to zero.
    @lineno = 0
    return if file == $stdin
    file.rewind
    0
  rescue IOError => e
    e = ::ArgumentError.new('closed stream') if e.message == 'closed stream'
    raise e
  end

  def seek(amount, whence = ::IO::SEEK_SET)
    # Seeks to offset amount (an Integer) in the ARGF stream according to the value of whence.
    file.seek(amount, whence)
  end

  def set_encoding(*args)
    file.set_encoding(*args)
  end

  def skip
    return self unless @processed
    return self if @file == $stdin
    next_filename = argv.shift
    if !next_filename && !@file
      next_filename = '-'
    elsif next_filename && next_filename != '-'
      next_filename = argv.shift while next_filename && next_filename[0] == '-'
    end
    return self unless next_filename
    @processed = false
    @file.close
    $FILENAME = @filename = next_filename
    @file = nil
    self
  end

  alias tell pos

  def to_a
    each.to_a
  rescue
    []
  end

  alias to_i fileno

  alias to_io file

  alias to_s inspect

  alias to_write_io __not_implemented__

  alias write __not_implemented__
end.new(ARGV)
