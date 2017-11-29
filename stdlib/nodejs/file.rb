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
  include ::IO::Writable
  include ::IO::Readable

  @__fs__ = node_require :fs
  @__path__ = node_require :path
  `var __fs__ = #{@__fs__}`
  `var __path__ = #{@__path__}`

  if `__path__.sep !== #{Separator}`
    ALT_SEPARATOR = `__path__.sep`
  end

  def self.read path
    `return executeIOAction(function(){return __fs__.readFileSync(#{path}).toString()})`
  end

  def self.write path, data
    `executeIOAction(function(){return __fs__.writeFileSync(#{path}, #{data})})`
    data.size
  end

  def self.exist? path
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
    `__path__.join.apply(__path__, #{paths})`
  end

  def self.directory? path
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

  def self.file? path
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

  def self.readable? path
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

  def self.size path
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

  def self.stat path
    path = path.path if path.respond_to? :path
    File::Stat.new(path)
  end

  def self.mtime path
    `return executeIOAction(function(){return __fs__.statSync(#{path}).mtime})`
  end

  # Instance Methods

  def initialize(path, flags = 'r')
    binary_flag_regexp = /b/
    encoding_flag_regexp = /:(.*)/
    # binary flag is unsupported
    `handle_unsupported_feature("Binary flag (b) is unsupported by Node.js openSync method, removing flag.")` if flags.match(binary_flag_regexp)
    flags = flags.gsub(binary_flag_regexp, '')
    # encoding flag is unsupported
    `handle_unsupported_feature("Encoding flag (:encoding) is unsupported by Node.js openSync method, removing flag.")` if flags.match(encoding_flag_regexp)
    flags = flags.gsub(encoding_flag_regexp, '')
    @path = path
    @flags = flags
    @fd = `executeIOAction(function(){return __fs__.openSync(path, flags)})`
  end

  attr_reader :path

  def write string
    `executeIOAction(function(){return __fs__.writeSync(#{@fd}, #{string})})`
  end

  def flush
    `executeIOAction(function(){return __fs__.fsyncSync(#@fd)})`
  end

  def close
    `executeIOAction(function(){return __fs__.closeSync(#{@fd})})`
  end

  def mtime
    `return executeIOAction(function(){return __fs__.statSync(#{@path}).mtime})`
  end
end

class File::Stat

  @__fs__ = node_require :fs
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
