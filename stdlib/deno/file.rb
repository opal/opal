`/* global Deno */`
require 'corelib/file'

%x{
  var warnings = {}, errno_codes = #{Errno.constants};

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
        #{Kernel.raise `error_class`.new(`error.message`)}
      }
      #{Kernel.raise `error`}
    }
  }
}

class File < IO
  `var __utf8TextDecoder__ = new TextDecoder('utf8')`
  `var __textEncoder__ = new TextEncoder()`

  def self.read(path)
    `return executeIOAction(function(){return Deno.readFileSync(#{path}).toString()})`
  end

  def self.write(path, data)
    `executeIOAction(function(){return Deno.writeFileSync(#{path}, __textEncoder__.encode(#{data}));})`
    data.size
  end

  def self.delete(path)
    `executeIOAction(function(){return Deno.removeSync(#{path})})`
  end

  class << self
    alias unlink delete
  end

  def self.exist?(path)
    path = path.path if path.respond_to? :path
    `return executeIOAction(function(){return Deno.statSync(#{path})})`
  end

  def self.realpath(pathname, dir_string = nil, cache = nil, &block)
    pathname = join(dir_string, pathname) if dir_string
    if block_given?
      `
        Deno.realpath(#{pathname}, #{cache}, function(error, realpath){
          if (error) Opal.IOError.$new(error.message)
          else #{block.call(`realpath`)}
        })
        `
    else
      `return executeIOAction(function(){return Deno.realpathSync(#{pathname}, #{cache})})`
    end
  end

  def self.join(*paths)
    # by itself, `path.posix.join` normalizes leading // to /.
    # restore the leading / on UNC paths (i.e., paths starting with //).
    paths = paths.map(&:to_s)
    prefix = paths.first&.start_with?('//') ? '/' : ''
    path = prefix
    paths.each do |pth|
      path << if pth.end_with?('/') || pth.start_with?('/')
                pth
              else
                '/' + pth
              end
    end
    path
  end

  def self.directory?(path)
    return false unless exist? path
    result = `executeIOAction(function(){return !!Deno.lstatSync(path).isDirectory})`
    unless result
      realpath = realpath(path)
      if realpath != path
        result = `executeIOAction(function(){return !!Deno.lstatSync(realpath).isDirectory})`
      end
    end
    result
  end

  def self.file?(path)
    return false unless exist? path
    result = `executeIOAction(function(){return !!Deno.lstatSync(path).isFile})`
    unless result
      realpath = realpath(path)
      if realpath != path
        result = `executeIOAction(function(){return !!Deno.lstatSync(realpath).isFile})`
      end
    end
    result
  end

  def self.readable?(path)
    return false unless exist? path
    %{
      try {
        Deno.openSync(path, {read: true}).close();
        return true;
      } catch (error) {
        return false;
      }
    }
  end

  def self.size(path)
    `return executeIOAction(function(){return Deno.lstatSync(path).size})`
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
    `return executeIOAction(function(){return Deno.statSync(#{path}).mtime})`
  end

  def self.symlink?(path)
    `return executeIOAction(function(){return Deno.lstatSync(#{path}).isSymLink})`
  end

  def self.absolute_path(path, basedir = nil)
    raise 'File::absolute_path is currently unsupported in Deno!'
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

    fd = `executeIOAction(function(){return Deno.openSync(path, flags)})`
    super(fd, flags)
  end

  attr_reader :path

  def sysread(bytes)
    if @eof
      raise EOFError, 'end of file reached'
    else
      if @binary_flag
        %x{
          var buf = executeIOAction(function(){return Deno.readFileSync(#{@path})})
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
        res = `executeIOAction(function(){return Deno.readFileSync(#{@path}).toString('utf8')})`
      end
      @eof = true
      @lineno = res.size
      res
    end
  end

  def write(string)
    `executeIOAction(function(){return #{@fd}.writeSync(__textEncoder__.encode(#{string}))})`
  end

  def flush
    # not supported by deno
  end

  def close
    `executeIOAction(function(){return #{@fd}.close()})`
    super
  end

  def mtime
    `return executeIOAction(function(){return Deno.statSync(#{@path}).mtime})`
  end
end

class File::Stat
  def initialize(path)
    @path = path
  end

  def file?
    `return executeIOAction(function(){return Deno.statSync(#{@path}).isFile})`
  end

  def directory?
    `return executeIOAction(function(){return Deno.statSync(#{@path}).isDirectory})`
  end

  def mtime
    `return executeIOAction(function(){return Deno.statSync(#{@path}).mtime})`
  end

  def readable?
    %x{
      return executeIOAction(function(){
        Deno.openSync(path, {read: true}).close();
        return true;
      })
    }
  end

  def writable?
    %x{
      return executeIOAction(function(){
        Deno.openSync(path, {write: true}).close();
        return true;
      })
    }
  end

  def executable?
    # accessible only over unstable API
    false
  end
end
