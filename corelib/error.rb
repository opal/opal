class Exception
  def initialize(message = '')
    `
      if (Error.captureStackTrace) Error.captureStackTrace(self);
      self.message = message;
    `
  end 

  def backtrace
    `self._bt || (self._bt = rb_exc_backtrace)`
  end

  def inspect
    "#<#{self.class}: '#{message}'>"
  end

  def message
    `self.message`
  end

  alias_method :to_s, :message
end
