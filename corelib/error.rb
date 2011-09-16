class Exception

  def initialize(message = '')
    @message = message
  end

  def message
    @message
  end

  def inspect
    `return "#<" + self.$k.__classid__ + ": '" + #{message} + "'>";`
  end

  def to_s
    message
  end
end

