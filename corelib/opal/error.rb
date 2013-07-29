class Exception
  attr_reader :message

  def self.new(message = '')
    %x{
      var err = new Error(message);
      err._klass = #{self};
      err.name = #{self}._name;
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

class StandardError < Exception; end
  class NameError < StandardError; end
    class NoMethodError < NameError; end
  class RuntimeError < StandardError; end
  class LocalJumpError < StandardError; end
  class TypeError < StandardError; end
  class ArgumentError < StandardError; end
  class IndexError < StandardError; end
    class StopIteration < IndexError; end
    class KeyError < IndexError; end
  class RangeError < StandardError; end
  class IOError < StandardError; end

class ScriptError < Exception; end
  class SyntaxError < ScriptError; end
  class NotImplementedError < ScriptError; end

class SystemExit < Exception; end
