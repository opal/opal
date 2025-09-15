# helpers: platform, coerce_to, coerce_to_or_nil, coerce_to_or_raise, str, mode_to_flags
# backtick_javascript: true

require 'io/buffer'

class ::IO
  include ::Enumerable

  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2

  READABLE = 1
  PRIORITY = 2
  WRITABLE = 4

  %x{
    const DEFAULT_BUFFER_SIZE = #{::IO::Buffer::DEFAULT_SIZE};

    function check_readable(io) {
      if (io.closed === "read" || io.closed === "both" ) #{raise IOError, 'closed for reading'};
    }

    function check_writable(io) {
      if (io.closed === "write" || io.closed === "both" ) #{raise IOError, 'not opened for writing'};
    }

    function check_open(io) {
      if (io.closed === "both") #{raise IOError, 'closed stream'};
    }

    function flags_readonly(flags) {
      const o = Opal.File.Constants;
      return ((flags & o.RDWR == o.RDWR) || (flags & o.WRONLY == o.WRONLY) || (flags & o.APPEND == o.APPEND)) ?
        false : true;
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

    function open_args_to_opts(open_args) {
      #{
        opts = {}
        `open_args`.each do |arg|
          if arg.is_a?(::String)
            opts[:mode] = arg
          elsif arg.is_a?(::Hash)
            opts[:binmode] = arg[:binmode] if arg.key?(:binmode)
            opts[:textmode] = arg[:textmode] if arg.key?(:textmode)
            opts[:encoding] = arg[:encoding] if arg.key?(:encoding)
            opts[:flags] = arg[:flags] if arg.key?(:flags)
            opts[:mode] = arg[:mode] if arg.key?(:mode)
            opts[:perm] = arg[:perm] if arg.key?(:perm)
          end
        end
      }
      return opts;
    }

    function common_read(p, l, f, o, binary) {
      // that return works because begin ... ensure ... end is wrapped in (function())()
      return #{
        begin
          path = `p`; length = `l`; offset = `f`; opts = `o`
          path = `$coerce_to_or_raise(path, Opal.String, "to_path")`
          raise(::NotImplementedError, "read with '|' is not available") if path[0] == '|'

          open_args = opts[:open_args]
          opts = `open_args_to_opts(open_args)` if open_args

          opts[:path] = path
          opts[:binmode] = true if `binary`

          raise(::Errno::EISDIR) if File.directory?(path)
          fd = `$platform.io_open_path(path.toString(), #{::File::Constants::RDONLY})`
          io = IO.new(fd, nil, **opts)
          io.pos = offset unless offset.nil?
          io.read(length)
        ensure
          io&.close
        end
      }
    }

    function common_write(p, d, f, o, binary) {
      // that return works because begin ... ensure ... end is wrapped in (function())()
      return #{
        begin
          path = `p`; data = `d`; offset = `f`; opts = `o`
          path = `$coerce_to_or_raise(path, Opal.String, "to_path")`
          raise(::NotImplementedError, "write with '|' is not available") if path[0] == '|'

          if offset.is_a?(::Hash) && !opts.empty?
            offset = nil
          elsif offset.is_a?(::Hash)
            opts = offset
            offset = nil
          elsif offset
            offset = `$coerce_to_or_raise(offset, Opal.Integer, "to_int")`
          end
          offset_given = offset && offset >= 0

          flags = nil

          open_args = opts[:open_args]
          opts = `open_args_to_opts(open_args)` if open_args

          opts[:path] = path
          mode = opts[:mode]

          if mode
            mode = `$coerce_to_or_nil(mode, Opal.String, "to_str")` || mode
            flags = if mode.is_a?(::String)
                      mode = mode.split(':').first if mode.include?(':')
                      raise(ArgumentError, 'mode is a empty string') if mode.empty?
                      raise(::IOError, 'not opened for writing') if mode == 'r'
                      `Opal.mode_to_flags(mode)`
                    else
                      `$coerce_to_or_raise(mode, Opal.Integer, "to_int")`
                    end
          end

          unless open_args
            opt_flags = opts[:flags]
            flags = flags ? flags | opt_flags : opt_flags if opt_flags
            flags ||= ::File::Constants::WRONLY | ::File::Constants::CREAT

            unless offset_given || (flags & ::File::Constants::APPEND == ::File::Constants::APPEND)
              flags |= ::File::Constants::TRUNC
            end
            flags |= ::File::Constants::WRONLY if `flags_readonly(flags)`
            opts[:flags] = flags
          end

          perm = opts[:perm]
          perm = perm ? `$coerce_to_or_raise(perm, Opal.Integer, "to_int")` : 0o666

          fd = `$platform.io_open_path(path.toString(), flags, perm)`
          io = IO.new(fd, nil, **opts)
          io.binmode if `binary`
          io.pos = offset if offset_given
          io.write(data)
        ensure
          io&.close
        end
      }
    }
  }

  class << self
    if `$platform.io_open_path`
      def binread(path, length = nil, offset = 0, **opts)
        # Behaves like IO.read, except that the stream is opened in binary mode with ASCII-8BIT encoding.
        `common_read(path, length, offset, opts, true)`
      end

      def binwrite(path, data, offset = nil, **opts)
        # Behaves like IO.write, except that the stream is opened in binary mode with ASCII-8BIT encoding.
        `common_write(path, data, offset, opts, true)`
      end
    else
      alias binread __not_implemented__
      alias binwrite __not_implemented__
    end

    if `$platform.io_open_path`
      def copy_stream(src, dst, src_length = nil, src_offset = nil)
        # Copies from the given src to the given dst, returning the number of bytes copied.
        src_opened = dest_opened = rpartial = false
        src = src.to_path if !src.is_a?(::IO) && src.respond_to?(:to_path)
        src_io = if src.is_a?(String)
                   fd = `$platform.io_open_path(src.toString(), #{::File::Constants::RDONLY})`
                   src_opened = true
                   IO.new(fd, 'r')
                 else
                   rpartial = if src.respond_to?(:read)
                                false
                              elsif src.respond_to?(:readpartial)
                                true
                              else
                                raise TypeError, 'src must respond to :read or :readpartial'
                              end
                   src
                 end
        dst = dst.to_path if !dst.is_a?(::IO) && dst.respond_to?(:to_path)
        dst_io = if dst.is_a?(String)
                   fd = `$platform.io_open_path(dst.toString(), #{::File::Constants::CREAT | ::File::Constants::WRONLY})`
                   dest_opened = true
                   IO.new(fd, 'w')
                 else
                   raise TypeError, 'dst must respond to :write' unless dst.respond_to?(:write)
                   dst
                 end

        bsizes = [src_io, dst_io].map do |io|
          size = io.stat.blksize if io.respond_to?(:stat)
          size && size > 0 ? size : 1024
        end

        bsize = bsizes.min
        bsize = [bsize, src_length].min if src_length
        total_bytes = 0
        if src_offset
          raise(::Errno::ESPIPE) if src_io.respond_to?(:stat) && src_io.stat.pipe?
          src_orig_pos = src_io.pos if !src_opened && src_io.respond_to?(:pos)
          src_io.pos = src_offset
        end

        begin
          bsize = src_length - total_bytes if src_length && (total_bytes + bsize) > src_length
          data = if rpartial
                   src_io.readpartial(bsize, nil) rescue nil
                 else
                   src_io.read(bsize, nil)
                 end
          total_bytes += dst_io.write(data) if data
        end while data && (!src_length || (total_bytes < src_length))

        total_bytes
      ensure
        src_io.pos = src_orig_pos if src_offset && !src_opened && src_io.respond_to?(:pos=)
        src_io&.close if src_opened
        dst_io&.close if dest_opened
      end
    else
      alias copy_stream __not_implemented__
    end

    alias for_fd new # Synonym for IO.new.

    if `$platform.io_open_path`
      def foreach(path, sep = $/, limit = nil, **opts, &block)
        # Calls the block with each successive line read from the stream.
        path = `$coerce_to_or_raise(#{path}, Opal.String, "to_path")`

        if sep.is_a?(::Integer) && limit.nil?
          limit = sep
          sep = $/
        end
        sep = `$coerce_to_or_raise(sep, Opal.String, "to_str")` if sep

        if limit
          limit = `$coerce_to_or_raise(limit, Opal.Integer, "to_int")`
          if limit < 0
            limit = nil
          elsif limit == 0
            raise(ArgumentError, 'limit must be greater than 0')
          end
        end

        return enum_for(:foreach, path, sep, limit, **opts) unless block_given?

        begin
          mode = opts.delete(:mode)
          mode = mode ? mode.split(':').first : 'r'
          flags = `Opal.mode_to_flags(mode)`
          fd = `$platform.io_open_path(path.toString(), flags)`
          chomp = opts.delete(:chomp)
          opts[:path] = path
          io = new(fd, mode, **opts)
          io.each(sep, limit, chomp: chomp, &block)
          $_ = nil
        ensure
          io&.close
        end
      end
    else
      alias foreach __not_implemented__
    end

    def open(fd, mode, **opts)
      # Creates a new IO object, via IO.new with the given arguments.
      # With no block given, returns the IO object.
      # With a block given, calls the block with the IO object and returns the block’s value.
      io = new(fd, mode, **opts)
      return io unless block_given?
      begin
        yield(io)
      ensure
        begin
          io.close
        rescue IOError
          nil
        end
      end
    end

    if `$platform.io_pipe`
      def pipe(ext_enc = nil, int_enc = nil, **opts)
        # Creates a pair of pipe endpoints, read_io and write_io, connected to each other.
        if ext_enc && !ext_enc.is_a?(::Encoding)
          ext_enc = `$coerce_to_or_raise(ext_enc, Opal.String, "to_str")`
          ext_enc, int_enc = ext_enc.split(':') if int_enc.nil?
          bom, ext_enc = ext_enc.split('|') if ext_enc.include?('|')
          ext_enc = ::Encoding.find(ext_enc)
        end
        if int_enc && !int_enc.is_a?(::Encoding)
          int_enc = `$coerce_to_or_raise(int_enc, Opal.String, "to_str")`
          int_enc = ::Encoding.find(int_enc)
        end

        ext_enc ||= Encoding.default_external
        int_enc ||= Encoding.default_internal
        int_enc = nil if ext_enc == int_enc

        read_fd, write_fd = `$platform.io_pipe()`

        write_io = allocate
        write_io.initialize(write_fd, 'w')
        write_io.set_encoding(nil)
        write_io.instance_variable_set(:@pipe, true)

        read_io = allocate
        read_io.initialize(read_fd, 'r', external_encoding: ext_enc, internal_encoding: int_enc)
        read_io.instance_variable_set(:@pipe, true)

        return [read_io, write_io] unless block_given?
        begin
          yield read_io, write_io
        ensure
          read_io.close
          write_io.close
        end
      end
    else
      alias pipe __not_implemented__
    end

    if `$platform.io_popen`
      def popen(env = {}, cmd = nil, mode = nil, **opts)
        # Executes the given command cmd as a subprocess whose $stdin and $stdout are connected to a new stream io.
        js_opts = `{ stdio: 'pipe' }`
        args = `null`
        if env.is_a?(Hash)
          `js_opts.env = {}`
          env.each { |k, v| `js_opts.env[k.toString()] = v.toString()` }
        else
          mode = cmd if mode.nil? && cmd
          cmd = env
          env = nil
        end
        if cmd.is_a?(Array)
          command = cmd.shift
          args = cmd.map { |a| `a.toString()` }
          cmd = command
        end
        raise(::NotImplementedError, "popen with fork '-' is not available") if cmd == '-'
        mode = mode ? `$coerce_to_or_raise(mode, Opal.String, "to_str")` : 'r'
        `js_opts.shell = true`
        `js_opts.cwd = #{opts[:chdir]}` if opts.key?(:chdir)
        if opts.key?(:err)
          err = opts[:err]
          `js_opts.err = 'out'` if err.is_a?(::Array) && err[0] == :child && (err[1] == :out || err[1] == 1)
        end
        fd, pid = `$platform.io_popen(cmd.toString(), args, mode.toString(), js_opts)`
        # $? = ::Process::Status.new(nil, pid)
        io = new(fd, mode, **opts)
        `io.pid = pid`
        `io.pipe = true`
        return io unless block_given?
        begin
          yield io
        ensure
          io.close
        end
      end
    else
      alias popen __not_implemented__
    end

    def read(path, length = nil, offset = 0, **opts)
      # Opens the stream, reads and returns some or all of its content, and closes the stream;
      # returns nil if no bytes were read.
      `common_read(path, length, offset, opts, false)`
    end

    if `$platform.io_open_path`
      def readlines(path, sep = $/, limit = nil, **opts)
        # Returns an array of all lines read from the stream.
        path = `$coerce_to_or_raise(#{path}, Opal.String, "to_path")`

        if sep.is_a?(::Integer) && limit.nil?
          limit = sep
          sep = $/
        end
        sep = `$coerce_to_or_raise(sep, Opal.String, "to_str")` if sep

        if limit
          limit = `$coerce_to_or_raise(limit, Opal.Integer, "to_int")`
          if limit < 0
            limit = nil
          elsif limit == 0
            raise(ArgumentError, 'limit must be greater than 0')
          end
        end
        mode = opts.delete(:mode)
        mode = mode ? mode.split(':').first : 'r'
        flags = `Opal.mode_to_flags(mode)`
        fd = `$platform.io_open_path(path.toString(), flags)`
        chomp = opts.delete(:chomp)
        opts[:path] = path
        io = new(fd, mode, **opts)
        io.readlines(sep, limit, chomp: chomp)
      ensure
        io&.close
      end
    else
      alias readlines __not_implemented__
    end

    # Invokes system call select(2), which monitors multiple file descriptors,
    # waiting until one or more of the file descriptors becomes ready for some class of I/O operation.
    alias select __not_implemented__

    if `$platform.io_open_path`
      def sysopen(path, mode = nil, perm = nil)
        # Opens the file at the given path with the given mode and permissions; returns the integer file descriptor.
        path = `$coerce_to_or_raise(path, Opal.String, "to_path")`
        mode = mode ? mode.split(':').first : 'r'
        perm ||= 0o666
        flags = `Opal.mode_to_flags(mode)`
        `$platform.io_open_path(path.toString(), flags, perm)`
      end
    else
      alias sysopen __not_implemented__
    end

    def try_convert(object)
      # Attempts to convert object into an IO object via method to_io; returns the new IO object if successful, or nil otherwise:
      `$coerce_to_or_nil(object, #{::IO}, "to_io")`
    end

    if `$platform.io_open_path`
      def write(path, data, offset = nil, **opts)
        # Opens the stream, writes the given data to it, and closes the stream; returns the number of bytes written.
        `common_write(path, data, offset, opts, false)`
      end
    else
      alias write __not_implemented__
    end
  end

  def initialize(fd, mode = nil, opts = {})
    # Creates and returns a new IO object (file stream) from a file descriptor.
    # flags should be mode

    raise(ArgumentError, 'opts must be a Hash') unless opts.is_a?(::Hash)
    if mode.is_a?(::Hash)
      opts = mode
      mode = nil
    end

    @autoclose = !!opts.fetch(:autoclose, true)
    @buffer = IO::Buffer.new
    fd = `$coerce_to_or_raise(#{fd}, Opal.Integer, "to_int")`
    raise(Errno::EBADF) if fd < 0
    @fd = fd
    @close_on_exec = @fd > 2
    @sync = @fd == 2
    @nonblock = false
    @lineno = 0
    @pos = 0

    @path = opts[:path]

    flags = opts[:flags] || 0
    arg_mode = mode
    @binmode = ext_enc = int_enc = textmode = mode = nil

    [arg_mode, opts[:mode]].each do |m|
      if m
        raise(ArgumentError, 'mode given multiple times') if mode
        m = `$coerce_to_or_nil(m, Opal.String, "to_str")` || m
        if m.is_a?(::String)
          m, ext_enc, int_enc = m.split(':') if m.include?(':')
          raise(ArgumentError, 'mode is a empty string') if m.empty?
          @binmode = m.include?('b')
          textmode = m.include?('t') # only used for args checking
          if (@binmode || textmode) && (opts.key?(:binmode) || opts.key?(:textmode))
            raise(ArgumentError, 'mode given multiple times')
          end
          mode = m
          flags |= `Opal.mode_to_flags(mode)`
        else
          flags |= `$coerce_to_or_raise(m, Opal.Integer, "to_int")`
        end
      end
    end

    @binmode ||= !!opts[:binmode]
    textmode ||= !!opts[:textmode]

    raise(ArgumentError, 'choose either binmode or textmode') if @binmode && textmode

    if flags & ::File::Constants::RDWR == ::File::Constants::RDWR
      @opened = :duplex
    elsif flags & ::File::Constants::WRONLY == ::File::Constants::WRONLY
      @opened = :write
      @closed = :read
    else
      @opened = :read
      @closed = :write
    end
    @flags = flags # need to store flags for #reopen

    if ext_enc && (opts.key?(:encoding) || opts.key?(:external_encoding))
      raise(ArgumentError, 'encoding specified twice')
    end

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

    use_bom = false

    if ext_enc && !ext_enc.is_a?(::Encoding)
      ext_enc = `$coerce_to_or_raise(ext_enc, Opal.String, "to_str")`
      ext_enc, int_enc = ext_enc.split(':') if ext_enc.include?(':')
      if ext_enc.start_with?('BOM|')
        use_bom = true
        _, ext_enc = ext_enc.split('|')
      end
      ext_enc = ::Encoding.find(ext_enc)
    end

    if opts.key?(:internal_encoding)
      raise(ArgumentError, 'internal encoding given multiple times') if int_enc
      int_enc = opts[:internal_encoding]
    end

    set_encoding_by_bom if use_bom

    @ext_enc ||= if ext_enc || (enc_def_int.nil? && mode == 'r')
                   ext_enc
                 elsif @binmode
                   ::Encoding::BINARY
                 elsif enc_def_int.nil?
                   nil
                 else
                   enc_def_ext
                 end

    if int_enc && !int_enc.is_a?(::Encoding)
      int_enc = `$coerce_to_or_raise(int_enc, Opal.String, "to_str")`
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
    raise(::ArgumentError, 'newline decorator with binary mode') if nl && @binmode
    @write_lsep = if nl == :cr
                    "\r"
                  elsif nl == :crlf
                    "\r\n"
                  else
                    "\n"
                  end

    @tty, @pipe, @file = `$platform.io_open(self.fd, self.flags)` if @fd
  end

  def <<(object)
    # Writes the given object to self, which must be opened for writing (see Access Modes);
    # returns self; if object is not a string, it is converted via method to_s:
    write(object)
    self
  end

  def advise(advice, offset = 0, len = 0)
    # Invokes Posix system call posix_fadvise(2), which announces an intention to access
    # data from the current file in a particular manner.
    `check_open(self)`
    raise(TypeError, 'advice must be a Symbol') unless advice.is_a?(::Symbol)
    offset = `$coerce_to_or_raise(offset, Opal.Integer, "to_int")`
    len = `$coerce_to_or_raise(len, Opal.Integer, "to_int")`
    raise NotImplementedError unless %i[dontneed noreuse normal random sequential willneed wontneed].include?(advice)
    # just a noop here until engines provide APIs accordingly
    nil
  end

  def autoclose=(bool)
    # Sets auto-close flag.
    @autoclose = !!bool
  end

  def autoclose?
    # Returns true if the underlying file descriptor of ios will be closed at its finalization or at calling close,
    # otherwise false.
    @autoclose
  end

  def binmode
    # Sets the stream’s data mode as binary
    `check_open(self)`
    @ext_enc = ::Encoding::BINARY
    @int_enc = nil
    @binmode = true
    self
  end

  def binmode?
    # Returns true if the stream is on binary mode, false otherwise.
    `check_open(self)`
    @binmode
  end

  def close
    # Closes the stream for both reading and writing if open for either or both; returns nil.
    return if closed?
    status = `$platform.io_close(self.fd)` if @fd && autoclose?
    if status
      # must have been a #popen
      $? = ::Process::Status.new(`{ status: status, flags: 4 }`, @pid)
    end
    @closed = :both
    @pid = nil
    nil
  end

  def close_on_exec=(bool)
    # Sets a close-on-exec flag.
    raise ::IOError if closed?
    @close_on_exec = !!bool
  end

  def close_on_exec?
    # Returns true if the stream will be closed on exec, false otherwise.
    raise ::IOError if closed?
    @close_on_exec
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

  def each(sep = $/, limit = nil, chomp: false)
    # Calls the block with each remaining line read from the stream; returns self.
    if !sep.nil? && limit.nil? && sep.is_a?(::Numeric)
      limit = sep
      sep = $/
    end
    raise(ArgumentError, 'if limit is given, it must be greater than 0') if limit && limit < 1

    return enum_for(:each, sep, limit, chomp: chomp) unless block_given?

    global_last_line = $_

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

  def each_char
    # Calls the given block with each character in the stream; returns self.
    return enum_for :each_char unless block_given?
    while (chr = getc)
      yield(chr)
    end
    self
  end

  def each_codepoint
    # Calls the given block with each codepoint in the stream; returns self
    return enum_for :each_codepoint unless block_given?
    while (chr = getc)
      yield(chr.ord)
    end
    self
  end

  alias each_line each

  if `$platform.io_pipe_eof`
    def eof
      # Returns true if the stream is positioned at its end, false otherwise;
      `check_readable(self)`
      return stat.size <= @pos if @file
      return `$platform.io_pipe_eof(self.fd)` if @pipe
      false
    end
    alias eof? eof
  else
    alias eof __not_implemented__
  end

  alias eof? eof

  def external_encoding
    # Returns the Encoding object that represents the encoding of the stream,
    # or nil if the stream is in write mode and no encoding is specified.
    return @ext_enc if @opened != :read
    @ext_enc || ::Encoding.default_external
  end

  def fcntl(integer_cmd, argument = nil)
    # Invokes Posix system call fcntl(2), which provides a mechanism for issuing low-level commands to
    # control or query a file-oriented I/O stream. Arguments and results are platform dependent.
    `check_open(self)`
    case integer_cmd
    when 1
      flags = 0
      flags |= 1 if close_on_exec?
      return flags
    end
    -1
  end

  if `$platform.io_fdatasync`
    def fdatasync
      # Immediately writes to disk all data buffered in the stream, via the operating system’s: fdatasync(2),
      # if supported, otherwise via fsync(2), if supported; otherwise raises an exception.
      `check_open(self)`
      `$platform.io_fdatasync(self.fd)`
      0
    end
  else
    alias fdatasync __not_implemented__
  end

  def fileno
    # Returns the integer file descriptor for the stream.
    `check_open(self)`
    @fd
  end

  def flush
    # Flushes data buffered in self to the operating system
    # (but does not necessarily flush data buffered in the operating system)
    `check_open(self)`
    # noop
    self
  end

  if `$platform.io_fsync`
    def fsync
      # Immediately writes to disk all data buffered in the stream, via the operating system’s fsync(2).
      # Raises an exception if the operating system does not support fsync(2).
      `check_open(self)`
      `$platform.io_fsync(self.fd)`
      0
    end
  else
    alias fsync __not_implemented__
  end

  if `$platform.io_read`
    def getbyte
      # Reads and returns the next byte (in range 0..255) from the stream; returns nil if already at end-of-stream.
      `check_readable(self)`
      return nil if eof
      bytes_read = `$platform.io_read(self.fd, self.buffer, 0, self.pos, 1, self.file)`
      @pos += bytes_read
      return `self.buffer.data_view.getUint8(0)` if bytes_read > 0
      nil
    end
  else
    alias getbyte __not_implemented__
  end

  if `$platform.io_read`
    def getc
      # Reads and returns the next 1-character string from the stream; returns nil if already at end-of-stream.
      `check_readable(self)`
      return nil if eof

      # allow for multi byte characters with up to 16 bytes
      bytes_read = `$platform.io_read(self.fd, self.buffer, 0, self.pos, 16, self.file)`
      return nil if bytes_read < 1
      chr = @buffer.get_raw_string(0, 16, @ext_enc, false)
      chr = chr[0] # the first one should be valid
      @pos += chr.bytesize
      chr
    end
  else
    alias getc __not_implemented__
  end

  if `$platform.io_read`
    def gets(sep = $/, limit = nil, chomp: false)
      # Reads and returns a line from the stream; assigns the return value to $_.
      `check_readable(self)`
      return $_ = nil if eof

      paragraph_mode = false

      if sep
        if limit.nil? && !sep.is_a?(::String)
          begin
            limit = `$coerce_to_or_raise(sep, Opal.Integer, "to_int")`
            sep = $/
          rescue
            sep = `$coerce_to_or_raise(sep, Opal.String, "to_str")`
          end
        elsif sep == ''
          sep = $/
          paragraph_mode = true
        else
          sep = `$coerce_to_or_raise(sep, Opal.String, "to_str")`
        end
      end

      limit = limit.nil? ? `Infinity` : `$coerce_to_or_raise(limit, Opal.Integer, "to_int")`
      if limit < 0
        limit = `Infinity`
      elsif limit == 0
        return `$str('', self.ext_enc)`
      end

      # get separator as bytes in external encoding
      if sep
        sep_bytes = `$str(sep, self.ext_enc)`.bytes
        sep_len = sep_bytes.size
      else
        sep_len = 0
      end
      bytes_read = 0
      total_bytes_read = 0
      buffer_size = @buffer.size
      read_len = @tty || @pipe ? 1 : `(limit == 0) ? buffer_size : Math.min(limit, buffer_size)`
      start_pos = temp_pos = @pos
      sep_pos = 0
      found_sep = false
      i = 0
      check_rn = `(sep === '\n') ? true : false`

      # Read additional up to 16 bytes above limit into the buffer to
      # account for multi byte character combinations that may have been
      # cut off. These are only for @buffer.get_raw_string to be able to
      # return a valid string, so don't count these bytes later on.
      real_read_len = @tty || @pipe ? 1 : `Math.min(read_len + 16, buffer_size)`

      while true
        # fill buffer
        dv = `self.buffer.data_view`
        temp_pos += bytes_read
        bytes_read = `$platform.io_read(self.fd, self.buffer, total_bytes_read, temp_pos, real_read_len, self.file)`
        bytes_read = read_len if bytes_read > read_len # Don't count the extra 16 bytes
        if bytes_read > 0
          total_bytes_read += bytes_read
          # lets look for the separator bytes
          # [possible optimization: use Uint8Array with its indexOf()]
          if sep
            %x{
              for (i = total_bytes_read - bytes_read; i < total_bytes_read; i++) {
                found_sep = is_sep(sep_bytes, sep_len, dv, i, check_rn);
                if (found_sep) {
                  // chomp pos, end of text, beginning of separator
                  sep_pos = i;
                  // end of separator, maybe beginning of next separtor or text
                  i += sep_len;
                  if (check_rn && 13 === dv.getUint8(sep_pos) && 10 === dv.getUint8(i)) i++;
                  if (paragraph_mode) { // check for second separator
                    if (i < total_bytes_read && is_sep(sep_bytes, sep_len, dv, i, check_rn)) {
                      i += sep_len;
                      if (check_rn && 13 === dv.getUint8(sep_pos) && 10 === dv.getUint8(i)) i++;
                    } else {
                      found_sep = false;
                      // special case if a sep has been found at the end that is not a paragraph sep
                      if (i >= total_bytes_read) break;
                    }
                  }
                  if (found_sep) break;
                }
              }
            }
          else
            i = total_bytes_read
          end
        end
        if found_sep || bytes_read < read_len || limit <= total_bytes_read
          str_end = found_sep && chomp ? sep_pos : i
          str_len = `Math.min(limit, str_end)`
          line = @buffer.get_raw_string(0, str_len, @ext_enc || ::Encoding.default_external, true)
          if paragraph_mode
            # skip additional empty paragraphs
            `while(i < total_bytes_read && is_sep(sep_bytes, sep_len, dv, i)) { i += sep_len }`
          end
          @pos = start_pos + +`((limit === Infinity) ? i : Math.max(line.$bytesize(), i))`
          break
        elsif total_bytes_read == @buffer.size
          # skip back a bit to correctly identify separator/paragraph across buffer border
          i -= sep_len
          @buffer.resize(@buffer.size + buffer_size)
        end
      end

      unless line.nil?
        if @int_enc
          line.force_encoding(@int_enc)
        elsif ::Encoding.default_internal &&
              (@ext_enc != ::Encoding::BINARY || ::Encoding.default_external != ::Encoding::BINARY)
          line.force_encoding(::Encoding.default_internal)
        end

        @lineno += 1
      end

      $. = @lineno
      $_ = line unless sep == ' '
      line
    ensure
      # shrink buffer to original size, freeing memory
      @buffer.resize(`DEFAULT_BUFFER_SIZE`) if @buffer.size != `DEFAULT_BUFFER_SIZE`
    end
  else
    alias gets __not_implemented__
  end

  if `$platform.io_open && $platform.io_open_path`
    def initialize_copy(other)
      `check_open(other)`

      @fd = `$platform.io_open_path(self.path.toString(), self.flags)` if path
      @tty = `$platform.io_open(self.fd, self.flags)` if @fd

      @autoclose = true
      @close_on_exec = true
    end
  else
    alias initialize_copy __not_implemented__
  end

  def inspect
    # Returns a string representation of self.
    "<#{self.class.name}:fd #{@fd}#{' (closed)' if closed?}>"
  end

  def internal_encoding
    # Returns the Encoding object that represents the encoding of the internal string,
    # if conversion is specified, or nil otherwise.
    @int_enc
  end

  if `$platform.ioctl`
    def ioctl(integer_cmd, argument)
      # Invokes Posix system call ioctl(2), which issues a low-level command to an I/O device.
      `check_open(self)`
      `$platform.ioctl(integer_cmd, argument)`
    end
  else
    alias ioctl __not_implemented__
  end

  def isatty
    # Returns true if the stream is associated with a terminal device (tty), false otherwise.
    `check_open(self)`
    @tty
  end

  def lineno
    # Returns the current line number for the stream.
    `check_readable(self)`
    @lineno
  end

  def lineno=(number)
    # Sets and returns the line number for the stream.
    `check_readable(self)`
    number = `$coerce_to_or_raise(number, Opal.Integer, "to_int")` unless number.is_a?(::Numeric)
    number = number.floor if number.is_a?(::Float)
    @lineno = number
  end

  def path
    # Returns the path associated with the IO, or nil if there is no path associated with the IO.
    # It is not guaranteed that the path exists on the filesystem.
    `$str(self.path, self.path.$encoding())` if @path
  end

  def pathconf(p1)
    nil
  end

  def pid
    # Returns the process ID of a child process associated with the stream,
    # which will have been set by IO#popen, or nil if the stream was not created by IO#popen.
    `check_open(self)`
    @pid
  end

  def pos
    # Returns the current position (in bytes) in self
    `check_open(self)`
    @pos
  end

  def pos=(number)
    # Seeks to the given new_position (in bytes).
    `check_open(self)`
    number = `$coerce_to_or_raise(#{number}, Opal.Integer, "to_int")`
    raise(Errno::EINVAL, 'position must be >= 0') if number < 0
    fsz = stat.size
    @pos = number
  end

  if `$platform.io_read`
    def pread(length, offset, out_string = nil)
      # Behaves like IO#readpartial, except that it:
      # - Reads at the given offset (in bytes).
      # - Disregards, and does not modify, the stream’s position (see Position).
      # - Bypasses any user space buffering in the stream.
      if out_string
        # requires mutable Strings
        raise NotImplementedError, 'out_string buffer is currently not supported'
      end

      `check_readable(self)`
      raise(::ArgumentError, 'invalid length') if length && length < 0

      enc = ::Encoding::BINARY
      return `$str('', enc)` if length == 0

      # the true limit will be the smaller of:
      # - max JS String size, which is Number.MAX_SAFE_INTEGER
      # - max ArrayBuffer size, which is implementation dependend
      read_end = length.nil? ? `Infinity` : offset + length
      read_len = @buffer.size
      bytes_read = 0
      total_bytes_read = 0
      while offset < read_end
        read_len = read_end - offset if (offset + read_len) > read_end
        s = @buffer.size
        @buffer.resize(s + read_len) if s < (total_bytes_read + read_len)
        bytes_read = `$platform.io_read(self.fd, self.buffer, total_bytes_read, offset, read_len, self.file)`
        total_bytes_read += bytes_read
        offset += bytes_read
        raise(::EOFError) if bytes_read < read_len
      end
      return `$str('', enc)` if bytes_read == 0
      @buffer.get_raw_string(0, total_bytes_read, enc, false)
    ensure
      # shrink buffer to original size, freeing memory
      @buffer.resize(`DEFAULT_BUFFER_SIZE`) if @buffer.size != `DEFAULT_BUFFER_SIZE`
    end
  else
    alias pread __not_implemented__
  end

  def print(*objects)
    # Writes the given objects to the stream; returns nil. Appends the output record
    # separator $OUTPUT_RECORD_SEPARATOR ($\), if it is not nil.
    `check_writable(self)`
    objects = [$_] if objects.empty?
    lidx = objects.size - 1
    wsep = $, || $\
    objects.each_with_index do |object, idx|
      idx == lidx ? write(object) : write(object, wsep)
    end
    write($\) if $\
    nil
  end

  def printf(format_string, *objects)
    # Formats and writes objects to the stream.
    `check_writable(self)`
    write format(format_string, *objects)
    nil
  end

  def putc(object)
    # Writes a character to the stream.
    `check_open(self)`
    c = if object.is_a?(::String)
          object[0]
        else
          raise(TypeError, 'object of wrong type') unless object.respond_to?(:to_int)
          obj = object.to_int
          code = `obj & 0xff`
          code.chr
        end
    write c
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
        arg = `$coerce_to_or_nil(arg, Opal.Array, "to_ary")` || arg
        if arg.is_a?(Array)
          unless arg.empty?
            ary = arg.flatten rescue arg
            ary.each do |a|
              if a == arg
                write('[...]')
              else
                puts a
              end
            end
          end
        else
          line = `$coerce_to_or_raise(arg, Opal.String, "to_s")`
          line += @write_lsep unless line.end_with?("\n")
          write(line)
        end
      end
    end
    nil
  end

  def pwrite(object, offset)
    # Behaves like IO#write, except that it:
    # Writes at the given offset (in bytes).
    # Disregards, and does not modify, the stream’s position (see Position).
    # Bypasses any user space buffering in the stream.
    `check_writable(self)`
    string = `$coerce_to_or_raise(object, Opal.String, "to_s")`
    total_wsize = 0
    ext_enc = if @ext_enc
                @ext_enc
              elsif @binmode # || string.binary_encoding == ::Encoding::BINARY
                string.binary_encoding
              else
                ::Encoding.default_external
              end
    if offset > 0
      fsz = stat.size
      if fsz < offset
        s_dif = offset - fsz
        e_buf = ::IO::Buffer.new(s_dif)
        total_wsize = `$platform.io_write(self.fd, e_buf, 0, fsz, s_dif)`
      end
    end
    ext_enc.each_byte_buffer(string, @buffer) do |write_len|
      bytes_written = `$platform.io_write(self.fd, self.buffer, 0, offset, write_len)`
      raise IOError, 'could not write all data' if bytes_written < write_len
      offset += write_len
      total_wsize += write_len
    end
    total_wsize
  end

  if `$platform.io_read`
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
        xenc = ::Encoding::BINARY
        binm = true
        return nil if eof
      else
        xenc = @ext_enc || ::Encoding.default_external
        return `$str('', xenc)` if eof
        binm = @binmode
        length = `Infinity`
      end

      # the true length limit will be the smaller of:
      # - max JS String size, which is Number.MAX_SAFE_INTEGER
      # - max ArrayBuffer size, which is implementation dependent
      read_end = @pos + length
      read_len = @buffer.size
      bytes_read = 0
      total_bytes_read = 0
      while @pos < read_end
        read_len = read_end - @pos if (@pos + read_len) > read_end
        s = @buffer.size
        @buffer.resize(s + read_len) if s < (total_bytes_read + read_len)
        bytes_read = `$platform.io_read(self.fd, self.buffer, total_bytes_read, self.pos, read_len, self.file)`
        total_bytes_read += bytes_read
        @pos += bytes_read
        break if bytes_read < read_len
      end
      return `$str('', xenc)` if length && `length !== Infinity` && bytes_read == 0
      result = @buffer.get_raw_string(0, total_bytes_read, xenc, false)
      result.force_encoding(@int_enc) if @int_enc && !binm
      result
    ensure
      # shrink buffer to original size, freeing memory
      @buffer.resize(`DEFAULT_BUFFER_SIZE`) if @buffer.size != `DEFAULT_BUFFER_SIZE`
    end

    def readbyte
      # Reads and returns the next byte (in range 0..255) from the stream;
      # raises EOFError if already at end-of-stream.
      `check_readable(self)`
      b = getbyte
      raise ::EOFError if eof
      b
    end

    def readchar
      # Reads and returns the next 1-character string from the stream; raises EOFError if already at end-of-stream.
      `check_readable(self)`
      c = getc
      raise ::EOFError if eof
      if @binmode
        `$str(c, #{::Encoding::BINARY})`
      elsif @int_enc
        `$str(c, self.int_enc)`
      elsif @ext_enc
        `$str(c, self.ext_enc)`
      else
        c
      end
    end

    def readline(sep = $/, limit = nil, chomp: false)
      # Reads a line as with IO#gets, but raises EOFError if already at end-of-stream.
      ::Kernel.raise(::EOFError, 'end of file reached') if eof
      gets(sep, limit, chomp: chomp)
    end

    def readlines(sep = $/, limit = nil, chomp: false)
      # Reads and returns all remaining line from the stream; does not modify $_.
      `check_readable(self)`

      global_last_line = $_
      res = each(sep, limit, chomp: chomp).to_a
      $_ = global_last_line unless sep == $/
      res
    end

    def readpartial(length, out_string = nil)
      # Reads up to length bytes from the stream; returns a string (either a new string or the given out_string).
      sysread(length, out_string)
    end

    def set_encoding_by_bom
      # If the stream begins with a BOM (byte order marker),
      # consumes the BOM and sets the external encoding accordingly;
      # returns the result encoding if found, or nil otherwise
      return nil if @opened == :write || @closed == :read || closed?
      raise(ArgumentError, 'ASCII incompatible encoding needs binmode') unless @binmode
      raise(ArgumentError, 'encoding conversion is set') if @ext_enc && @int_enc

      encoding = nil

      # read up to 4 bytes
      bytes_read = `$platform.io_read(self.fd, self.buffer, 0, 0, 4, self.file)`

      # get the read bytes
      bom = []
      @buffer.each_byte(0, bytes_read) do |byte|
        bom << byte
      end

      if bom.size == 4
        # check for 4 byte BOMS
        encoding = case bom
                   when [0x00, 0x00, 0xFE, 0xFF] then ::Encoding::UTF_32BE
                   when [0xFF, 0xFE, 0x00, 0x00] then ::Encoding::UTF_32LE
                   when [0xDD, 0x73, 0x66, 0x73] then false # UTF-EBCDIC
                   when [0x84, 0x31, 0x95, 0x33] then false # GB18030
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
                   end
        bom.pop if encoding.nil? # 3 -> 2
      end

      if bom.size == 2
        # check for 2 byte BOMS
        encoding = case bom
                   when [0xFE, 0xFF] then ::Encoding::UTF_16BE
                   when [0xFF, 0xFE] then ::Encoding::UTF_16LE
                   end
      end

      if encoding
        @pos = bom.size
        @ext_enc = encoding
        return encoding
      end

      nil
    end

    def sysread(length, out_string = nil)
      # Behaves like IO#readpartial, except that it uses low-level system functions.
      if out_string
        # requires mutable Strings
        raise NotImplementedError, 'out_string buffer is currently not supported'
      end

      `check_readable(self)`
      raise ::ArgumentError, 'invalid length' if length && length < 0

      enc = ::Encoding::BINARY
      return `$str('', enc)` if length == 0

      raise ::EOFError if eof

      # the true limit will be the smaller of:
      # - max JS String size, which is Number.MAX_SAFE_INTEGER
      # - max ArrayBuffer size, which is implementation dependend
      read_end = length.nil? ? `Infinity` : @pos + length
      read_len = @buffer.size
      bytes_read = 0
      total_bytes_read = 0
      while @pos < read_end
        read_len = read_end - @pos if (@pos + read_len) > read_end
        s = @buffer.size
        @buffer.resize(s + read_len) if s < (total_bytes_read + read_len)
        bytes_read = `$platform.io_read(self.fd, self.buffer, total_bytes_read, self.pos, read_len, self.file)`
        total_bytes_read += bytes_read
        @pos += bytes_read
        break if bytes_read < read_len
      end
      return `$str('', enc)` if bytes_read == 0
      @buffer.get_raw_string(0, total_bytes_read, enc, false)
    ensure
      # shrink buffer to original size, freeing memory
      @buffer.resize(`DEFAULT_BUFFER_SIZE`) if @buffer.size != `DEFAULT_BUFFER_SIZE`
    end
  else
    alias read __not_implemented__
    alias readbyte __not_implemented__
    alias readchar __not_implemented__
    alias readline __not_implemented__
    alias readlines __not_implemented__
    alias set_encoding_by_bom __not_implemented__
    alias sysread __not_implemented__
  end

  if `$platform.io_open_path`
    def reopen(path_or_io, mode = nil, **opts)
      # Reassociates the stream with another stream, which may be of a different class.
      # This method may be used to redirect an existing stream to a new destination.
      if path_or_io.is_a?(::IO)
        other_io = path_or_io
        path = nil
      elsif path_or_io
        other_io = `$coerce_to_or_nil(path_or_io, #{::IO}, "to_io")`
        path = `$coerce_to_or_raise(path_or_io, Opal.String, "to_path")` unless other_io
      end

      fsync if @fd && (@opened == :duplex || @opened == :write) && @closed != :write && !closed?

      if path
        mode = mode ? mode.split(':').first : 'r'
        `$platform.io_close(self.fd)` if @fd && !closed?
        begin
          @fd = `$platform.io_open_path(path.toString(), Opal.mode_to_flags(mode))`
        rescue Errno::ENOENT => e
          raise(e) unless @opened == :write || @opened == :duplex
          @fd = `$platform.io_open_path(path.toString(), Opal.mode_to_flags('w+'))`
        end
        @path = path
        @pos = 0
      elsif other_io
        raise(IOError, 'closed stream') if closed?
        raise(IOError, 'other closed stream') if other_io.closed?
        if (`other_io.opened` == :duplex || `other_io.opened` == :write) && `other_io.closed` != :write
          other_io.fsync
        end
        @path = other_io.path
        if @path
          `$platform.io_close(self.fd)` if @fd && !closed?
          begin
            @fd = `$platform.io_open_path(self.path.toString(), other_io.flags)`
          rescue Errno::ENOENT
            @fd = `$platform.io_open_path(self.path.toString(), Opal.mode_to_flags('w+'))`
          end
        else
          @fd = other_io.fileno
        end
        `self.pos = other_io.pos`
        `self.opened = other_io.opened`
        `self.binmode = other_io.binmode`
      elsif @path
        `$platform.io_close(self.fd)` if @fd && !closed?
        begin
          @fd = `$platform.io_open_path(path.toString(), self.flags)`
        rescue Errno::ENOENT
          @fd = `$platform.io_open_path(path.toString(), Opal.mode_to_flags('w+'))`
        end
      end

      if @opened == :duplex
        @closed = false
      elsif @opened == :read
        @closed = :write
      elsif @opened == :write
        @closed = :read
      end

      @binmode = binmode if binmode
      @close_on_exec = @fd > 2

      self
    end
  else
    alias reopen __not_implemented__
  end

  def rewind
    # Repositions the stream to its beginning, setting both the position and the line number to zero.
    `check_open(self)`
    @lineno = 0
    @pos = 0
  end

  def seek(offset, whence = SEEK_SET)
    # Seeks to the position given by integer offset (see Position) and constant whence.
    sysseek(offset, whence)
    0
  end

  def set_encoding(ext_enc, int_enc = nil, **enc_opts)
    if int_enc.is_a?(Hash)
      enc_opts = int_enc
      int_enc = nil
    end

    is_stdio = @fd && @fd < 3
    enc_def_int = ::Encoding.default_internal
    @ext_enc = if @binmode && @opened == :read
                 ::Encoding.default_external
               elsif ext_enc.nil? && (enc_def_int.nil? || is_stdio)
                 nil
               elsif ext_enc.nil?
                 ::Encoding.default_external
               elsif ext_enc.is_a?(::Encoding)
                 ext_enc
               else
                 ext_enc = `$coerce_to_or_raise(ext_enc, Opal.String, "to_str")`
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
                int_enc = `$coerce_to_or_raise(int_enc, Opal.String, "to_str")`
                ::Encoding.find(int_enc)
              end
    @int_enc = int_enc == @ext_enc ? nil : int_enc
    self
  end

  if `$platform.io_fstat`
    def stat
      # Returns status information for ios as an object of type File::Stat.
      `check_open(self)`
      ::File::Stat.new(@path, `$platform.io_fstat(self.fd)`)
    end
  else
    alias stat __not_implemented__
  end

  def sync
    # Returns the current sync mode of the stream. When sync mode is true,
    # all output is immediately flushed to the underlying operating system
    # and is not buffered by Ruby internally.
    `check_open(self)`
    @sync
  end

  def sync=(bool)
    # Sets the sync mode for the stream to the given value; returns the given value.
    `check_open(self)`
    @sync = !!bool
  end

  def sysseek(offset, whence = ::IO::SEEK_SET)
    # Behaves like IO#seek, except that it:
    # Uses low-level system functions.
    # Returns the new position.
    `check_open(self)`
    sz = stat.size
    offset = `$coerce_to_or_raise(#{offset}, Opal.Integer, "to_int")`
    if whence == SEEK_SET || whence == :SET
      raise Errno::EINVAL, 'wrong value for offset' if offset < 0
      new_pos = offset
    elsif whence == SEEK_CUR || whence == :CUR
      new_pos = @pos + offset
    elsif whence == SEEK_END || whence == :END
      new_pos = sz + offset
    elsif whence
      raise Errno::EINVAL, 'wrong value for whence'
    end
    @pos = new_pos
  end

  def syswrite(object)
    # Writes the given object to self, which must be opened for writing (see Modes);
    # returns the number bytes written. If object is not a string is converted via method to_s.
    `check_writable(self)`
    string = `$coerce_to_or_raise(object, Opal.String, "to_s")`
    total_wsize = 0
    string.binary_encoding.each_byte_buffer(string, @buffer) do |write_len|
      bytes_written = `$platform.io_write(self.fd, self.buffer, 0, self.pos, write_len)`
      raise IOError, 'could not write all data' if bytes_written < write_len
      @pos += write_len
      total_wsize += write_len
    end
    fsync if @sync && `$platform.io_fsync`
    total_wsize
  end

  alias tell pos

  # Get the internal timeout duration or nil if it was not set.
  #   or
  # Sets the internal timeout to the specified duration or nil.
  # The timeout applies to all blocking operations where possible.
  attr_accessor :timeout

  alias to_i fileno

  def to_io
    self
  end

  alias to_path path

  alias tty? isatty

  def ungetbyte(int_or_str)
    # Pushes back (“unshifts”) the given data onto the stream’s buffer,
    # placing the data so that it is next to be read; returns nil
    raise NotImplementedError
  end

  def ungetc(int_or_str)
    # Pushes back (“unshifts”) the given data onto the stream’s buffer,
    # placing the data so that it is next to be read; returns nil
    raise NotImplementedError
  end

  def write(*objects)
    # Writes each of the given objects to self, which must be opened for writing (see Access Modes);
    # returns the total number bytes written; each of objects that is not a string is converted via method to_s.
    total_wsize = 0
    objects.each do |obj|
      next if obj.nil?
      str = `$coerce_to_or_raise(obj, Opal.String, "to_s")`
      # syswrite will use the str binary_encoding, encode accordingly
      str = `$str(str, self.ext_enc)` if @ext_enc && @ext_enc != ::Encoding::BINARY
      next if str.empty?
      total_wsize += syswrite(str)
    end
    total_wsize
  end
end

require 'corelib/file/constants'

::STDIN = $stdin = ::IO.new(0, 'r').set_encoding(nil, nil)
::STDOUT = $stdout = ::IO.new(1, 'w').set_encoding(nil, nil)
::STDERR = $stderr = ::IO.new(2, 'w').set_encoding(nil, nil)
