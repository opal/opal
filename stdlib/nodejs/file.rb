# use_strict: true
# frozen_string_literal: true

%x{
  var warnings = {}, errno_code, errno_codes = [
    'EACCES',
    'EISDIR',
    'EMFILE',
    'ENOENT',
    'EPERM'
  ];

  function handle_unsupported_feature(message) {
    switch (Opal.config.unsupported_features_severity) {
    case 'error':
      #{Kernel.raise NotImplementedError, `message`}
      break;
    case 'warning':
      warn(message)
      break;
    default: // ignore
      // noop
    }
  }
  function warn(string) {
    if (warnings[string]) {
      return;
    }
    warnings[string] = true;
    #{warn(`string`)};
  }
  function is_utf8(bytes) {
    var i = 0;
    while (i < bytes.length) {
      if ((// ASCII
        bytes[i] === 0x09 ||
        bytes[i] === 0x0A ||
        bytes[i] === 0x0D ||
        (0x20 <= bytes[i] && bytes[i] <= 0x7E)
      )
      ) {
        i += 1;
        continue;
      }

      if ((// non-overlong 2-byte
        (0xC2 <= bytes[i] && bytes[i] <= 0xDF) &&
        (0x80 <= bytes[i + 1] && bytes[i + 1] <= 0xBF)
      )
      ) {
        i += 2;
        continue;
      }

      if ((// excluding overlongs
          bytes[i] === 0xE0 &&
          (0xA0 <= bytes[i + 1] && bytes[i + 1] <= 0xBF) &&
          (0x80 <= bytes[i + 2] && bytes[i + 2] <= 0xBF)
        ) ||
        (// straight 3-byte
          ((0xE1 <= bytes[i] && bytes[i] <= 0xEC) ||
            bytes[i] === 0xEE ||
            bytes[i] === 0xEF) &&
          (0x80 <= bytes[i + 1] && bytes[i + 1] <= 0xBF) &&
          (0x80 <= bytes[i + 2] && bytes[i + 2] <= 0xBF)
        ) ||
        (// excluding surrogates
          bytes[i] === 0xED &&
          (0x80 <= bytes[i + 1] && bytes[i + 1] <= 0x9F) &&
          (0x80 <= bytes[i + 2] && bytes[i + 2] <= 0xBF)
        )
      ) {
        i += 3;
        continue;
      }

      if ((// planes 1-3
          bytes[i] === 0xF0 &&
          (0x90 <= bytes[i + 1] && bytes[i + 1] <= 0xBF) &&
          (0x80 <= bytes[i + 2] && bytes[i + 2] <= 0xBF) &&
          (0x80 <= bytes[i + 3] && bytes[i + 3] <= 0xBF)
        ) ||
        (// planes 4-15
          (0xF1 <= bytes[i] && bytes[i] <= 0xF3) &&
          (0x80 <= bytes[i + 1] && bytes[i + 1] <= 0xBF) &&
          (0x80 <= bytes[i + 2] && bytes[i + 2] <= 0xBF) &&
          (0x80 <= bytes[i + 3] && bytes[i + 3] <= 0xBF)
        ) ||
        (// plane 16
          bytes[i] === 0xF4 &&
          (0x80 <= bytes[i + 1] && bytes[i + 1] <= 0x8F) &&
          (0x80 <= bytes[i + 2] && bytes[i + 2] <= 0xBF) &&
          (0x80 <= bytes[i + 3] && bytes[i + 3] <= 0xBF)
        )
      ) {
        i += 4;
        continue;
      }

      return false;
    }

    return true;
  }
  function executeIOAction(action) {
    try {
      return action();
    } catch (error) {
      if (errno_codes.indexOf(error.code) >= 0) {
        var error_class = #{Errno.const_get(`error.code`)}
        throw #{`error_class`.new(`error.message`)};
      }
      throw error;
    }
  }

  for(var i = 0, ii = errno_codes.length; i < ii; i++) {
    errno_code = errno_codes[i];
    if (!#{Errno.const_defined?(`errno_code`)}) {
      #{Errno.const_set(`errno_code`, Class.new(SystemCallError))}
    }
  }
}

