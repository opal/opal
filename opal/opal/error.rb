class Exception < `Error`
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
class RuntimeError < Exception; end
class LocalJumpError < Exception; end
class TypeError < Exception; end
class NameError < Exception; end
class NoMethodError < Exception; end
class ArgumentError < Exception; end
class IndexError < Exception; end
class KeyError < Exception; end
class RangeError < Exception; end
class StopIteration < Exception; end
class SyntaxError < Exception; end
class SystemExit < Exception; end
