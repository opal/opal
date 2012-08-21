# A really small ERB implementation for Opal.
class ERB

  # @private Stores all registered instances
  @templates = {}
  def self.[]=(name, instance)
    @templates[name] = instance
  end

  def self.[](name)
    @templates[name]
  end

  def initialize(name, &body)
    ERB[name] = self
    @body = body
  end

  # Run this erb template against the given context. Unlike ERB, opals
  # implementation uses a normal object as a context.
  #
  #   view = UserView.new
  #   ERB[:user_view].result(view)
  #
  # @param [Object] context
  # @result [String]
  def result(context)
    context.instance_eval &@body
  end
end