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

  def eval(*)
    ::Kernel.raise ::NotImplementedError, "To use Kernel#eval, you must first require 'opal-parser'. "\
                                          "See https://github.com/opal/opal/blob/#{RUBY_ENGINE_VERSION}/docs/opal_parser.md for details."
  end

  def fork
    ::Kernel.raise ::NotImplementedError, "can't fork in a JavaScript environment"
  end

  def system(*)
    ::Kernel.raise ::NotImplementedError, "can't run system commands in JavaScript environment"
  end
end
