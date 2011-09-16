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
    `rb_include_module(mod, self);`
    self
  end

  def included(mod)
    nil
  end
end

module Kernel

  # Try to load the library or file named `path`. An error is thrown if the
  # path cannot be resolved.
  #
  # @param [String] path The path to load
  # @return [true, false]
  def require(path)
    `return rb_require(path);`
  end

  # Prints the message to `STDOUT`.
  #
  # @param [Array<Object>] args Objects to print using `to_s`
  # @return [nil]
  def puts(*a)
    $stdout.puts *a
    nil
  end
end

class << $stdout
  # FIXME: Should this really be here? We only need to override this when we
  # are in the browser context as we don't have native access to file
  # descriptors etc
  def puts(*a)
    `for (var i = 0, ii = a.length; i < ii; i++) {
      console.log(#{`a[i]`.to_s}.toString());
    }`
    nil
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

