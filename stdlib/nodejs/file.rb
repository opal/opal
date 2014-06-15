class File

  def self.__fs__
    @fs ||= `OpalNode.node_require('fs')`
  end

  def self.read path
    `#{__fs__}.readFileSync(#{path}).toString()`
  end

  def self.exist? path
    `#{__fs__}.existsSync(#{path})`
  end

  def self.realpath(pathname, dir_string = nil, cache = nil, &block)
    pathname = join(dir_string, pathname) if dir_string
    if block_given?
      `
      #{__fs__}.realpath(#{pathname}, #{cache}, function(error, realpath){
        if (error) #{raise error.message}
        else #{block.call(`realpath`)}
      })
      `
    else
      `#{__fs__}.realpathSync(#{pathname}, #{cache})`
    end
  end

  def self.__path__
    @path ||= `OpalNode.node_require('path')`
  end

  def self.basename(path, ext = undefined)
    `#{__path__}.basename(#{path}, #{ext})`
  end

  def self.dirname(path)
    `#{__path__}.dirname(#{path})`
  end

  def self.join(*paths)
    __path = __path__
    `#{__path}.join.apply(#{__path}, #{paths})`
  end

  def self.directory? path
    return nil unless exist? path
    `!!#{__fs__}.lstatSync(path).isDirectory()`
  end

  def self.file? path
    return nil unless exist? path
    `!!#{__fs__}.lstatSync(path).isFile()`
  end
end

