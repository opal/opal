class File < IO
  include ::IO::Writable
  include ::IO::Readable

  @__fs__ = NodeJS.require :fs
  @__path__ = NodeJS.require :path
  `var __fs__ = #{@__fs__}`
  `var __path__ = #{@__path__}`

  def self.read path
    `__fs__.readFileSync(#{path}).toString()`
  end

  def self.exist? path
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
    flags = flags.gsub(/b/, '')
    @path = path
    @flags = flags
    @fd = `__fs__.openSync(path, flags)`
  end

  attr_reader :path

  def write string
    `__fs__.writeSync(#{@fd}, #{string}, null, #{string}.length)`
  end

  def close
    `__fs__.closeSync(#{@fd})`
  end
end

