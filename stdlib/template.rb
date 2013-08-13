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
    render_to_buffer ctx
  end

  def render_to_buffer(ctx = self, buffer = OutputBuffer.new)
    ctx.instance_exec(buffer, &@body)
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

    def capture(*args, &block)
      old = @buffer
      tmp = @buffer = []
      yield(*args) if block_given?
      @buffer = old
      tmp.join
    end
  end
end

