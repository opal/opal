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

  %i[
    << capitalize! chomp! chop! downcase! gsub! lstrip! next! reverse!
    slice! squeeze! strip! sub! succ! swapcase! tr! tr_s! upcase! prepend
    []= clear encode! unicode_normalize!
  ].each do |method_name|
    define_method method_name do |*|
      ::Kernel.raise ::NotImplementedError, `ERROR` % method_name
    end
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
