%x{
  var warnings = {};

  function handle_unsupported_feature(message) {
    switch (Opal.config.unsupported_features_severity) {
    case 'error':
      #{Kernel.raise NotImplementedError, `message`}
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
    raise NotImplementedError, `ERROR` % '<<'
  end

  def capitalize!(*)
    raise NotImplementedError, `ERROR` % 'capitalize!'
  end

  def chomp!(*)
    raise NotImplementedError, `ERROR` % 'chomp!'
  end

  def chop!(*)
    raise NotImplementedError, `ERROR` % 'chop!'
  end

  def downcase!(*)
    raise NotImplementedError, `ERROR` % 'downcase!'
  end

  def gsub!(*)
    raise NotImplementedError, `ERROR` % 'gsub!'
  end

  def lstrip!(*)
    raise NotImplementedError, `ERROR` % 'lstrip!'
  end

  def next!(*)
    raise NotImplementedError, `ERROR` % 'next!'
  end

  def reverse!(*)
    raise NotImplementedError, `ERROR` % 'reverse!'
  end

  def slice!(*)
    raise NotImplementedError, `ERROR` % 'slice!'
  end

  def squeeze!(*)
    raise NotImplementedError, `ERROR` % 'squeeze!'
  end

  def strip!(*)
    raise NotImplementedError, `ERROR` % 'strip!'
  end

  def sub!(*)
    raise NotImplementedError, `ERROR` % 'sub!'
  end

  def succ!(*)
    raise NotImplementedError, `ERROR` % 'succ!'
  end

  def swapcase!(*)
    raise NotImplementedError, `ERROR` % 'swapcase!'
  end

  def tr!(*)
    raise NotImplementedError, `ERROR` % 'tr!'
  end

  def tr_s!(*)
    raise NotImplementedError, `ERROR` % 'tr_s!'
  end

  def upcase!(*)
    raise NotImplementedError, `ERROR` % 'upcase!'
  end

  def prepend(*)
    raise NotImplementedError, `ERROR` % 'prepend'
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
    raise NotImplementedError, "To use Kernel#eval, you must first require 'opal-parser'. "\
                               "See https://github.com/opal/opal/blob/#{RUBY_ENGINE_VERSION}/docs/opal_parser.md for details."
  end
end

def self.public(*)
  # stub
end

def self.private(*)
  # stub
end
