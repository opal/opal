class Binding
  # @private
  def initialize(jseval, scope_variables, receiver, source_location)
    @jseval, @scope_variables, @receiver, @source_location = \
      jseval, scope_variables, receiver, source_location
  end

  def js_eval(*args)
    @jseval.call(*args)
  end

  def local_variable_get(symbol)
    js_eval(symbol)
  rescue Exception
    raise NameError, "local variable `#{symbol}' is not defined for #{inspect}"
  end

  def local_variable_set(symbol, value)
    js_eval(symbol, value)
  end

  def local_variables
    @scope_variables
  end

  def local_variable_defined?(value)
    @scope_variables.include?(value)
  end

  def eval(str, file = nil, line = nil)
    return receiver if str == 'self'

    Kernel.eval(str, self, file, line)
  end

  attr_reader :receiver, :source_location
end

module Kernel
  def binding
    raise "Opal doesn't support dynamic calls to binding"
  end
end

TOPLEVEL_BINDING = binding
`#{TOPLEVEL_BINDING}.source_location = ["<main>", 0]`
