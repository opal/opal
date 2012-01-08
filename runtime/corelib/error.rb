class Exception
  def initialize(message = '')
    %x{
      if (Error.captureStackTrace) {
        Error.captureStackTrace(this);
      }

      this.message = message;
    }
  end

  def backtrace
    `this._bt || (this._bt = exc_backtrace(this))`
  end

  def inspect
    "#<#{self.class}: '#{message}'>"
  end

  def message
    `this.message`
  end

  alias to_s message
end
