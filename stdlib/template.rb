class Template
  @_cache = {}
  def self.[](name)
    @_cache[name]
  end

  def self.[]=(name, instance)
    @_cache[name] = instance
  end

  def initialize(name, &body)
    @name, @body = name, body
    Template[name] = self
  end

  def inspect
    "#<Template: '#@name'>"
  end

  def render(ctx = self)
    ctx.instance_exec(OutputBuffer.new, &@body)
  end

  class OutputBuffer
    def initialize
      @buffer = []
    end

    def append(str)
      @buffer << str
    end

    def append=(content)
      @buffer << content
    end

    def join
      @buffer.join
    end
  end
end

