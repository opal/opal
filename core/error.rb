class Exception < `Error`
  attr_reader :message

  def self.new(message = '')
    %x{
      var err = new Error(message);
      err._klass = #{self};
      return err;
    }
  end

  def backtrace
    %x{
      var backtrace = #{self}.stack;

      if (typeof(backtrace) === 'string') {
        return backtrace.split("\\n").slice(0, 15);
      }
      else if (backtrace) {
        return backtrace.slice(0, 15);
      }

      return [];
    }
  end

  def inspect
    "#<#{self.class.name}: '#@message'>"
  end

  alias to_s message
end

StandardError   = Exception
RuntimeError    = Exception
LocalJumpError  = Exception
TypeError       = Exception
NameError       = Exception
NoMethodError   = Exception
ArgumentError   = Exception
IndexError      = Exception
KeyError        = Exception
RangeError      = Exception