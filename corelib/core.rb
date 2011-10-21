class Module

  def include(*mods)
    `var i = mods.length - 1, mod;
    while (i >= 0) {
      mod = mods[i];
      #{`mod`.append_features self};
      #{`mod`.included self};
      i--;
    }
    return self;`
  end

  def append_features(mod)
    `VM.im(mod, self);`
    self
  end

  def included(mod)
    nil
  end
end

module Kernel
  def puts(*a)
    $stdout.puts *a
    nil
  end

  def print(*args)
    $stdout.print *args
  end
end

class Object
  include Kernel
end

class String
  def to_s
    `return self.toString();`
  end
end

class Symbol
  def to_s
    `return self.toString();`
  end
end

