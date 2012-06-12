class Exception < `Error`
  attr_reader :message

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

      var backtrace = this.stack;

      if (typeof(backtrace) === 'string') {
        return this._bt = backtrace.split("\\n");
      }
      else if (backtrace) {
        this._bt = backtrace;
      }

      return this._bt = ["No backtrace available"];
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