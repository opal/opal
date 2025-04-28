# helpers: truthy, coerce_to, respond_to, Opal, deny_frozen_access, freeze, freeze_props, jsid, each_ivar, slice, platform
# use_strict: true
# backtick_javascript: true
require 'corelib/process/status'

module ::Kernel
  # TODO: This is just here as a workaround, must be removed before merge/release
  def __dir__
    # Returns the canonicalized absolute path of the directory of the file from which this method is called.
    File.realpath(File.dirname(__FILE__))
  end

  def `(cmdline)
    # Returns the $stdout output from running command in a subshell; sets global variable $? to the process status.
    cmdline = ::Opal.coerce_to!(cmdline, ::String, :to_str)
    out = `$platform.process_spawn(#{cmdline}, [], { shell: true, stdio: 'pipe', wait: true })`

    status = `out.status > 128 ? out.status - 128 : out.status`
    pid = `out.pid == null ? nil : out.pid`
    $? = ::Process::Status.new(status, pid)

    raise ::Errno::ENOENT if `out.status == 126 || out.status == 127`

    $stderr.write(`out.stderr`) if `out.stderr`
    `Opal.str(out.stdout, #{::Encoding.default_external})`
  end

  def =~(obj)
    false
  end

  def !~(obj)
    !(self =~ obj)
  end

  def ===(other)
    object_id == other.object_id || self == other
  end

  def <=>(other)
    %x{
      // set guard for infinite recursion
      self.$$comparable = true;

      var x = #{self == other};

      if (x && x !== nil) {
        return 0;
      }

      return nil;
    }
  end

  def Array(object)
    # Returns an array converted from object.
    %x{
      var coerced;

      if (object === nil) {
        return [];
      }

      if (object.$$is_array) {
        return object;
      }

      coerced = #{::Opal.coerce_to?(object, ::Array, :to_ary)};
      if (coerced !== nil) { return coerced; }

      coerced = #{::Opal.coerce_to?(object, ::Array, :to_a)};
      if (coerced !== nil) { return coerced; }

      return [object];
    }
  end

  # Complex - is in corelib/complex/base.rb

  def Float(value, exception: true)
    # Returns value converted to a float.
    %x{
      var str;

      exception = $truthy(#{exception});

      if (value === nil) {
        if (exception) {
          #{::Kernel.raise ::TypeError, "can't convert nil into Float"}
        } else {
          return nil;
        }
      }

      if (value.$$is_string) {
        str = value.toString();

        str = str.replace(/(\d)_(?=\d)/g, '$1');

        //Special case for hex strings only:
        if (/^\s*[-+]?0[xX][0-9a-fA-F]+\s*$/.test(str)) {
          return #{::Kernel.Integer(`str`)};
        }

        if (!/^\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?\s*$/.test(str)) {
          if (exception) {
            #{::Kernel.raise ::ArgumentError, "invalid value for Float(): \"#{value}\""}
          } else {
            return nil;
          }
        }

        return parseFloat(str);
      }

      if (exception) {
        return #{::Opal.coerce_to!(value, ::Float, :to_f)};
      } else {
        return $coerce_to(value, #{::Float}, 'to_f');
      }
    }
  end

  def Hash(arg)
    # Returns a hash converted from object.
    return {} if arg.nil? || arg == []
    return arg if ::Hash === arg
    ::Opal.coerce_to!(arg, ::Hash, :to_hash)
  end

  def Integer(value, base = undefined, exception: true)
    # Returns an integer converted from object.
    %x{
      var i, str, base_digits;

      exception = $truthy(#{exception});

      if (!value.$$is_string) {
        if (base !== undefined) {
          if (exception) {
            #{::Kernel.raise ::ArgumentError, 'base specified for non string value'}
          } else {
            return nil;
          }
        }
        if (value === nil) {
          if (exception) {
            #{::Kernel.raise ::TypeError, "can't convert nil into Integer"}
          } else {
            return nil;
          }
        }
        if (value.$$is_number) {
          if (value === Infinity || value === -Infinity || isNaN(value)) {
            if (exception) {
              #{::Kernel.raise ::FloatDomainError, value}
            } else {
              return nil;
            }
          }
          return Math.floor(value);
        }
        if (#{value.respond_to?(:to_int)}) {
          i = #{value.to_int};
          if (Opal.is_a(i, #{::Integer})) {
            return i;
          }
        }
        if (#{value.respond_to?(:to_i)}) {
          i = #{value.to_i};
          if (Opal.is_a(i, #{::Integer})) {
            return i;
          }
        }

        if (exception) {
          #{::Kernel.raise ::TypeError, "can't convert #{value.class} into Integer"}
        } else {
          return nil;
        }
      }

      if (value === "0") {
        return 0;
      }

      if (base === undefined) {
        base = 0;
      } else {
        base = $coerce_to(base, #{::Integer}, 'to_int');
        if (base === 1 || base < 0 || base > 36) {
          if (exception) {
            #{::Kernel.raise ::ArgumentError, "invalid radix #{base}"}
          } else {
            return nil;
          }
        }
      }

      str = value.toLowerCase();

      str = str.replace(/(\d)_(?=\d)/g, '$1');

      str = str.replace(/^(\s*[+-]?)(0[bodx]?)/, function (_, head, flag) {
        switch (flag) {
        case '0b':
          if (base === 0 || base === 2) {
            base = 2;
            return head;
          }
          // no-break
        case '0':
        case '0o':
          if (base === 0 || base === 8) {
            base = 8;
            return head;
          }
          // no-break
        case '0d':
          if (base === 0 || base === 10) {
            base = 10;
            return head;
          }
          // no-break
        case '0x':
          if (base === 0 || base === 16) {
            base = 16;
            return head;
          }
          // no-break
        }
        if (exception) {
          #{::Kernel.raise ::ArgumentError, "invalid value for Integer(): \"#{value}\""}
        } else {
          return nil;
        }
      });

      base = (base === 0 ? 10 : base);

      base_digits = '0-' + (base <= 10 ? base - 1 : '9a-' + String.fromCharCode(97 + (base - 11)));

      if (!(new RegExp('^\\s*[+-]?[' + base_digits + ']+\\s*$')).test(str)) {
        if (exception) {
          #{::Kernel.raise ::ArgumentError, "invalid value for Integer(): \"#{value}\""}
        } else {
          return nil;
        }
      }

      i = parseInt(str, base);

      if (isNaN(i)) {
        if (exception) {
          #{::Kernel.raise ::ArgumentError, "invalid value for Integer(): \"#{value}\""}
        } else {
          return nil;
        }
      }

      return i;
    }
  end

  # JSON - is in stdlib/json.rb

  # Pathname - is in stdlib/pathname.rb

  # Rational - is in corelib/rational/base.rb

  def String(str)
    ::Opal.coerce_to?(str, ::String, :to_str) || ::Opal.coerce_to!(str, ::String, :to_s)
  end

  # URI - is not implemented yet

  def abort(msg = nil)
    # Terminates execution immediately, effectively by calling Kernel.exit(false).
    ::Process.abort(msg)
  end

  def at_exit(&block)
    # Converts block to a Proc object (and therefore binds it at the point of call)
    # and registers it for execution when the program exits.
    # If multiple handlers are registered,
    # they are executed in reverse order of registration.
    raise(::ArgumentError, 'called without a block') unless block_given?
    $__at_exit__ ||= []
    $__at_exit__ << block
    block
  end

  # autoload - early stage is in corelib/main.rb and normal stage is in corelib/module.rb

  # autoload? - is in corelib/module.rb

  # binding - is in corelib/binding.rb

  # block_given? - is handled by the compiler

  # callcc - is obsolete and we don't have a 'continuation' module

  def caller(start = 1, length = nil)
    # Returns the current execution stack—an array containing strings in the form file:line or file:line: in `method'.
    %x{
      var stack, result;

      stack = new Error().$backtrace();
      result = [];

      for (var i = #{start} + 1, ii = stack.length; i < ii; i++) {
        if (!stack[i].match(/runtime\//)) {
          result.push(stack[i]);
        }
      }
      if (length != nil) result = result.slice(0, length);
      return result;
    }
  end

  def caller_locations(*args)
    # Returns the current execution stack—an array containing backtrace location objects.
    caller(*args).map do |loc|
      ::Thread::Backtrace::Location.new(loc)
    end
  end

  def catch(tag = nil)
    # catch executes its block. If throw is not called, the block executes normally
    # and catch returns the value of the last expression evaluated.
    # If throw(tag2, val) is called, Ruby searches up its stack for a catch block
    # whose tag has the same object_id as tag2. When found, the block stops
    # executing and returns val (or nil if no second argument was given to throw).
    tag ||= ::Object.new
    yield(tag)
  rescue ::UncaughtThrowError => e
    return e.value if e.tag == tag
    ::Kernel.raise
  end

  # chomp - not supported

  # chop - not supported

  def class
    # Returns the class of obj.
    `self.$$class`
  end

  def clone(freeze: nil)
    # Produces a shallow copy of obj—the instance variables of obj are copied, but not the objects they reference.
    unless freeze.nil? || freeze == true || freeze == false
      raise ArgumentError, "unexpected value for freeze: #{freeze.class}"
    end

    copy = self.class.allocate

    copy.copy_instance_variables(self)
    copy.copy_singleton_methods(self)
    copy.initialize_clone(self, freeze: freeze)

    if freeze == true || (freeze.nil? && frozen?)
      copy.freeze
    end

    copy
  end

  def define_singleton_method(name, method = undefined, &block)
    # Defines a public singleton method in the receiver.
    singleton_class.define_method(name, method, &block)
  end

  # eval - is in corelib/unsupported.rb

  def exec(*argv)
    # Replaces the current process by doing one of the following:
    #   Passing string command_line to the shell.
    #   Invoking the executable at exe_path.
    ::Process.exec(*argv)
  end

  def exit(status = true)
    # Initiates termination of the Ruby script by raising SystemExit; the exception may be caught.
    # Returns exit status status to the underlying operating system.
    ::Process.exit(status)
  end

  def exit!(status = false)
    # Exits the process immediately; no exit handlers are called.
    # Returns exit status status to the underlying operating system.
    ::Process.exit!(status)
  end

  # fail - aliased to raise below

  def fork(&block)
    # Creates a child process.
    ::Process.fork(&block)
  end

  # format - is in corelib/kernel/format.rb

  def frozen?
    # Returns the freeze status of obj.
    %x{
      switch (typeof(self)) {
      case "string":
      case "symbol":
      case "number":
      case "boolean":
        return true;
      case "object":
      case "function":
        return (self.$$frozen || false);
      default:
        return false;
      }
    }
  end

  # gem - not supported yet

  def gets(*args)
    # Returns (and assigns to $_) the next line from the list of files in ARGV (or $*), or from standard input.
    ::ARGF.gets(*args)
  end

  def global_variables
    # Returns an array of the names of global variables.
    `Object.keys(Opal.gvars)`
  end

  # gsub - not supported

  # iterator? - deprecated, not supported

  # j - in stdlib/json.rb

  # jj - in stdlib/json.rb; not

  def lambda(&block)
    # Equivalent to Proc.new, except the resulting Proc objects check the number of parameters passed when called.
    `Opal.lambda(block)`
  end

  def load(file)
    # Loads and executes the Ruby program in the file filename.
    file = ::Opal.coerce_to!(file, ::String, :to_str)
    `Opal.load(#{file})`
  end

  # local_variables - handled by the compiler

  def loop
    # Repeatedly executes the block.
    return enum_for(:loop) { ::Float::INFINITY } unless block_given?

    while true
      begin
        yield
      rescue ::StopIteration => e
        return e.result
      end
    end

    self
  end

  def open(obj, *args, &block)
    # Creates an IO object connected to the given file.
    if obj.respond_to?(:to_open)
      obj = obj.to_open(*args)
      return yield obj if block_given?
      obj
    elsif obj.is_a?(Numeric)
      raise TypeError
    else
      ::File.open(obj, *args, &block)
    end
  end

  def p(*args)
    # For each object obj, executes: $stdout.write(obj.inspect, "\n")
    args.each { |obj| $stdout.puts obj.inspect }

    args.length <= 1 ? args[0] : args
  end

  # pp - is in stdlib/pp.rb

  # pretty_inspect - is in stdlib/pp.rb

  def print(*strs)
    # Equivalent to $stdout.print(*objects)
    $stdout.print(*strs)
  end

  # printf - is in corelib/kernel/format.rb

  def proc(&block)
    # Equivalent to Proc.new.
    unless block
      ::Kernel.raise ::ArgumentError, 'tried to create Proc object without a block'
    end

    `block.$$is_lambda = false`
    block
  end

  def putc(object)
    # Equivalent to: $stdout.putc(int)
    $stdout.putc(object)
  end

  def puts(*strs)
    # Equivalent to $stdout.puts(objects)
    $stdout.puts(*strs)
  end

  def raise(exception = undefined, string = nil, backtrace = nil)
    # Raises an exception
    %x{
      if (exception == null && #{$!} !== nil) {
        throw #{$!};
      }
      if (exception == null) {
        exception = #{::RuntimeError.new ''};
      }
      else if ($respond_to(exception, '$to_str')) {
        exception = #{::RuntimeError.new exception.to_str};
      }
      // using respond_to? and not an undefined check to avoid method_missing matching as true
      else if (exception.$$is_class && $respond_to(exception, '$exception')) {
        exception = #{exception.exception string};
      }
      else if (exception.$$is_exception) {
        // exception is fine
      }
      else {
        exception = #{::TypeError.new 'exception class/object expected'};
      }

      if (backtrace !== nil) {
        exception.$set_backtrace(backtrace);
      }

      if (#{$!} !== nil) {
        Opal.exceptions.push(#{$!});
      }

      #{$!} = exception;

      throw exception;
    }
  end

  alias fail raise

  def rand(max = undefined)
    # If called without an argument, or if max.to_i.abs == 0,
    # rand returns a pseudo-random floating point number between 0.0 and 1.0, including 0.0 and excluding 1.0.
    # When max.abs is greater than or equal to 1,
    # rand returns a pseudo-random integer greater than or equal to 0 and less than max.to_i.abs.
    %x{
      if (max === undefined) {
        return #{::Random::DEFAULT.rand};
      }

      if (max.$$is_number) {
        if (max < 0) {
          max = Math.abs(max);
        }

        if (max % 1 !== 0) {
          max = max.$to_i();
        }

        if (max === 0) {
          max = undefined;
        }
      }
    }
    ::Random::DEFAULT.rand(max)
  end

  def readline(*args)
    # Equivalent to method Kernel#gets, except that it raises an exception if called at end-of-stream.
    $stdin.readline(*args)
  end

  def readlines(*args)
    # Returns an array containing the lines returned by calling Kernel#gets until the end-of-stream is reached.
    $stdin.readlines(*args)
  end

  def require(file)
    # If the file can be loaded from the existing Ruby loadpath as crystallized in Opal.modules, it is.
    %x{
      // As Object.require refers to Kernel.require once Kernel has been loaded the String
      // class may not be available yet, the coercion requires both String and Array to be loaded.
      if (typeof #{file} !== 'string' && Opal.String && Opal.Array) {
        #{file = ::Opal.coerce_to!(file, ::String, :to_str) }
      }
      return Opal.require(#{file})
    }
  end

  def require_relative(file)
    # Ruby tries to load the library named string relative to the directory containing the requiring file.
    ::Opal.try_convert!(file, ::String, :to_str)
    file = ::File.expand_path ::File.join(`Opal.current_file`, '..', file)

    `Opal.require(#{file})`
  end

  # select - not supported

  # set_trace_func - obsolete

  def singleton_class
    # Returns the singleton class of obj.
    `Opal.get_singleton_class(self)`
  end

  def sleep(seconds = nil)
    # Suspends execution of the current thread for the number of seconds specified by numeric argument secs,
    # or forever if secs is nil; returns the integer number of seconds suspended (rounded)
    %x{
      if (seconds === nil) {
        #{::Kernel.raise ::TypeError, "can't convert NilClass into time interval"}
      }
      if (!seconds.$$is_number) {
        #{::Kernel.raise ::TypeError, "can't convert #{seconds.class} into time interval"}
      }
      if (seconds < 0) {
        #{::Kernel.raise ::ArgumentError, 'time interval must be positive'}
      }
      if (typeof(Opal.global.Atomics) === "object") {
        Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, Math.round(seconds * 1000));
      } else {
        var get_time = Opal.global.performance ?
          function() {return performance.now()} :
          function() {return new Date()}

        var t = get_time();
        while (get_time() - t <= seconds * 1000);
      }
      return Math.round(seconds);
    }
  end

  def spawn(*argv)
    # Creates a new child process by doing one of the following in that process:
    #   Passing string command_line to the shell.
    #   Invoking the executable at exe_path.
    ::Process.spawn(*argv)
  end

  # sprintf - is in corelib/kernel/format.rb

  def srand(seed = ::Random.new_seed)
    # Seeds the system pseudo-random number generator, with number. The previous seed value is returned.
    ::Random.srand(seed)
  end

  # sub - not supported

  # syscall - not supported

  def system(*argv, exception: false)
    # Creates a new child process by doing one of the following in that process:
    #   Passing string command_line to the shell.
    #   Invoking the executable at exe_path.
    env = {}
    env = argv.shift if argv.first.is_a? ::Hash
    env = ::ENV.merge(env)
    js_env = `{}`
    env.each { |k, v| `js_env[k] = v.toString()` }
    `delete js_env["SHELL"]`
    js_opts = `{ stdio: 'pipe', env: js_env, wait: true }`

    cmdname = argv.shift
    if Array === cmdname
      `js_opts.argv0 = #{cmdname[1]}`
      cmdname = cmdname[0]
    end

    opts = argv.shift

    if opts.is_a?(::Hash)
      `js_opts.cwd = #{opts[:chdir]}` if opts.key?(:chdir)
      so = opts[:out]
      se = opts[:err]
    end

    `js_opts.shell = true` unless ::File.absolute_path?(cmdname)

    out = `$platform.process_spawn(#{cmdname}, #{argv}, js_opts)`

    status = `out.status > 128 ? out.status - 128 : out.status`
    pid = `out.pid == null ? nil : out.pid`
    $? = ::Process::Status.new(status, pid)

    if exception
      raise ::Errno::ENOENT if `out.status == 126 || out.status == 127`
      raise "Command failed with exit #{status}: #{cmdname}" if status != 0
      raise `out.error` if `out.error`
    end

    return nil if `out.error || out.status > 125`

    (so || $stdout).write(`out.stdout`) if `out.stdout`
    (se || $stderr).write(`out.stderr`) if `out.stderr`

    status == 0
  end

  def tap(&block)
    # Yields self to the block and then returns self.
    yield self
    self
  end

  # test - in corelib/file_test.rb

  # then - aliased to yield_self below

  def throw(tag, obj = nil)
    # Transfers control to the end of the active catch block waiting for tag.
    ::Kernel.raise ::UncaughtThrowError.new(tag, obj)
  end

  # trace_var - not supported

  def trap(signal, command = nil, &block)
    if signal.is_a?(::Integer)
      signal = ::Signal.list.key(signal)
      raise(::ArgumentError, 'unknown signal') unless signal
    elsif signal.is_a?(::String)
      signal = signal[1..] if signal[0] == '-'
      raise(::ArgumentError, 'unknown signal') if signal != signal.upcase
      signal = signal[3..] if signal.start_with?('SIG')
      raise(::ArgumentError, 'unknown signal') unless ::Signal.list.key?(signal)
    else
      raise(::ArgumentError, 'signal must be Integer or String')
    end
    command ||= 'USETHEBLOCK'
    `$platform.process_trap(signal, command, block)` || nil
  end

  # untrace_var - not supported

  def warn(*strs, uplevel: nil)
    # If warnings have been disabled (for example with the -W0 flag), does nothing.
    # Otherwise, converts each of the messages to strings,
    # appends a newline character to the string if the string does not end in a newline,
    # and calls Warning.warn with the string.
    if uplevel
      uplevel = ::Opal.coerce_to!(uplevel, ::Integer, :to_str)
      ::Kernel.raise ::ArgumentError, "negative level (#{uplevel})" if uplevel < 0
      location = caller(uplevel + 1, 1).first&.split(':in `')&.first
      location = "#{location}: " if location
      strs = strs.map { |s| "#{location}warning: #{s}" }
    end

    $stderr.puts(*strs) unless $VERBOSE.nil? || strs.empty?
  end

  # y - not supported

  def yield_self
    # Yields self to the block and returns the result of the block.
    return enum_for(:yield_self) { 1 } unless block_given?
    yield self
  end

  alias then yield_self

  #
  # methods of BasicObject
  #

  def equal?(other)
    # Equality — At the Object level, == returns true only if obj and other are the same object. Typically,
    # this method is overridden in descendant classes to provide class-specific meaning.
    `self === other`
  end

  #
  # methods of Object
  #

  def dup
    # Produces a shallow copy of obj—the instance variables of obj are copied, but not the objects they reference.
    copy = self.class.allocate

    copy.copy_instance_variables(self)
    copy.initialize_dup(self)

    copy
  end

  def enum_for(method = :each, *args, &block)
    # Creates a new Enumerator which will enumerate by calling method on obj, passing args if any.
    ::Enumerator.for(self, method, *args, &block)
  end

  def extend(*mods)
    # Adds to obj the instance methods from each module given as a parameter.
    %x{
      if (mods.length == 0) {
        #{raise ::ArgumentError, 'wrong number of arguments (given 0, expected 1+)'}
      }

      $deny_frozen_access(self);

      var singleton = #{singleton_class};

      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (!mod.$$is_module) {
          #{::Kernel.raise ::TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
        }

        #{`mod`.append_features `singleton`};
        #{`mod`.extend_object self};
        #{`mod`.extended self};
      }
    }

    self
  end

  def freeze
    # Prevents further modifications to obj.
    return self if frozen?

    %x{
      if (typeof(self) === "object") {
        $freeze_props(self);
        return $freeze(self);
      }
      return self;
    }
  end

  `var inspect_stack = []`

  def inspect
    # Returns a string containing a human-readable representation of obj.
    ivs = ''
    id = __id__
    if `inspect_stack`.include? id
      ivs = ' ...'
    else
      `inspect_stack` << id
      pushed = true
      instance_variables.each do |i|
        ivar = instance_variable_get(i)
        inspect = Opal.inspect(ivar)
        ivs += " #{i}=#{inspect}"
      end
    end
    "#<#{self.class}:0x#{id.to_s(16)}#{ivs}>"
  rescue => e
    "#<#{self.class}:0x#{id.to_s(16)}>"
  ensure
    `inspect_stack`.pop if pushed
  end

  def instance_of?(klass)
    # Returns true if obj is an instance of the given class.
    %x{
      if (!klass.$$is_class && !klass.$$is_module) {
        #{::Kernel.raise ::TypeError, 'class or module required'};
      }

      return self.$$class === klass;
    }
  end

  def instance_variable_defined?(name)
    # Returns true if the given instance variable is defined in obj.
    name = ::Opal.instance_variable_name!(name)

    `Opal.hasOwnProperty.call(self, name.substr(1))`
  end

  def instance_variable_get(name)
    # Returns the value of the given instance variable, or nil if the instance variable is not set.
    name = ::Opal.instance_variable_name!(name)

    %x{
      var ivar = self[Opal.ivar(name.substr(1))];

      return ivar == null ? nil : ivar;
    }
  end

  def instance_variable_set(name, value)
    # Sets the instance variable named by symbol to the given object.
    `$deny_frozen_access(self)`

    name = ::Opal.instance_variable_name!(name)

    `self[Opal.ivar(name.substr(1))] = value`
  end

  def instance_variables
    # Returns an array of instance variable names for the receiver.
    %x{
      var result = [], name;

      $each_ivar(self, function(name) {
        if (name[name.length-1] === '$') {
          name = name.slice(0, name.length - 1);
        }
        result.push('@' + name);
      });

      return result;
    }
  end

  def is_a?(klass)
    # Returns true if class is the class of obj,
    # or if class is one of the superclasses of obj or modules included in obj.
    %x{
      if (!klass.$$is_class && !klass.$$is_module) {
        #{::Kernel.raise ::TypeError, 'class or module required'};
      }

      return Opal.is_a(self, klass);
    }
  end

  def itself
    # Returns the receiver.
    self
  end

  alias kind_of? is_a?

  def method(name)
    # Looks up the named method as a receiver in obj, returning a Method object (or raising NameError).
    %x{
      var meth = self[$jsid(name)];

      if (meth && !meth.$$stub) {
        return #{::Method.new(self, `meth.$$owner || #{self.class}`, `meth`, name)};
      }

      var respond_to_missing = self['$respond_to_missing?'];
      if (respond_to_missing.$$pristine || !respond_to_missing.call(self, name, true)) {
        #{::Kernel.raise ::NameError.new("undefined method `#{name}' for class `#{self.class}'", name)};
      }

      meth = function wrapper() {
        var method_missing = self.$method_missing;
        if (method_missing == null) {
          #{::Kernel.raise ::NameError.new("undefined method `#{name}' for class `#{self.class}'", name)};
        }
        method_missing.$$p = wrapper.$$p;
        return method_missing.apply(self, [name].concat($slice(arguments)));
      };
      meth.$$parameters = [['rest']]
      meth.$$arity = -1;
      return #{::Method.new(self, self.class, `meth`, name)};
    }
  end

  def methods(all = true)
    # Returns a list of the names of public and protected methods of obj.
    %x{
      if ($truthy(#{all})) {
        return Opal.methods(self);
      } else {
        return Opal.own_methods(self);
      }
    }
  end

  def nil?
    # Only the object nil responds true to nil?.
    false
  end

  alias object_id __id__ # Returns an integer identifier for obj.

  def public_methods(all = true)
    # Returns the list of public methods accessible to obj.
    %x{
      if ($truthy(#{all})) {
        return Opal.methods(self);
      } else {
        return Opal.receiver_methods(self);
      }
    }
  end

  alias public_send __send__ # Invokes the method identified by symbol, passing it any arguments specified.

  def remove_instance_variable(name)
    # Removes the named instance variable from obj, returning that variable’s value.
    name = ::Opal.instance_variable_name!(name)

    %x{
      var key = Opal.ivar(name.substr(1)),
          val;
      if (self.hasOwnProperty(key)) {
        val = self[key];
        delete self[key];
        return val;
      }
    }

    ::Kernel.raise ::NameError, "instance variable #{name} not defined"
  end

  def respond_to?(name, include_all = false)
    # Returns true if obj responds to the given method.
    # Private and protected methods are included in the search only if the optional second parameter evaluates to true.
    %x{
      var body = self[$jsid(name)];

      if (typeof(body) === "function" && !body.$$stub) {
        return true;
      }

      if (self['$respond_to_missing?'].$$pristine === true) {
        return false;
      } else {
        return #{respond_to_missing?(name, include_all)};
      }
    }
  end

  def respond_to_missing?(method_name, include_all = false)
    # Hook method to return whether the obj can respond to id method or not.
    false
  end

  ::Opal.pristine(self, :respond_to?, :respond_to_missing?)

  alias send __send__ # Invokes the method identified by symbol, passing it any arguments specified.

  def singleton_methods(all = true)
    # Returns an array of the names of singleton methods for obj. If the optional all parameter is true, the list will include methods in modules included in obj.
    # Only public and protected singleton methods are returned.
    res = []
    origin = self.class
    singleton = singleton_class

    if singleton
      if all
        mods = singleton.ancestors
        prep_mods = `origin.$$own_prepended_modules`
        origin = prep_mods.first if prep_mods.any?
        mods.each do |mod|
          break if mod == origin
          res.concat(`Opal.own_instance_methods(mod)`)
        end
      else
        res.concat(`Opal.own_instance_methods(singleton)`)
      end
    end

    res.uniq!
    res
  end

  alias to_enum enum_for

  def to_s
    # Returns a string representing obj.
    `Opal.fallback_to_s(self)`
  end

  #
  # Opal specific helpers
  #

  def __not_implemented__(*args)
    # convenience method to be aliased to, to save some code, e.g:
    #   alias fancy_method __not_implemented__
    raise ::NotImplementedError
  end

  def copy_instance_variables(other)
    %x{
      var keys = Object.keys(other), i, ii, name;
      for (i = 0, ii = keys.length; i < ii; i++) {
        name = keys[i];
        if (name.charAt(0) !== '$' && other.hasOwnProperty(name)) {
          self[name] = other[name];
        }
      }
    }
  end

  def copy_singleton_methods(other)
    %x{
      var i, name, names, length;

      if (other.hasOwnProperty('$$meta') && other.$$meta !== null) {
        var other_singleton_class = Opal.get_singleton_class(other);
        var self_singleton_class = Opal.get_singleton_class(self);
        names = Object.getOwnPropertyNames(other_singleton_class.$$prototype);

        for (i = 0, length = names.length; i < length; i++) {
          name = names[i];
          if (Opal.is_method(name)) {
            self_singleton_class.$$prototype[name] = other_singleton_class.$$prototype[name];
          }
        }

        self_singleton_class.$$const = Object.assign({}, other_singleton_class.$$const);
        Object.setPrototypeOf(
          self_singleton_class.$$prototype,
          Object.getPrototypeOf(other_singleton_class.$$prototype)
        );
      }

      for (i = 0, names = Object.getOwnPropertyNames(other), length = names.length; i < length; i++) {
        name = names[i];
        if (name.charAt(0) === '$' && name.charAt(1) !== '$' && other.hasOwnProperty(name)) {
          self[name] = other[name];
        }
      }
    }
  end

  def initialize_clone(other, freeze: nil)
    initialize_copy(other)
    self
  end

  def initialize_copy(other)
  end

  def initialize_dup(other)
    initialize_copy(other)
  end

  def hash
    __id__
  end

  # `path` should be the full path to be found in registered modules (`Opal.modules`)
  def require_tree(path, autoload: false)
    %x{
      var result = [];

      path = Opal.expand_module_path(path);
      path = Opal.normalize(path);
      if (path === '.') path = '';
      for (var name in Opal.modules) {
        if (#{`name`.start_with?(path)}) {
          if(!#{autoload}) {
            result.push([name, Opal.require(name)]);
          } else {
            result.push([name, true]); // do nothing, delegated to a autoloading
          }
        }
      }

      return result;
    }
  end

  def to_proc
    self
  end
end

class ::Object
  # Object.require has been set to runtime.js Opal.require
  # Now we have Kernel loaded, make sure Object.require refers to Kernel.require
  # which is what ruby does and allows for overwriting by autoloaders
  `delete $Object.$$prototype.$require`
  include ::Kernel
end
