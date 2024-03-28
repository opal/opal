# backtick_javascript: true

require 'pathname'

class Pathname
  include Comparable

  @__path__ = Opal::Raw.import('node:path')
  `var __path__ = #{@__path__}`

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
