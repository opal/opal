class Exception
  def initialize(message = '')
    @message = message
  end

  def ==(*)
    raise NotImplementedError, 'Exception#== not yet implemented'
  end

  def backtrace
    []
  end

  def exception(*)
    raise NotImplementedError, 'Exception#exception not yet implemented'
  end

  def inspect
    `"#<" + self.$k.__classid__ + ": '" + #{message} + "'>"`
  end

  def message
    @message
  end

  def set_backtrace(*)
    raise NotImplementedError, 'Exception#set_backtrace not yet implemented'
  end

  alias_method :to_s, :message
end