class File < IO
  @__fs__ = `require('fs')`
  @__path__ = `require('path')`
  @__util__ = `require('util')`
  `var __fs__ = #{@__fs__}`
  `var __path__ = #{@__path__}`
  `var __util__ = #{@__util__}`
  # Since Node.js 11+ TextEncoder and TextDecoder are now available on the global object.
  `var __TextEncoder__ = typeof TextEncoder !== 'undefined' ? TextEncoder : __util__.TextEncoder`
  `var __TextDecoder__ = typeof TextDecoder !== 'undefined' ? TextDecoder : __util__.TextDecoder`
  `var __utf8TextDecoder__ = new __TextDecoder__('utf8')`
  `var __textEncoder__ = new __TextEncoder__()`

  if `__path__.sep !== #{Separator}`
    ALT_SEPARATOR = `__path__.sep`
  end


  def self.read(path)
    `return executeIOAction(function(){return __fs__.readFileSync(#{path}).toString()})`
  end

  def self.write(path, data)
    `executeIOAction(function(){return __fs__.writeFileSync(#{path}, #{data})})`
    data.size
  end

  def self.exist?(path)
    path = path.path if path.respond_to? :path
    `return executeIOAction(function(){return __fs__.existsSync(#{path})})`
  end

  def self.realpath(pathname, dir_string = nil, cache = nil, &block)
    pathname = join(dir_string, pathname) if dir_string
    if block_given?
      `
        __fs__.realpath(#{pathname}, #{cache}, function(error, realpath){
          if (error) Opal.IOError.$new(error.message)
          else #{block.call(`realpath`)}
        })
        `
    else
      `return executeIOAction(function(){return __fs__.realpathSync(#{pathname}, #{cache})})`
    end
  end

  def self.join(*paths)
    `__path__.posix.join.apply(__path__, #{paths})`
  end

  def self.directory?(path)
    return false unless exist? path
    result = `executeIOAction(function(){return !!__fs__.lstatSync(path).isDirectory()})`
    unless result
      realpath = realpath(path)
      if realpath != path
        result = `executeIOAction(function(){return !!__fs__.lstatSync(realpath).isDirectory()})`
      end
    end
    result
  end

  def self.file?(path)
    return false unless exist? path
    result = `executeIOAction(function(){return !!__fs__.lstatSync(path).isFile()})`
    unless result
      realpath = realpath(path)
      if realpath != path
        result = `executeIOAction(function(){return !!__fs__.lstatSync(realpath).isFile()})`
      end
    end
    result
  end

  def self.readable?(path)
    return false unless exist? path
    %{
        try {
          __fs__.accessSync(path, __fs__.R_OK);
          return true;
        } catch (error) {
          return false;
        }
      }
  end

  def self.size(path)
    `return executeIOAction(function(){return __fs__.lstatSync(path).size})`
  end

  def self.open(path, mode = 'r')
    file = new(path, mode)
    if block_given?
      begin
        yield(file)
      ensure
        file.close
      end
    else
      file
    end
  end

  def self.stat(path)
    path = path.path if path.respond_to? :path
    File::Stat.new(path)
  end

  def self.mtime(path)
    `return executeIOAction(function(){return __fs__.statSync(#{path}).mtime})`
  end

  def self.symlink?(path)
    `return executeIOAction(function(){return __fs__.lstatSync(#{path}).isSymbolicLink()})`
  end

  def self.absolute_path(path, basedir = nil)
    path = path.respond_to?(:to_path) ? path.to_path : path
    basedir ||= Dir.pwd
    `return __path__.normalize(__path__.resolve(#{basedir.to_str}, #{path.to_str})).split(__path__.sep).join(__path__.posix.sep)`
  end

  # Instance Methods

  def initialize(path, flags = 'r')
    @binary_flag = flags.include?('b')
    # Node does not recognize this flag
    flags = flags.delete('b')
    # encoding flag is unsupported
    encoding_option_rx = /:(.*)/
    if encoding_option_rx.match?(flags)
      `handle_unsupported_feature("Encoding option (:encoding) is unsupported by Node.js openSync method and will be removed.")`
      flags = flags.sub(encoding_option_rx, '')
    end
    @path = path

    fd = `executeIOAction(function(){return __fs__.openSync(path, flags)})`
    super(fd, flags)
  end

  attr_reader :path

  def sysread(bytes)
    if @eof
      raise EOFError, 'end of file reached'
    else
      if @binary_flag
        %x{
          var buf = executeIOAction(function(){return __fs__.readFileSync(#{@path})})
          var content
          if (is_utf8(buf)) {
            content = buf.toString('utf8')
          } else {
            // coerce to utf8
            content = __utf8TextDecoder__.decode(__textEncoder__.encode(buf.toString('binary')))
          }
        }
        res = `content`
      else
        res = `executeIOAction(function(){return __fs__.readFileSync(#{@path}).toString('utf8')})`
      end
      @eof = true
      @lineno = res.size
      res
    end
  end

  def write(string)
    `executeIOAction(function(){return __fs__.writeSync(#{@fd}, #{string})})`
  end

  def flush
    `executeIOAction(function(){return __fs__.fsyncSync(#{@fd})})`
  end

  def close
    `executeIOAction(function(){return __fs__.closeSync(#{@fd})})`
    super
  end

  def mtime
    `return executeIOAction(function(){return __fs__.statSync(#{@path}).mtime})`
  end
end

class File::Stat
  @__fs__ = `require('fs')`
  `var __fs__ = #{@__fs__}`

  def initialize(path)
    @path = path
  end

  def file?
    `return executeIOAction(function(){return __fs__.statSync(#{@path}).isFile()})`
  end

  def mtime
    `return executeIOAction(function(){return __fs__.statSync(#{@path}).mtime})`
  end
end
