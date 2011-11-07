class Exception
  def initialize(message = '')
    `Error.captureStackTrace(self);`
    `self.message = message`
  end

  def ==(*)
    raise NotImplementedError, 'Exception#== not yet implemented'
  end

  def backtrace
    `
      if (!self._backtrace) {
        self._backtrace = VM.backtrace(self);
      }

      return self._backtrace;
    `
  end

  def awesome_backtrace
    @backtrace ||= `VM.awesome_backtrace(self)`
  end

  def exception(*)
    raise NotImplementedError, 'Exception#exception not yet implemented'
  end

  def inspect
    "#<#{self.class}: '#{message}'>"
  end

  def message
    `self.message`
  end

  def set_backtrace(*)
    raise NotImplementedError, 'Exception#set_backtrace not yet implemented'
  end

  alias_method :to_s, :message
end
