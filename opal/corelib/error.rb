class Exception < `Error`
  `var Kernel$raise = #{Kernel}.$raise`
  def self.new(*args)
    %x{
      var message   = (args.length > 0) ? args[0] : nil;
      var error     = new self.$$alloc(message);
      error.name    = self.$$name;
      error.message = message;
      Opal.send(error, error.$initialize, args);

      // Error.captureStackTrace() will use .name and .toString to build the
      // first line of the stack trace so it must be called after the error
      // has been initialized.
      // https://nodejs.org/dist/latest-v6.x/docs/api/errors.html
      if (Opal.config.enable_stack_trace && Error.captureStackTrace) {
        // Passing Kernel.raise will cut the stack trace from that point above
        Error.captureStackTrace(error, Kernel$raise);
      }

      return error;
    }
  end

  def self.exception(*args)
    new(*args)
  end

  def initialize(*args)
    # using self.message aka @message to retain compatibility with native exception's message property
    `self.message = (args.length > 0) ? args[0] : nil`
  end

  def backtrace
    %x{
      var backtrace = self.stack;

      if (typeof(backtrace) === 'string') {
        return backtrace.split("\n").slice(0, 15);
      }
      else if (backtrace) {
        return backtrace.slice(0, 15);
      }

      return [];
    }
  end

  def exception(str=nil)
    %x{
      if (str === nil || self === str) {
        return self;
      }

      var cloned = #{self.clone};
      cloned.message = str;
      return cloned;
    }
  end

  # not using alias message to_s because you need to be able to override to_s and have message use overridden method, won't work with alias
  def message
    to_s
  end

  def inspect
    as_str = to_s
    as_str.empty? ? self.class.to_s : "#<#{self.class.to_s}: #{to_s}>"
  end

  def to_s
    # using self.message aka @message to retain compatibility with native exception's message property
    (@message && @message.to_s) || self.class.to_s
  end
end

# keep the indentation, it makes the exception hierarchy clear
class ScriptError       < Exception; end
class SyntaxError         < ScriptError; end
class LoadError           < ScriptError; end
class NotImplementedError < ScriptError; end

class SystemExit        < Exception; end
class NoMemoryError     < Exception; end
class SignalException   < Exception; end
class Interrupt         < Exception; end
class SecurityError     < Exception; end

class StandardError     < Exception; end
class ZeroDivisionError   < StandardError; end
class NameError           < StandardError; end
class NoMethodError         < NameError; end
class RuntimeError        < StandardError; end
class LocalJumpError      < StandardError; end
class TypeError           < StandardError; end
class ArgumentError       < StandardError; end
class IndexError          < StandardError; end
class StopIteration         < IndexError; end
class KeyError              < IndexError; end
class RangeError          < StandardError; end
class FloatDomainError      < RangeError; end
class IOError             < StandardError; end
class SystemCallError     < StandardError; end

module Errno
  class EINVAL              < SystemCallError
    def self.new(name = nil)
      message = "Invalid argument"
      message += " - #{name}" if name
      super(message)
    end
  end
end

class UncaughtThrowError < ArgumentError
  attr_reader :sym, :arg

  def initialize(args)
    @sym = args[0]
    @arg = args[1] if args.length > 1

    super("uncaught throw #{@sym.inspect}")
  end
end

class NameError
  attr_reader :name

  def initialize(message, name=nil)
    super message
    @name = name
  end
end

class NoMethodError
  attr_reader :args

  def initialize(message, name=nil, args=[])
    super message, name
    @args = args
  end
end

class StopIteration
  attr_reader :result
end

module JS
  class Error
  end
end
