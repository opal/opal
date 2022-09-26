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

module ::Kernel
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

module ::Kernel
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

class ::Module
  def public(*methods)
    %x{
      if (methods.length === 0) {
        self.$$module_function = false;
        return nil;
      }
      return (methods.length === 1) ? methods[0] : methods;
    }
  end

  def private_class_method(*methods)
    `return (methods.length === 1) ? methods[0] : methods`
  end

  def private_method_defined?(obj)
    false
  end

  def private_constant(*)
  end

  alias nesting public
  alias private public
  alias protected public
  alias protected_method_defined? private_method_defined?
  alias public_class_method private_class_method
  alias public_instance_method instance_method
  alias public_instance_methods instance_methods
  alias public_method_defined? method_defined?
end

module ::Kernel
  def private_methods(*methods)
    []
  end

  alias private_instance_methods private_methods
end

module ::Kernel
  def eval(*)
    ::Kernel.raise ::NotImplementedError, "To use Kernel#eval, you must first require 'opal-parser'. "\
                                          "See https://github.com/opal/opal/blob/#{RUBY_ENGINE_VERSION}/docs/opal_parser.md for details."
  end
end

def self.public(*methods)
  `return (methods.length === 1) ? methods[0] : methods`
end

def self.private(*methods)
  `return (methods.length === 1) ? methods[0] : methods`
end
