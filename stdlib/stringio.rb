class StringIO < IO
  include IO::Readable
  include IO::Writable

  def self.open(string = "", mode = nil, &block)
    io  = new(string, mode)
    res = block.call(io)
    io.close

    res
  end

  attr_accessor :string

  def initialize(string = "", mode = 'rw')
    @string   = string
    @position = string.length

    if mode.include?('r') and not mode.include?('w')
      @closed = :write
    elsif mode.include?('w') and not mode.include?('r')
      @closed = :read
    end
  end

  def eof?
    check_readable

    @position == @string.length
  end

  alias eof eof?

  def seek(pos, whence = IO::SEEK_SET)
    case whence
    when IO::SEEK_SET
      raise Errno::EINVAL unless pos >= 0

      @position = pos

    when IO::SEEK_CUR
      if @position + pos > @string.length
        @position = @string.length
      else
        @position += pos
      end

    when IO::SEEK_END
      if pos > @string.length
        @position = 0
      else
        @position -= pos
      end
    end

    0
  end

  def tell
    @position
  end

  alias pos tell

  alias pos= seek

  def rewind
    seek 0
  end

  def each_byte(&block)
    return enum_for :each_byte unless block

    check_readable

    i = @position
    until eof?
      block.call(@string[i].ord)
      i += 1
    end

    self
  end

  def each_char(&block)
    return enum_for :each_char unless block

    check_readable

    i = @position
    until eof?
      block.call(@string[i])
      i += 1
    end

    self
  end

  def each(separator = $/)
    return enum_for :each_line unless block_given?
    check_readable
    chomp_lines = false
    if ::Hash === separator
      separator = (chomp_lines = separator[:chomp]) ? /\r?\n/ : $/
    elsif separator
      separator = separator.to_str
    else
      separator = `undefined`
    end
    %x{
      var str = self.string, stringLength = str.length;
      if (self.position < stringLength) str = str.substr(self.position);
      if (separator) {
        var chomped = #{`str`.chomp}, trailing = str.length !== chomped.length, splitted = chomped.split(separator);
        for (var i = 0, len = splitted.length; i < len; i++) {
          var line = chomp_lines ? splitted[i] : (i < len - 1 || trailing ? splitted[i] + separator : splitted[i]);
          #{yield `line`};
        }
      } else if (separator === undefined) {
        #{yield `str`};
      } else {
        var m, re = /(.+(?:\n\n|$))\n*/g;
        while ((m = re.exec(str))) #{yield `m[1]`};
      }
      self.position = stringLength;
    }
    self
  end

  alias each_line each

  def write(string)
    check_writable

    string = String(string)

    if @string.length == @position
      @string   += string
      @position += string.length
    else
      before = @string[0 .. @position - 1]
      after  = @string[@position + string.length .. -1]

      @string   = before + string + after
      @position += string.length
    end
  end

  def read(length = nil, outbuf = nil)
    check_readable

    return if eof?

    string = if length
      str = @string[@position, length]
      @position += length
      str
    else
      str = @string[@position .. -1]
      @position = @string.length
      str
    end

    if outbuf
      outbuf.write(string)
    else
      string
    end
  end

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

  def check_writable
    if closed_write?
      raise IOError, "not opened for writing"
    end
  end

  def check_readable
    if closed_read?
      raise IOError, "not opened for reading"
    end
  end
end
