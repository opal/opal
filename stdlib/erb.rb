module Template
  @_cache = {}
  def self.[](name)
    @_cache[name]
  end

  def self.[]=(name, instance)
    @_cache[name] = instance
  end
end

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
    ctx.instance_exec(OutputBuffer.new, &@body)
  end

  class OutputBuffer
    def initialize
      @buffer = []
    end

    def <<(str)
      @buffer << str
    end

    def join
      @buffer.join
    end
  end
end
