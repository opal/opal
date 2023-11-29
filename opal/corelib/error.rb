# backtick_javascript: true

class ::Exception < `Error`
  `Opal.prop(self.$$prototype, '$$is_exception', true)`
  `var stack_trace_limit`

  `Error.stackTraceLimit = 100`

  def self.new(*args)
    %x{
      var message   = (args.length > 0) ? args[0] : nil;
      var error     = new self.$$constructor(message);
      error.name    = self.$$name;
      error.message = message;
      error.cause   = #{$!};
      Opal.send(error, error.$initialize, args);

      // Error.captureStackTrace() will use .name and .toString to build the
      // first line of the stack trace so it must be called after the error
      // has been initialized.
      // https://nodejs.org/dist/latest-v6.x/docs/api/errors.html
      if (Opal.config.enable_stack_trace && Error.captureStackTrace) {
        // Passing Kernel.raise will cut the stack trace from that point above
        Error.captureStackTrace(error, stack_trace_limit);
      }

      return error;
    }
  end
  `stack_trace_limit = self.$new`

  def self.exception(*args)
    new(*args)
  end

  def initialize(*args)
    # using self.message aka @message to retain compatibility with native exception's message property
    `self.message = (args.length > 0) ? args[0] : nil`
  end

  # Those instance variables are not enumerable.
  def copy_instance_variables(other)
    super
    %x{
      self.message = other.message;
      self.cause = other.cause;
      self.stack = other.stack;
    }
  end

  %x{
    // Convert backtrace from any format to Ruby format
    function correct_backtrace(backtrace) {
      var new_bt = [], m;

      for (var i = 0; i < backtrace.length; i++) {
        var loc = backtrace[i];
        if (!loc || !loc.$$is_string) {
          /* Do nothing */
        }
        /* Chromium format */
        else if ((m = loc.match(/^    at (.*?) \((.*?)\)$/))) {
          new_bt.push(m[2] + ":in `" + m[1] + "'");
        }
        else if ((m = loc.match(/^    at (.*?)$/))) {
          new_bt.push(m[1] + ":in `undefined'");
        }
        /* Node format */
        else if ((m = loc.match(/^  from (.*?)$/))) {
          new_bt.push(m[1]);
        }
        /* Mozilla/Apple format */
        else if ((m = loc.match(/^(.*?)@(.*?)$/))) {
          new_bt.push(m[2] + ':in `' + m[1] + "'");
        }
      }

      return new_bt;
    }
  }

  def backtrace
    %x{
      if (self.backtrace) {
        // nil is a valid backtrace
        return self.backtrace;
      }

      var backtrace = self.stack;

      if (typeof(backtrace) !== 'undefined' && backtrace.$$is_string) {
        return self.backtrace = correct_backtrace(backtrace.split("\n"));
      }
      else if (backtrace) {
        return self.backtrace = correct_backtrace(backtrace);
      }

      return [];
    }
  end

  def backtrace_locations
    %x{
      if (self.backtrace_locations) return self.backtrace_locations;
      self.backtrace_locations = #{backtrace&.map do |loc|
        ::Thread::Backtrace::Location.new(loc)
      end}
      return self.backtrace_locations;
    }
  end

  def cause
    `self.cause || nil`
  end

  def exception(str = nil)
    %x{
      if (str === nil || self === str) {
        return self;
      }

      var cloned = #{clone};
      cloned.message = str;
      if (self.backtrace) cloned.backtrace = self.backtrace.$dup();
      cloned.stack = self.stack;
      cloned.cause = self.cause;
      return cloned;
    }
  end

  # not using alias message to_s because you need to be able to override to_s and have message use overridden method, won't work with alias
  def message
    to_s
  end

  def full_message(kwargs = nil)
    unless defined? Hash
      # We are dealing with an unfully loaded Opal library, so we should
      # do with as little as we can.

      return "#{@message}\n#{`self.stack`}"
    end

    kwargs = {
      highlight: $stderr.respond_to?(:tty?) ? $stderr.tty? : false,
      order: :top
    }.merge(kwargs || {})
    highlight, order = kwargs[:highlight], kwargs[:order]

    ::Kernel.raise ::ArgumentError, "expected true or false as highlight: #{highlight}" unless [true, false].include? highlight
    ::Kernel.raise ::ArgumentError, "expected :top or :bottom as order: #{order}" unless %i[top bottom].include? order

    if highlight
      bold_underline = "\e[1;4m"
      bold = "\e[1m"
      reset = "\e[m"
    else
      bold_underline = bold = reset = ''
    end

    bt = backtrace.dup
    bt = caller if !bt || bt.empty?
    first = bt.shift

    msg = "#{first}: "
    msg += "#{bold}#{to_s} (#{bold_underline}#{self.class}#{reset}#{bold})#{reset}\n"

    msg += bt.map { |loc| "\tfrom #{loc}\n" }.join

    msg += cause.full_message(highlight: highlight) if cause

    if order == :bottom
      msg = msg.split("\n").reverse.join("\n")
      msg = "#{bold}Traceback#{reset} (most recent call last):\n" + msg
    end

    msg
  end

  def inspect
    as_str = to_s
    as_str.empty? ? self.class.to_s : "#<#{self.class.to_s}: #{to_s}>"
  end

  def set_backtrace(backtrace)
    %x{
      var valid = true, i, ii;

      if (backtrace === nil) {
        self.backtrace = nil;
        self.stack = '';
      } else if (backtrace.$$is_string) {
        self.backtrace = [backtrace];
        self.stack = '  from ' + backtrace;
      } else {
        if (backtrace.$$is_array) {
          for (i = 0, ii = backtrace.length; i < ii; i++) {
            if (!backtrace[i].$$is_string) {
              valid = false;
              break;
            }
          }
        } else {
          valid = false;
        }

        if (valid === false) {
          #{::Kernel.raise ::TypeError, 'backtrace must be Array of String'}
        }

        self.backtrace = backtrace;
        self.stack = #{`backtrace`.map { |i| '  from ' + i }}.join("\n");
      }

      return backtrace;
    }
  end

  def to_s
    # using self.message aka @message to retain compatibility with native exception's message property
    (@message && @message.to_s) || self.class.to_s
  end
