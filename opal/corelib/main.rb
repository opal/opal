# backtick_javascript: true

class << self
  def to_s
    'main'
  end

  def include(mod)
    ::Object.include mod
  end

  def autoload(*args)
    `Opal.Object.$autoload.apply(Opal.Object, args)`
  end

  # Compiler overrides this method
  def using(mod)
    ::Kernel.raise 'main.using is permitted only at toplevel'
  end

  def ruby2_keywords(*methods)
    ::Object.ruby2_keywords(*methods)
  end
end
