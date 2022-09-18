require 'pathname'

class Pathname
  include Comparable

  __path__ = ::JS.import("path")

  def absolute?
    `__path__.isAbsolute(#{@path.to_str})`
  end

  def relative?
    !absolute?
  end

  def to_path
    @path
  end
end
