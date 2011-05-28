class Module

  def private(*args)
    `$runtime.private_methods(self, args);`
    self
  end

  def public(*args)
    `$runtime.public_methods(self, args);`
    self
  end

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
    `$runtime.include_module(mod, self);`
    self
  end

  def included(mod)
    nil
  end
end

module Kernel
  private

  # Try to load the library or file named `path`. An error is thrown if the
  # path cannot be resolved.
  #
  # @param [String] path The path to load
  # @return [true, false]
  def require(path)
    `$runtime.require(path);`
    true
  end

  # Prints each argument in turn to the browser console. Currently there
  # is no use of `$stdout`, so it is hardcoded into this method to write
  # to the console directly.
  #
  # @param [Array<Object>] args Objects to print using `to_s`
  # @return [nil]
  def puts(*args)
    `for (var i = 0; i < args.length; i++) {
      console.log(#{`args[i]`.to_s});
    }`
    nil
  end
end


class Object
  include Kernel
end

class Symbol
  def to_s
    `return self.$value;`
  end
end

class String
  def to_s
    `return self;`
  end
end

require 'core/basic_object'
require 'core/object'
require 'core/module'
require 'core/class'
require 'core/kernel'
require 'core/top_self'
require 'core/nil_class'
require 'core/true_class'
require 'core/false_class'
require 'core/enumerable'
require 'core/array'
require 'core/numeric'
require 'core/hash'
require 'core/error'
require 'core/string'
require 'core/symbol'
require 'core/proc'
require 'core/range'
require 'core/regexp'
require 'core/match_data'
require 'core/file'
require 'core/dir'

`var platform = opal.platform;`
RUBY_PLATFORM = `platform.platform`
RUBY_ENGINE = `platform.engine`
RUBY_VERSION = `platform.version`

ARGV = `platform.argv`

