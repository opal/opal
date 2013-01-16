class ERB
  @_cache = {}
  def self.[](name)
    @_cache[name]
  end

  def self.[]=(name, instance)
    @_cache[name] = instance
  end

  def initialize(name, &body)
    @body = body
    @name = name
    ERB[name] = self
  end

  def render(ctx=self)
    ctx.instance_eval(&@body)
  end
end
