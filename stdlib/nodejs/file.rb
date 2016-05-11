%x{
  var warnings = {};
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
}

class File < IO
  include ::IO::Writable
  include ::IO::Readable

  @__fs__ = node_require :fs
  @__path__ = node_require :path
  `var __fs__ = #{@__fs__}`
  `var __path__ = #{@__path__}`

  def self.read path
    `__fs__.readFileSync(#{path}).toString()`
  end

  def self.write path, data
    `__fs__.writeFileSync(#{path}, #{data})`
    data.size
  end

  def self.exist? path
    path = path.path if path.respond_to? :path
    `__fs__.existsSync(#{path})`
  end

  def self.realpath(pathname, dir_string = nil, cache = nil, &block)
    pathname = join(dir_string, pathname) if dir_string
    if block_given?
      `
      __fs__.realpath(#{pathname}, #{cache}, function(error, realpath){
        if (error) #{raise error.message}
        else #{block.call(`realpath`)}
      })
      `
    else
      `__fs__.realpathSync(#{pathname}, #{cache})`
    end
  end

  def self.join(*paths)
    `__path__.join.apply(__path__, #{paths})`
  end

  def self.directory? path
    return nil unless exist? path
    `!!__fs__.lstatSync(path).isDirectory()`
  end

  def self.file? path
    return nil unless exist? path
    `!!__fs__.lstatSync(path).isFile()`
  end

  def self.size path
    return nil unless exist? path
    `__fs__.lstatSync(path).size`
  end

  def self.open path, flags
    file = new(path, flags)
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
    `__fs__.statSync(#{path}).mtime`
  end

  # Instance Methods

  def initialize(path, flags)
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
    @fd = `__fs__.openSync(path, flags)`
  end

  attr_reader :path

  def write string
    `__fs__.writeSync(#{@fd}, #{string})`
  end

  def flush
    `__fs__.fsyncSync(#@fd)`
  end

  def close
    `__fs__.closeSync(#{@fd})`
  end

  def mtime
    `__fs__.statSync(#{@path}).mtime`
  end
end

class File::Stat

  @__fs__ = node_require :fs
  `var __fs__ = #{@__fs__}`

  def initialize(path)
    @path = path
  end

  def file?
    `__fs__.statSync(#{@path}).isFile()`
  end

  def mtime
    `__fs__.statSync(#{@path}).mtime`
  end
end
