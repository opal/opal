# backtick_javascript: true

class ::Binding
  # @private
  def initialize(jseval, scope_variables = [], receiver = undefined, source_location = nil)
    @jseval, @scope_variables, @receiver, @source_location = \
      jseval, scope_variables, receiver, source_location

    receiver = js_eval('self') if `typeof receiver === "undefined"`
  end

  def js_eval(*args)
    if @jseval
      args.map! { |arg| `(typeof arg === "object" && arg.$$is_string)` ? `arg.toString()` : arg }
      @jseval.call(*args)
    else
      ::Kernel.raise 'Evaluation on a Proc#binding is not supported'
    end
  end

  def local_variable_get(symbol)
    js_eval(symbol)
  rescue ::Exception
    ::Kernel.raise ::NameError, "local variable `#{symbol}' is not defined for #{inspect}"
  end

  def local_variable_set(symbol, value)
    `Opal.Binding.tmp_value = value`
    js_eval("#{symbol} = Opal.Binding.tmp_value")
    `delete Opal.Binding.tmp_value`
    value
  end

  def local_variables
    @scope_variables
  end

  def local_variable_defined?(value)
    @scope_variables.include?(value)
  end

  def eval(str, file = nil, line = nil)
    return receiver if str == 'self'

    ::Kernel.eval(str, self, file, line)
  end

  attr_reader :receiver, :source_location
end

module ::Kernel
  def binding
    ::Kernel.raise ::NotImplementedError, "Opal doesn't support dynamic calls to binding"
  end
end

TOPLEVEL_BINDING = ::Binding.new(
  %x{
    function(js) {
      return (new Function("self", "return " + js))(self);
    }
  },
  [], self, ['<main>', 0]
)
