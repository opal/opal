class Exception < `Error`
  attr_reader :message

  def self.new(message = 'Exception')
    %x{
      var err = new self.$$alloc(message);

      if (Error.captureStackTrace) {
        Error.captureStackTrace(err);
      }

      err.name = self.$$name;
      err.$initialize(message);
      return err;
    }
  end

  def initialize(message)
    `self.message = message`
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

  def inspect
    class_str = self.class.to_s
    our_str = to_s
    our_str.empty? ? class_str : "#<#{class_str}: #{our_str == class_str ? @message : our_str}>"
  end

  alias to_s message
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
    def self.new
      super('Invalid argument')
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
