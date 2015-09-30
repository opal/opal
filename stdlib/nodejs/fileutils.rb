module FileUtils
  extend self
  `var __fs__ = #{File}.__fs__`

  def cp source, target
    target = File.join(target, File.basename(source)) if File.directory? target
    `__fs__.writeFileSync(target, __fs__.readFileSync(source));`
  end

  def rm path
    `__fs__.unlinkSync(path)`
  end

  def mkdir_p path
    return true if File.directory? path
    `__fs__.mkdirSync(#{path})`
  end

  alias mkpath mkdir_p
  alias makedirs mkdir_p

  def mv source, target
    target = File.join(target, File.basename(source)) if File.directory? target
    `__fs__.renameSync(source, target)`
  end
end
