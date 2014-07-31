module FileUtils
  extend self
  `var __fs__ = #{File}.__fs__`

  def mkdir_p path
    return true if File.directory? path
    `__fs__.mkdirSync(#{path})`
  end

  def cp source, target
    target = File.join(target, File.basename(source)) if File.directory? target
    `__fs__.writeFileSync(target, __fs__.readFileSync(source));`
  end

  def rm path
    `__fs__.unlinkSync(path)`
  end

  def mv source, target
    target = File.join(target, File.basename(source)) if File.directory? target
    `__fs__.renameSync(source, target)`
  end

  alias mkpath mkdir_p
  alias makedirs mkdir_p
end
