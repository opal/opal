%x{
  var warnings = {};

  function handle_unsupported_feature(message) {
    switch (Opal.config.unsupported_features_severity) {
    case 'error':
      #{::Kernel.raise ::NotImplementedError, `message`}
      break;
    case 'warning':
      warn(message)
      break;
    default: // ignore
      // noop
    }
  }

  function warn(string) {
    if (warnings[string]) {
      return;
    }

    warnings[string] = true;
    #{warn(`string`)};
  }
}

class String
  `var ERROR = "String#%s not supported. Mutable String methods are not supported in Opal."`

  def <<(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % '<<'
  end

  def capitalize!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'capitalize!'
  end

  def chomp!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'chomp!'
  end

  def chop!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'chop!'
  end

  def downcase!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'downcase!'
  end

  def gsub!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'gsub!'
  end

  def lstrip!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'lstrip!'
  end

  def next!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'next!'
  end

  def reverse!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'reverse!'
  end

  def slice!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'slice!'
  end

  def squeeze!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'squeeze!'
  end

  def strip!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'strip!'
  end

  def sub!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'sub!'
  end

  def succ!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'succ!'
  end

  def swapcase!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'swapcase!'
  end

  def tr!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'tr!'
  end

  def tr_s!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'tr_s!'
  end

  def upcase!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'upcase!'
  end

  def prepend(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'prepend'
  end

  def []=(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % '[]='
  end

  def clear(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'clear'
  end

  def encode!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'encode!'
  end

  def unicode_normalize!(*)
    ::Kernel.raise ::NotImplementedError, `ERROR` % 'unicode_normalize!'
  end
end

module Kernel
  `var ERROR = "Object freezing is not supported by Opal"`

  def freeze
    `handle_unsupported_feature(ERROR)`
    self
  end

  def frozen?
    `handle_unsupported_feature(ERROR)`
    false
  end
end

module Kernel
  `var ERROR = "Object tainting is not supported by Opal"`

  def taint
    `handle_unsupported_feature(ERROR)`
    self
  end

  def untaint
    `handle_unsupported_feature(ERROR)`
    self
  end

  def tainted?
    `handle_unsupported_feature(ERROR)`
    false
  end
end

class Module
  def public(*methods)
    %x{
      if (methods.length === 0) {
        self.$$module_function = false;
      }

      return nil;
    }
  end

  alias private public

  alias protected public

  alias nesting public

  def private_class_method(*)
    self
  end

  alias public_class_method private_class_method

  def private_method_defined?(obj)
    false
  end

  def private_constant(*)
  end

  alias protected_method_defined? private_method_defined?

  alias public_instance_methods instance_methods

  alias public_instance_method instance_method

  alias public_method_defined? method_defined?
end

module Kernel
  def private_methods(*)
    []
  end

  alias private_instance_methods private_methods
end

module Kernel
  def eval(*)
    ::Kernel.raise NotImplementedError, "To use Kernel#eval, you must first require 'opal-parser'. "\
                                        "See https://github.com/opal/opal/blob/#{RUBY_ENGINE_VERSION}/docs/opal_parser.md for details."
  end
end

def self.public(*)
  # stub
end

def self.private(*)
  # stub
end