end

# keep the indentation, it makes the exception hierarchy clear
class ::ScriptError       < ::Exception; end
class ::SyntaxError         < ::ScriptError; end
class ::LoadError           < ::ScriptError; end
class ::NotImplementedError < ::ScriptError; end

class ::SystemExit        < ::Exception; end
class ::NoMemoryError     < ::Exception; end
class ::SignalException   < ::Exception; end
class ::Interrupt           < ::SignalException; end
class ::SecurityError     < ::Exception; end
class ::SystemStackError  < ::Exception; end

class ::StandardError     < ::Exception; end
class ::EncodingError       < ::StandardError; end
class ::ZeroDivisionError   < ::StandardError; end
class ::NameError           < ::StandardError; end
class ::NoMethodError         < ::NameError; end
class ::RuntimeError        < ::StandardError; end
class ::FrozenError           < ::RuntimeError; end
class ::LocalJumpError      < ::StandardError; end
class ::TypeError           < ::StandardError; end
class ::ArgumentError       < ::StandardError; end
class ::UncaughtThrowError    < ::ArgumentError; end
class ::IndexError          < ::StandardError; end
class ::StopIteration         < ::IndexError; end
class ::ClosedQueueError        < ::StopIteration; end
class ::KeyError              < ::IndexError; end
class ::RangeError          < ::StandardError; end
class ::FloatDomainError      < ::RangeError; end
class ::IOError             < ::StandardError; end
class ::EOFError              < ::IOError; end
class ::SystemCallError     < ::StandardError; end
class ::RegexpError         < ::StandardError; end
class ::ThreadError         < ::StandardError; end
class ::FiberError          < ::StandardError; end

::Object.autoload :Errno, 'corelib/error/errno'

class ::FrozenError < ::RuntimeError
  attr_reader :receiver

  def initialize(message, receiver: nil)
    super message
    @receiver = receiver
  end
end

class ::UncaughtThrowError < ::ArgumentError
  attr_reader :tag, :value

  def initialize(tag, value = nil)
    @tag = tag
    @value = value

    super("uncaught throw #{@tag.inspect}")
  end
end

class ::NameError
  attr_reader :name

  def initialize(message, name = nil)
    super message
    @name = name
  end
end

class ::NoMethodError
  attr_reader :args

  def initialize(message, name = nil, args = [])
    super message, name
    @args = args
  end
end

class ::StopIteration
  attr_reader :result
end

class ::KeyError
  def initialize(message, receiver: nil, key: nil)
    super(message)
    @receiver = receiver
    @key = key
  end

  def receiver
    @receiver || ::Kernel.raise(::ArgumentError, 'no receiver is available')
  end

  def key
    @key || ::Kernel.raise(::ArgumentError, 'no key is available')
  end
end

class ::LocalJumpError
  attr_reader :exit_value, :reason

  def initialize(message, exit_value = nil, reason = :noreason)
    super message
    @exit_value = exit_value
    @reason = reason
  end
end

module ::JS
  class Error
  end
end
