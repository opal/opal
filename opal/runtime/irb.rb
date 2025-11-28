# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: raise, slice, splice, has_own

module ::Opal
  # Run in WebTools console with: Opal.irb(c => eval(c))
  def self.irb(fun)
    ::Binding.new(fun).irb
  end

  def self.load_parser
    ::Opal::IRB.ensure_loaded('opal-parser')
  end

  %x{
    if (typeof Opal.eval === 'undefined') {
      #{
        def self.eval(str)
          `Opal.load_parser()`
          `Opal.eval(str)`
        end
      }
    }
  }

  %x{
    if (typeof Opal.compile === 'undefined') {
      #{
        def self.compile(str, options)
          `Opal.load_parser()`
          `Opal.compile(str, options)`
        end
      }
    }
  }
end

::Opal
