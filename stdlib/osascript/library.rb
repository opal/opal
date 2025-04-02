# backtick_javascript: true

class Library
  def initialize(name)
    @native_library = `Library(name)`
  end

  def method_missing(name, *args)
    name_s = name.to_s
    `self.native_library[name_s](...args)`
  end
end