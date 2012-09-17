# A wapper for ERB templates in Opal. Other templates may be used
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
  #   ERB[:user_view].render(view)
  #
  # @param [Object] context
  # @result [String]
  def render(content)
    content.instance_eval(&@body)
  end

  alias :result :render
end