class StringIO < IO
  def self.open(string = "", mode = nil, &block)
    io  = new(string, mode)
    res = block.call(io)
    io.close

    res
  end

  attr_accessor :string

  def initialize(string = "", mode = 'rw')
    @string   = string
    @position = 0

    super(nil, mode)
  end

  def eof?
    check_readable

    @position == @string.length
  end

  def seek(pos, whence = IO::SEEK_SET)
    # Let's reset the read buffer, because it will be most likely wrong
    @read_buffer = ''

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

  def rewind
    seek 0
  end

  def write(string)
    check_writable

    # Let's reset the read buffer, because it will be most likely wrong
    @read_buffer = ''

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
      @position = @string.length if @position > @string.length
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

  def sysread(length)
    check_readable

    read(length)
  end

  alias eof eof?
  alias pos tell
  alias pos= seek
  alias readpartial read
end
