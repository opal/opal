# backtick_javascript: true
# helper: platform

require 'pathname'

class Pathname
  include Comparable

  def absolute?
    `$platform.file_is_absolute(self.path)`
  end

  def relative?
    !absolute?
  end

  def to_path
    @path
  end
end
