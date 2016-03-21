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

  def self.basename(path, ext = undefined)
    `__path__.basename(#{path}, #{ext})`
  end

  def self.dirname(path)
    `__path__.dirname(#{path})`
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




  # Instance Methods

  def initialize(path, flags)
    binary_flag_regexp = /b/
    encoding_flag_regexp = /:(.*)/
    # binary flag is unsupported
    warn "Binary flag (b) is unsupported by Node.js openSync method, removing flag." if flags.match(binary_flag_regexp)
    flags = flags.gsub(binary_flag_regexp, '')
    # encoding flag is unsupported
    warn "Encoding flag (:encoding) is unsupported by Node.js openSync method, removing flag." if flags.match(encoding_flag_regexp)
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
end

