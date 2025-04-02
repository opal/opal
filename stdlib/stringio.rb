# helpers: str
# backtick_javascript: true

class StringIO
  include ::Enumerable

  MAX_LENGTH = `Number.MAX_SAFE_INTEGER` # that would be bytes
  VERSION = "0"

  def self.open(string = nil, mode = nil, **opts, &block)
    # Creates a new IO object, via IO.new with the given arguments.
    # With no block given, returns the IO object.
    # With a block given, calls the block with the IO object and returns the block’s value.
    io  = new(string, mode, **opts)
    return io unless block_given?
    res = nil
    begin
      res = yield(io)
    ensure
      begin
        `io.string = nil`
        `io.string_is_valid = true`
        io.close
      rescue IOError
        nil
      end
    end
    res
  end

  %x{
    function check_readable(io) {
      if (io.closed === "read" || io.closed === "both" ) { #{raise IOError, 'closed for reading'} }
    }

    function check_writable(io) {
      if (io.closed === "write" || io.closed === "both" ) { #{raise IOError, 'closed for writing'} }
    }

    function check_open(io) {
      if (io.closed === "both") #{raise IOError, 'closed stream'};
    }

    function get_string(io, enc) {
      if (!io.string_is_valid) {
        io.string = io.buffer.$get_raw_string(0, nil, enc, false);
        io.string_is_valid = true;
      }
      return io.string;
    }

    // code for '\r' is 13, code for '\n' is 10
    function is_sep(sep_bytes, sep_len, data_view, pos, check_rn) {
      let byte = data_view.getUint8(pos);
      if (check_rn && 13 === byte && 10 === data_view.getUint8(pos + 1)) {
        return true;
      }
      if (sep_bytes[0] === byte) {
        for (let i = 1; i < sep_len; i++) {
          if (sep_bytes[i] !== data_view.getUint8(pos + i)) return false;
        }
        return true;
      }
      return false;
    }
  }

  def initialize(str = nil, mode = nil, **opts)
    # Returns a new StringIO instance formed from string and mode.
    raise(ArgumentError, 'opts must be a Hash') unless opts.is_a?(::Hash)
    if mode.is_a?(::Hash)
      opts = mode
      mode = nil
    end

    @autoclose = !!opts.fetch(:autoclose, true)

    self.string = str

    @close_on_exec = true
    @sync = false

    @path = opts[:path]
    flags = opts[:flags]

    if opts[:open_args]
      # :open_args can be used with the class methods IO.read and IO.write
      opts[:open_args].each do |arg|
        if arg
          if arg.is_a?(String)
            mode = arg
          elsif arg.is_a?(Hash)
            @binmode = arg[:binmode] if arg.key?(:binmode)
            ext_enc = arg[:encoding] if arg.key?(:encoding)
            flags = arg[:flags] if arg.key?(:flags)
            mode = arg[:mode] if arg.key?(:mode)
          end
        end
      end
    end

    mode = ::Opal.coerce_to!(mode, ::String, :to_str) rescue mode
    if mode.is_a?(String)
      raise(ArgumentError, 'mode given twice') if opts[:mode]
    elsif mode
      flags = ::Opal.coerce_to!(mode, ::Integer, :to_int)
      mode = nil
    end
    unless mode
      if opts.key?(:mode)
        mode = opts[:mode]
        mode = ::Opal.coerce_to!(mode, ::String, :to_str) rescue mode
        unless mode.is_a?(::String)
          flags = ::Opal.coerce_to!(mode, ::Integer, :to_int)
          mode = nil
        end
      end
    end
    mode = 'r+' unless mode

    raise(ArgumentError, 'mode is a empty string') if mode.empty?

    mode, ext_enc, int_enc = mode.split(':') if mode&.include?(':')
    binmode = mode.include?('b')
    textmode = mode.include?('t') # only used for args checking

    raise(ArgumentError, 'mode given multiple times') if (binmode || textmode) && (opts.key?(:binmode) || opts.key?(:textmode))

    @binmode = binmode || !!opts[:binmode]
    textmode = textmode || !!opts[:textmode]

    raise(ArgumentError, 'choose either binmode or textmode') if @binmode && textmode

    if mode.include?('r') && !mode.match?(/[wa+]/)
      @opened = :read
      @closed = :write
    elsif mode.match?(/[wa]/) && !mode.match?(/[r+]/)
      @opened = :write
      @closed = :read
    else
      @opened = :duplex
    end

    @mode = mode

    raise(ArgumentError, 'external encoding given multiple times') if ext_enc && (opts.key?(:encoding) || opts.key?(:external_encoding))

    if ext_enc.nil?
      ext_enc = opts[:external_encoding]
      if opts.key?(:encoding)
        if opts.key?(:external_encoding)
          STDERR.puts "warning: Ignoring encoding parameter '#{opts[:encoding].upcase}': external_encoding is used"
        elsif opts.key?(:internal_encoding)
          STDERR.puts "warning: Ignoring encoding parameter '#{opts[:encoding].upcase}': internal_encoding is used"
        else
          ext_enc = opts[:encoding]
        end
      end
    end

    enc_def_ext = ::Encoding.default_external
    enc_def_int = ::Encoding.default_internal

    if ext_enc && !ext_enc.is_a?(::Encoding)
      ext_enc = ::Opal.coerce_to!(ext_enc, ::String, :to_str)
      ext_enc, int_enc = ext_enc.split(':') if ext_enc.include?(':')
      ext_enc = ::Encoding.find(ext_enc)
    end

    if opts.key?(:internal_encoding)
      raise(ArgumentError, 'internal encoding given multiple times') if int_enc
      int_enc = opts[:internal_encoding]
    end

    @ext_enc = if ext_enc || (enc_def_int.nil? && mode == 'r')
                  ext_enc
                elsif @binmode
                  ::Encoding::BINARY
                else
                  @string.encoding
                end

    if int_enc && !int_enc.is_a?(::Encoding)
      int_enc = ::Opal.coerce_to!(int_enc, ::String, :to_str)
      int_enc = ::Encoding.find(int_enc) unless int_enc == '-'
    end
    @int_enc = if int_enc && (int_enc == '-' || int_enc == @ext_enc)
                  nil
                elsif int_enc
                  int_enc
                elsif enc_def_ext == enc_def_int || @ext_enc == ::Encoding::BINARY
                  nil
                else
                  enc_def_int
                end

    nl = opts[:newline]
    @write_lsep = if nl == :cr
                    "\r"
                  elsif nl == :crlf
                    "\r\n"
                  else
                    "\n"
                  end

    @tty = `$platform.io_open(self.fd)` if @fd
  end

  def <<(object)
    # Writes the given object to self, which must be opened for writing (see Access Modes);
    # returns self; if object is not a string, it is converted via method to_s:
    write(object)
    self
  end

  def binmode
    # Sets the data mode in self to binary mode
    `check_open(self)`
    @ext_enc = ::Encoding::BINARY
    @int_enc = nil
    @binmode = true
    self
  end

  def close
    # Closes the stream for both reading and writing if open for either or both; returns nil.
    return if closed?
    @closed = :both
    @pid = nil
    nil
  end

  def close_read
    # Closes the stream for reading if open for reading; returns nil
    raise ::IOError if @opened == :write
    return if @closed == :read || closed?
    return close if @closed == :write || @opened == :read
    @closed = :read
    nil
  end

  def close_write
    # Closes the stream for writing if open for writing; returns nil.
    raise ::IOError if @opened == :read
    return if @closed == :write || closed?
    flush
    return close if @closed == :read || @opened == :write
    @closed = :write
    nil
  end

  def closed?
    # Returns true if the stream is closed for both reading and writing, false otherwise.
    @closed == :both
  end

  def closed_read?
    # Returns true if self is closed for reading, false otherwise.
    @closed == :read || closed?
  end

  def closed_write?
    # Returns true if self is closed for writing, false otherwise.
    @closed == :write || closed?
  end

  def each(sep = $/, limit = nil, chomp: false)
    # Calls the block with each remaining line read from the stream; returns self.
    unless sep.nil?
      if limit.nil? && sep.is_a?(::Numeric)
        limit = sep
        sep = $/
      end
    end
    raise(ArgumentError, "if limit is given, it must be greater than 0") if limit && limit < 1

    return enum_for(:each, sep, limit, chomp: chomp) unless block_given?

    global_last_line = $_ # this does not seem right, but makes specs pass, maybe it is right

    got_text = false
    while (line = gets(sep, limit, chomp: chomp))
      next if !got_text && sep == '' && line =~ /\A\n+\z/
      got_text = true
      yield(line)
    end

    $_ = global_last_line
    self
  end

  def each_byte
    # Calls the given block with each byte (0..255) in the stream; returns self.
    return enum_for :each_byte unless block_given?
    while (byte = getbyte)
      yield(byte)
    end
    self
  end

  def each_char(&block)
    # With a block given, calls the block with each remaining character in the stream
    return enum_for :each_char unless block_given?
    while (chr = getc)
      yield(chr)
    end
    self
  end

  def each_codepoint(&block)
    # With a block given, calls the block with each remaining codepoint in the stream
    return enum_for(:each_codepoint) unless block_given?
    while (chr = getc)
      yield(chr.ord)
    end
    self
  end

  alias each_line each

  def eof
    # Returns true if the stream is positioned at its end, false otherwise;
    `check_readable(self)`
    @eof
  end

  alias eof? eof

  def external_encoding
    # Returns the Encoding object that represents the encoding of the stream,
    # or nil if the stream is in write mode and no encoding is specified.
    @ext_enc
  end

  def fcntl
    # Raises NotImplementedError.
    raise ::NotImplementedError
  end

  def fileno
    # Returns nil. Just for compatibility to IO.
    nil
  end

  def flush
    # Returns an object itself. Just for compatibility to IO.
    self
  end

  def fsync
    # Returns 0. Just for compatibility to IO.
    0
  end

  def getbyte
    # Reads and returns the next 8-bit byte from the stream; see Byte IO.
    `check_readable(self)`
    s = @buffer.size
    return nil if @eof || @pos >= s
    byte = `self.buffer.data_view.getUint8(self.pos)`
    @pos += 1
    @eof = true if @pos >= s
    byte
  end

  def getc
    # Reads and returns the next character from the stream; see Character IO.
    `check_readable(self)`
    s = @buffer.size
    return nil if @eof || @pos >= s
    c = @buffer.get_raw_string(@pos, `Math.min(16, s - self.pos)`, @ext_enc) # account for multi byte chars
    c = c[0]
    @pos += c.bytesize
    @eof = true if @pos >= s
    c
  end

  def gets(sep = $/, limit = nil, chomp: false)
    # Reads and returns a line from the stream; assigns the return value to $_.
    `check_readable(self)`
    return $_ = nil if @eof

    paragraph_mode = false

    if sep
      if limit.nil? && !sep.is_a?(::String)
        if sep.respond_to?(:to_int)
          limit = sep.to_int
          sep = $/
        else
          sep = ::Opal.coerce_to!(sep, ::String, :to_str)
        end
      elsif sep == ''
        sep = $/
        paragraph_mode = true
      else
        sep = ::Opal.coerce_to!(sep, ::String, :to_str)
      end
    end

    limit = limit.nil? ? `Infinity` : limit.to_int
    if limit < 0
      limit = `Infinity`
    elsif limit == 0
      return `$str('', self.ext_enc)`
    end

    # get separator as bytes in external encoding
    `if (limit == null || limit === nil) limit = Infinity`
    if sep
      sep_bytes = `$str(sep, self.ext_enc)`.bytes
      sep_len = sep_bytes.size
    else
      sep_len = 0
    end
    buffer_size = @buffer.size
    start_pos = @pos
    search_end = `Math.min(start_pos + limit, buffer_size)`
    sep_pos = 0
    found_sep = false
    i = start_pos
    dv = `self.buffer.data_view`

    # lets look for the separator bytes
    # [possible optimization: use Uint8Array with its indexOf()]
    # TODO: buffer border check
    if sep
      %x{
        let check_rn = (sep === '\n') ? true : false;
        for (; i < search_end; i++) {
          found_sep = is_sep(sep_bytes, sep_len, dv, i, check_rn);
          if (found_sep) {
            sep_pos = i; // chomp pos, end of text, beginning of separator
            i += sep_len; // end of separator, maybe beginning of next separtor or text
            if (check_rn && 13 === dv.getUint8(sep_pos) && 10 === dv.getUint8(i)) i++;
            if (paragraph_mode && i < search_end) { // check for second separator
              if (is_sep(sep_bytes, sep_len, dv, i, check_rn)) {
                i += sep_len;
                if (check_rn && 13 === dv.getUint8(sep_pos) && 10 === dv.getUint8(i)) i++;
              } else {
                found_sep = false;
                // special case if a sep has been found at the end that is not a paragraph sep
                if (i >= search_end) break;
              }
            }
            if (found_sep) break;
          }
        }
      }
    else
      i = search_end
    end
    str_end = found_sep && chomp ? sep_pos : i
    str_len = `Math.min(limit, str_end - start_pos)`
    line = @buffer.get_raw_string(start_pos, str_len, @ext_enc, true)
    if paragraph_mode
      # skip additional empty paragraphs
      `while(i < search_end && is_sep(sep_bytes, sep_len, dv, i)) { i += sep_len }`
    end
    @pos = `limit === Infinity` ? i : `Math.min(start_pos + limit, i)`
    # @pos = start_pos + line.bytesize unless found_sep && chomp
    @eof = true if @pos >= buffer_size

    unless line.nil?
      if @int_enc
        line.force_encoding(@int_enc)
      elsif ::Encoding.default_internal && (@ext_enc != ::Encoding::BINARY || ::Encoding.default_external != ::Encoding::BINARY)
        line.force_encoding(::Encoding.default_internal)
      end

      @lineno += 1
    end

    $. = @lineno
    $_ = line unless sep == ' '
    line
  end

  def inspect
    "#<StringIO:0x#{object_id.to_s(16)}>"
  end

  def internal_encoding
    # Returns the Encoding of the internal string if conversion is specified.
    # Otherwise returns nil.
    @int_enc
  end

  def isatty
    # Returns false. Just for compatibility to IO.
    false
  end

  def length
    # Returns the size of the buffer string.
    @buffer.size
  end

  def lineno
    # Returns the current line number for the stream.
    `check_readable(self)`
    @lineno
  end

  def lineno=(number)
    # Sets and returns the line number for the stream.
    `check_readable(self)`
    number = ::Opal.coerce_to!(number, ::Integer, :to_int) unless number.is_a?(::Numeric)
    number = number.floor if number.is_a?(::Float)
    @lineno = number
  end

  def pid
    # Returns nil. Just for compatibility to IO.
    nil
  end

  def pos
    # Returns the current position (in bytes); see Position.
    @pos
  end

  def pos=(number)
    # Sets the current position (in bytes); see Position.
    `check_open(self)`
    number = ::Opal.coerce_to!(number, ::Integer, :to_int)
    raise(Errno::EINVAL, "position must be >= 0") if number < 0
    @eof = false if @eof && number < @pos
    @eof = true if number >= @buffer.size
    @pos = number
  end

  def pread(maxlen, offset, out_string = nil)
    # Behaves like IO#readpartial, except that it:
    # - Reads at the given offset (in bytes).
    # - Disregards, and does not modify, the stream’s position (see Position).
    # - Bypasses any user space buffering in the stream.
    if out_string
      # requires mutable Strings
      raise NotImplementedError, 'out_string buffer is currently not supported'
    end
    `check_readable(self)`
    raise(::EOFError) if @eof
    raise(::ArgumentError, 'invalid length') if maxlen && maxlen < 0
    @buffer.get_raw_string(offset, maxlen, @ext_enc)
  end

  def print(*objects)
    # Writes the given objects to the stream; returns nil.
    # Appends the output record separator $OUTPUT_RECORD_SEPARATOR ($\),
    # if it is not nil. See Line IO.
    `check_writable(self)`
    if objects.empty?
      write $_
    else
      objects.each do |object|
        object = ::Opal.coerce_to!(object, ::String, :to_s)
        write object
      end
    end
    write $\ if $\
    nil
  end

  def printf(format_string, *objects)
    # Formats and writes objects to the stream.
    write format(format_string, *objects)
    nil
  end

  def putc(object)
    # Writes a character to the stream.
    `check_writable(self)`
    c = if object.is_a?(::String)
          object[0]
        else
          raise(TypeError, 'object of wrong type') unless object.respond_to?(:to_int)
          object = object.to_int
          code = `object & 0xff`
          code.chr
        end
    syswrite c
    object
  end

  def puts(*args)
    # Writes the given objects to the stream, which must be open for writing; returns nil.
    # Writes a newline after each that does not already end with a newline sequence.
    # If called without arguments, writes a newline.
    `check_writable(self)`
    if args.empty?
      write @write_lsep
    else
      args.each do |arg|
        arg = ::Opal.coerce_to!(arg, ::Array, :to_ary) rescue arg
        if arg.is_a?(Array)
          unless arg.empty?
            ary = arg.flatten rescue arg
            ary.each do |a|
              if a == arg
                write("[...]" + @write_lsep)
              else
                puts a
              end
            end
          end
        else
          line = ::Opal.coerce_to!(arg, ::String, :to_s)
          line += @write_lsep unless line.end_with?("\n")
          write(line)
        end
      end
    end
    nil
  end

  def read(length = nil, out_string = nil)
    # Reads bytes from the stream; the stream must be opened for reading:
    # If length is nil, reads all bytes using the stream’s data mode.
    # Otherwise reads up to length bytes in binary mode.
    # Returns a string (either a new string or the given out_string
    # [currently not supported by opal]) containing the bytes read.
    # The encoding of the string depends on both length and out_string.
    if out_string
      # requires mutable Strings
      raise NotImplementedError, 'out_string buffer is currently not supported'
    end
    `check_readable(self)`

    if length && `length !== Infinity`
      unless length.is_a?(::Integer)
        raise(::TypeError, 'length cannot be converted to int') unless length.respond_to?(:to_int)
        length = length.to_int
      end
      raise ArgumentError, 'invalid length' if length < 0
      enc = ::Encoding::BINARY
      return nil if @eof
    else
      enc = @ext_enc
      return `$str('', enc)` if @eof
      length = `Infinity`
    end

    s = @buffer.size
    read_len = `Math.min(length, s - self.pos)`
    return `$str('', enc)` if read_len == 0 # @eof
    res = @buffer.get_raw_string(@pos, read_len, enc)
    @pos = @pos + read_len
    @eof = true if pos >= s
    res
  end

  def readbyte
    # Reads and returns the next byte (in range 0..255) from the stream;
    # raises EOFError if already at end-of-stream.
    `check_readable(self)`
    b = getbyte
    raise ::EOFError if @eof
    b
  end

  def readchar
    # Reads and returns the next 1-character string from the stream; raises EOFError if already at end-of-stream.
    `check_readable(self)`
    c = getc
    raise ::EOFError if @eof
    if @binmode
      `$str(c, #{::Encoding::BINARY})`
    elsif @int_enc
      `$str(c, self.int_enc)`
    elsif @ext_enc
      `$str(c, self.extt_enc)`
    else
      c
    end
  end

  def readline(*args)
    # Reads a line as with IO#gets, but raises EOFError if already at end-of-stream.
    ::Kernel.raise(::EOFError, 'end of file reached') if @eof
    gets(*args)
  end

  def readlines(sep = $/, limit = nil, chomp: false)
    # Reads and returns all remaining line from the stream; does not modify $_.
    global_last_line = $_
    if limit.nil? && sep.is_a?(::Numeric)
      limit = sep
      sep = $/
    end
    limit = nil if limit.is_a?(::Numeric) && limit < 0
    res = each(sep, limit, chomp: chomp).to_a
    $_ = global_last_line unless sep == $/
    res
  end

  def readpartial(maxlen, out_string = nil)
    # Reads up to maxlen bytes from the stream; returns a string (either a new string or the given out_string).
    sysread(maxlen, out_string)
  end

  def reopen(other = nil, mode = nil, **opts)
    if other && mode
      mode = ::Opal.coerce_to!(mode, ::String, :to_str)
      other = ::Opal.coerce_to!(other, ::StringIO, :to_strio) rescue other
      string = if other.is_a?(::StringIO)
                  other.string
                else
                  ::Opal.coerce_to!(other, ::String, :to_str)
                end
      string = `$str('', string.$encoding())` if mode.include?('w') # truncate
      initialize(string, mode, **opts)
    elsif other.is_a?(::String)
      self.string = other
      @mode = 'r+'
      @closed = false
      @opened = :duplex
      rewind
    elsif other
      other = ::Opal.coerce_to!(other, ::StringIO, :to_strio)
      self.string = other.string
      @mode = 'r+'
      @closed = false
      @opened = :duplex
      rewind
    else
      @mode = 'r+'
      @closed = false
      @opened = :duplex
      rewind
    end
    self
  end

  def rewind
    # Repositions the stream to its beginning, setting both the position and the line number to zero.
    @eof = false
    @lineno = 0
    @pos = 0
  end

  def seek(offset, whence = ::IO::SEEK_SET)
    # Seeks to the position given by integer offset (see Position) and constant whence.
    `check_open(self)`
    sz = @buffer.size
    offset = ::Opal.coerce_to!(offset, ::Integer, :to_int)
    if whence == ::IO::SEEK_SET || whence == :SET
      raise Errno::EINVAL, 'wrong value for offset' if offset < 0
      new_pos = offset
    elsif whence == ::IO::SEEK_CUR || whence == :CUR
      new_pos = @pos + offset
    elsif whence == ::IO::SEEK_END || whence == :END
      new_pos = sz + offset
    elsif whence
      raise Errno::EINVAL, 'wrong value for whence'
    end
    # new_pos = sz if new_pos > sz
    # @eof = true if new_pos == sz
    @pos = new_pos
    0
  end

  def set_encoding(ext_enc, int_enc = nil, **enc_opts)
    if int_enc.is_a?(Hash)
      enc_opts = int_enc
      int_enc = nil
    end

    is_stdio = @fd && @fd < 3
    enc_def_int = ::Encoding.default_internal
    @ext_enc = if ext_enc.nil?
                 ::Encoding.default_external
               elsif ext_enc.is_a?(::Encoding)
                 ext_enc
               else
                 ext_enc = ::Opal.coerce_to!(ext_enc, ::String, :to_str)
                 ext_enc, int_enc = ext_enc.split(':') if int_enc.nil?
                 ::Encoding.find(ext_enc)
               end
    int_enc = if int_enc.nil? && (enc_def_int.nil? || is_stdio)
                nil
              elsif int_enc.nil?
                enc_def_int
              elsif int_enc.is_a?(::Encoding)
                int_enc
              else
                int_enc = ::Opal.coerce_to!(int_enc, ::String, :to_str)
                ::Encoding.find(int_enc)
              end
    @int_enc = int_enc == @ext_enc ? nil : int_enc
    @string_is_valid = false
    self
  end

  def set_encoding_by_bom
    # If the stream begins with a BOM (byte order marker),
    # consumes the BOM and sets the external encoding accordingly;
    # returns the result encoding if found, or nil otherwise
    return nil if @opened == :write || @closed == :read || closed?
    raise(ArgumentError, 'ASCII incompatible encoding needs binmode') unless @binmode
    raise(ArgumentError, 'encoding conversion is set') if @ext_enc && @int_enc

    encoding = nil

    # get the first upto 4 bytes
    bom = []
    @buffer.each_byte(0, `Math.min(4, self.buffer.$size())`) do |byte|
      bom << byte
    end

    if bom.size == 4
      # check for 4 byte BOMS
      encoding = case bom
                when [0x00, 0x00, 0xFE, 0xFF] then ::Encoding::UTF_32BE
                when [0xFF, 0xFE, 0x00, 0x00] then ::Encoding::UTF_32LE
                when [0xDD, 0x73, 0x66, 0x73] then false # UTF-EBCDIC
                when [0x84, 0x31, 0x95, 0x33] then false # GB18030
                else nil
                end
      bom.pop if encoding.nil? # 4 -> 3
    end

    if bom.size == 3
      # check for 3 byte BOMS
      encoding = case bom
                when [0xEF, 0xBB, 0xBF] then ::Encoding::UTF_8
                when [0x2B, 0x2F, 0x76] then false # UTF-7
                when [0xF7, 0x64, 0x4C] then false # UTF-1
                when [0x0E, 0xFE, 0xFF] then false # SCSU
                when [0xFB, 0xEE, 0x28] then false # BOCU-1
                else nil
                end
      bom.pop if encoding.nil? # 3 -> 2
    end

    if bom.size == 2
      # check for 2 byte BOMS
      encoding = case bom
                when [0xFE, 0xFF] then ::Encoding::UTF_16BE
                when [0xFF, 0xFE] then ::Encoding::UTF_16LE
                else nil
                end
    end

    if encoding
      # if @ext_enc == encoding
      #   raise raise(ArgumentError, "encoding is set to #{@ext_enc.name} already")
      # end
      @pos = bom.size
      @ext_enc = encoding
      return encoding
    end

    nil
  end

  alias size length

  def string
    # Returns underlying string
    `get_string(self, self.ext_enc)`
  end

  def string=(other_string)
    # Assigns the underlying string as other_string, and sets position to zero;
    # returns other_string
    @string = other_string ? ::Opal.coerce_to!(other_string, ::String, :to_str) : `$str('', #{::Encoding.default_external})`
    @buffer = ::IO::Buffer.for(@string)
    `self.buffer.readonly = false` # Temporary override because of primitives.
    @string_is_valid = true
    rewind
    other_string
  end

  def sync
    # Returns true; implemented only for compatibility with other stream classes
    true
  end

  def sync=(p1)
    # Returns the argument unchanged. Just for compatibility to IO.
    p1
  end

  def sysread(length = nil, out_string = nil)
    # Reads bytes from the stream; the stream must be opened for reading:
    # If maxlen is nil, reads all bytes using the stream’s data mode.
    # Otherwise reads up to maxlen bytes in binary mode.
    # Returns a string (either a new string or the given out_string
    # [currently not supported by opal]) containing the bytes read.
    # The encoding of the string depends on both maxlen and out_string.
    if out_string
      # requires mutable Strings
      raise NotImplementedError, 'out_string buffer is currently not supported'
    end

    `check_readable(self)`

    if length
      unless length.is_a?(::Integer)
        raise(::TypeError, 'length cannot be converted to int') unless length.respond_to?(:to_int)
        length = length.to_int
      end
      raise ArgumentError, 'invalid length' if length < 0
      raise ::EOFError if @eof
      enc = ::Encoding::BINARY
    else
      return `$str('', enc)` if @eof
      length = `Infinity`
      enc = @ext_enc
    end

    s = @buffer.size
    read_len = `Math.min(length, s - self.pos)`
    return `$str('', enc)` if read_len == 0 # @eof
    res = @buffer.get_raw_string(@pos, read_len, enc)
    @pos = @pos + read_len
    @eof = true if @pos >= s
    res
  end

  def syswrite(string)
    # Writes the given string to the underlying buffer string.
    # The stream must be opened for writing. If the argument is not a string,
    # it will be converted to a string using to_s.
    # Returns the number of bytes written.
    `check_writable(self)`
    @pos = @buffer.size if @mode.include?('a')
    string = ::Opal.coerce_to!(string, ::String, :to_s)
    if @ext_enc && string.encoding != @ext_enc && string.encoding != ::Encoding::BINARY
      string = string.encode(@ext_enc)
    end
    string_buffer = ::IO::Buffer.for(string)
    string_buffer_size = string_buffer.size
    max = @pos + string_buffer_size
    @buffer.resize(max) if max > @buffer.size
    @buffer.copy(string_buffer, @pos, string_buffer_size)
    @string_is_valid = false
    @pos += string_buffer_size
    string_buffer_size
  end

  alias tell pos

  def truncate(len)
    # Truncates the buffer string to at most integer bytes.
    # The stream must be opened for writing.
    `check_writable(self)`
    len = ::Opal.coerce_to!(len, ::Integer, :to_int)
    raise(::Errno::EINVAL, 'len cannot be negative') if len < 0
    @buffer.resize(len)
    @string_is_valid = false
    0
  end

  alias tty? isatty

  def ungetbyte(byte)
    # Pushes back (“unshifts”) an 8-bit byte onto the stream; see Byte IO.
    @pos = @pos > 0 ? @pos - 1 : @pos
    @buffer.set_byte(@pos, byte)
    @string_is_valid = false
    nil
  end

  def ungetc(c)
    # Pushes back (“unshifts”) a character or integer onto the stream;
    # see Character IO.
    raise NotImplementedError
  end

  def write(*strings)
    # Writes each of the given objects to self, which must be opened for writing (see Access Modes);
    # returns the total number bytes written; each of objects that is not a string is converted via method to_s.
    `check_writable(self)`
    total_wsize = 0
    strings.each do |str|
      next if str.nil?
      total_wsize += syswrite(str)
    end
    total_wsize
  end
end
