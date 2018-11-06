require 'pathname'

class Pathname
  include Comparable

  @__path__ = `require('path')`
  `var __path__ = #{@__path__}`

  def absolute?
    `__path__.isAbsolute(#{@path.to_str})`
  end

  def relative?
    !absolute?
  end
end
