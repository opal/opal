# backtick_javascript: true
# use_strict: true

class ::String
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

  alias protected_methods private_methods
  alias private_instance_methods private_methods
  alias protected_instance_methods private_methods
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
