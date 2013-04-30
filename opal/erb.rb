# Provides Template module for registering erb templates
require 'opal-template'

class ERB
  def initialize(name, &body)
    @body = body
    @name = name
    Template[name] = self
  end

  def inspect
    "#<ERB: name=#{@name.inspect}>"
  end

  def render(ctx = self)
    ctx.instance_eval(&@body)
  end
end

