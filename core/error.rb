class Exception < `Error`
  attr_reader :message

  def initialize(message = '')
    @message = message
  end

  def backtrace
    %x{
      var backtrace = this.stack;

      if (typeof(backtrace) === 'string') {
        return backtrace.split("\\n");
      }
      else if (backtrace) {
        return backtrace;
      }

      return ["No backtrace available"];
    }
  end

  def inspect
    "#<#{self.class}: '#{message}'>"
  end

  alias to_s message
end

class StandardError < Exception; end
class RuntimeError < Exception; end
class LocalJumpError < StandardError; end
class TypeError < StandardError; end
class NameError < StandardError; end
class NoMethodError < NameError; end
class ArgumentError < StandardError; end
class IndexError < StandardError; end
class KeyError < IndexError; end
class RangeError < StandardError; end