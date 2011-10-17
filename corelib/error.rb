class Exception
  def initialize (message = "")
    @message = message
  end

  def message
    @message
  end

  alias_method :to_s, :message

  def inspect
    `"#<" + self.$k.__classid__ + ": '" + #{message} + "'>"`
    "#<#{self.class}: #{message}>"
  end

  def backtrace
    []
  end
end

