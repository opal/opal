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
    %x{
      if (this._bt !== undefined) {
        return this._bt;
      }

      var old = Error.prepareStackTrace;
      Error.prepareStackTrace = prepare_backtrace;

      var backtrace = this.stack;
      Error.prepareStackTrace = old;

      if (backtrace && backtrace.join) {
        return this._bt = backtrace;
      }

      return this._bt = ["No backtrace available"];
    }
  end

  def inspect
    "#<#{self.class}: '#{message}'>"
  end

  def message
    `this.message`
  end

  alias to_s message
end
