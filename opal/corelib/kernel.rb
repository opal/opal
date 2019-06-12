module Kernel
  def method_missing(symbol, *args, &block)
    raise NoMethodError.new("undefined method `#{symbol}' for #{inspect}", symbol, args)
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

  def method(name)
    %x{
      var meth = self['$' + name];

      if (!meth || meth.$$stub) {
        #{raise NameError.new("undefined method `#{name}' for class `#{self.class}'", name)};
      }

      return #{Method.new(self, `meth.$$owner || #{self.class}`, `meth`, name)};
    }
  end

  def methods(all = true)
    %x{
      if (#{Opal.truthy?(all)}) {
        return Opal.methods(self);
      } else {
        return Opal.own_methods(self);
      }
    }
  end

  def public_methods(all = true)
    %x{
      if (#{Opal.truthy?(all)}) {
        return Opal.methods(self);
      } else {
        return Opal.receiver_methods(self);
      }
    }
  end

  def Array(object)
    %x{
      var coerced;

      if (object === nil) {
        return [];
      }

      if (object.$$is_array) {
        return object;
      }

      coerced = #{Opal.coerce_to?(object, Array, :to_ary)};
      if (coerced !== nil) { return coerced; }

      coerced = #{Opal.coerce_to?(object, Array, :to_a)};
      if (coerced !== nil) { return coerced; }

      return [object];
    }
  end

  def at_exit(&block)
    $__at_exit__ ||= []
    $__at_exit__ << block
  end

  # Opal does not support #caller, but we stub it as an empty array to not
  # break dependant libs
  def caller(*args)
    []
  end

  def class
    `self.$$class`
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

      if (other.hasOwnProperty('$$meta')) {
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

  def clone(freeze: true)
    copy = self.class.allocate

    copy.copy_instance_variables(self)
    copy.copy_singleton_methods(self)
    copy.initialize_clone(self)

    copy
  end

  def initialize_clone(other)
    initialize_copy(other)
  end

  def define_singleton_method(name, method = undefined, &block)
    singleton_class.define_method(name, method, &block)
  end

  def dup
    copy = self.class.allocate

    copy.copy_instance_variables(self)
    copy.initialize_dup(self)

    copy
  end

  def initialize_dup(other)
    initialize_copy(other)
  end

  def enum_for(method = :each, *args, &block)
    Enumerator.for(self, method, *args, &block)
  end

  alias to_enum enum_for

  def equal?(other)
    `self === other`
  end

  def exit(status = true)
    $__at_exit__ ||= []

    until $__at_exit__.empty?
      block = $__at_exit__.pop
      block.call
    end

    %x{
      if (status.$$is_boolean) {
        status = status ? 0 : 1;
      } else {
        status = #{Opal.coerce_to(status, Integer, :to_int)}
      }

      Opal.exit(status);
    }
    nil
  end

  def extend(*mods)
    %x{
      var singleton = #{singleton_class};

      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (!mod.$$is_module) {
          #{raise TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
        }

        #{`mod`.append_features `singleton`};
        #{`mod`.extend_object self};
        #{`mod`.extended self};
      }
    }

    self
  end

  def hash
    __id__
  end

  def initialize_copy(other)
  end

  def inspect
    to_s
  end

  def instance_of?(klass)
    %x{
      if (!klass.$$is_class && !klass.$$is_module) {
        #{raise TypeError, 'class or module required'};
      }

      return self.$$class === klass;
    }
  end

  def instance_variable_defined?(name)
    name = Opal.instance_variable_name!(name)

    `Opal.hasOwnProperty.call(self, name.substr(1))`
  end

  def instance_variable_get(name)
    name = Opal.instance_variable_name!(name)

    %x{
      var ivar = self[Opal.ivar(name.substr(1))];

      return ivar == null ? nil : ivar;
    }
  end

  def instance_variable_set(name, value)
    name = Opal.instance_variable_name!(name)

    `self[Opal.ivar(name.substr(1))] = value`
  end

  def remove_instance_variable(name)
    name = Opal.instance_variable_name!(name)

    %x{
      var key = Opal.ivar(name.substr(1)),
          val;
      if (self.hasOwnProperty(key)) {
        val = self[key];
        delete self[key];
        return val;
      }
    }

    raise NameError, "instance variable #{name} not defined"
  end

  def instance_variables
    %x{
      var result = [], ivar;

      for (var name in self) {
        if (self.hasOwnProperty(name) && name.charAt(0) !== '$') {
          if (name.substr(-1) === '$') {
            ivar = name.slice(0, name.length - 1);
          } else {
            ivar = name;
          }
          result.push('@' + ivar);
        }
      }

      return result;
    }
  end

  def Integer(value, base = undefined)
    %x{
      var i, str, base_digits;

      if (!value.$$is_string) {
        if (base !== undefined) {
          #{raise ArgumentError, 'base specified for non string value'}
        }
        if (value === nil) {
          #{raise TypeError, "can't convert nil into Integer"}
        }
        if (value.$$is_number) {
          if (value === Infinity || value === -Infinity || isNaN(value)) {
            #{raise FloatDomainError, value}
          }
          return Math.floor(value);
        }
        if (#{value.respond_to?(:to_int)}) {
          i = #{value.to_int};
          if (i !== nil) {
            return i;
          }
        }
        return #{Opal.coerce_to!(value, Integer, :to_i)};
      }

      if (value.toString() === "0") {
        return 0;
      }

      if (base === undefined) {
        base = 0;
      } else {
        base = #{Opal.coerce_to(`base`, Integer, :to_int)};
        if (base === 1 || base < 0 || base > 36) {
          #{raise ArgumentError, "invalid radix #{base}"}
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
        case '0':
        case '0o':
          if (base === 0 || base === 8) {
            base = 8;
            return head;
          }
        case '0d':
          if (base === 0 || base === 10) {
            base = 10;
            return head;
          }
        case '0x':
          if (base === 0 || base === 16) {
            base = 16;
            return head;
          }
        }
        #{raise ArgumentError, "invalid value for Integer(): \"#{value}\""}
      });

      base = (base === 0 ? 10 : base);

      base_digits = '0-' + (base <= 10 ? base - 1 : '9a-' + String.fromCharCode(97 + (base - 11)));

      if (!(new RegExp('^\\s*[+-]?[' + base_digits + ']+\\s*$')).test(str)) {
        #{raise ArgumentError, "invalid value for Integer(): \"#{value}\""}
      }

      i = parseInt(str, base);

      if (isNaN(i)) {
        #{raise ArgumentError, "invalid value for Integer(): \"#{value}\""}
      }

      return i;
    }
  end

  def Float(value)
    %x{
      var str;

      if (value === nil) {
        #{raise TypeError, "can't convert nil into Float"}
      }

      if (value.$$is_string) {
        str = value.toString();

        str = str.replace(/(\d)_(?=\d)/g, '$1');

        //Special case for hex strings only:
        if (/^\s*[-+]?0[xX][0-9a-fA-F]+\s*$/.test(str)) {
          return #{Integer(`str`)};
        }

        if (!/^\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?\s*$/.test(str)) {
          #{raise ArgumentError, "invalid value for Float(): \"#{value}\""}
        }

        return parseFloat(str);
      }

      return #{Opal.coerce_to!(value, Float, :to_f)};
    }
  end

  def Hash(arg)
    return {} if arg.nil? || arg == []
    return arg if Hash === arg
    Opal.coerce_to!(arg, Hash, :to_hash)
  end

  def is_a?(klass)
    %x{
      if (!klass.$$is_class && !klass.$$is_module) {
        #{raise TypeError, 'class or module required'};
      }

      return Opal.is_a(self, klass);
    }
  end

  def itself
    self
  end

  alias kind_of? is_a?

  def lambda(&block)
    `Opal.lambda(block)`
  end

  def load(file)
    file = Opal.coerce_to!(file, String, :to_str)
    `Opal.load(#{file})`
  end

  def loop
    return enum_for(:loop) { Float::INFINITY } unless block_given?

    while true
      begin
        yield
      rescue StopIteration => e
        return e.result
      end
    end

    self
  end

  def nil?
    false
  end

  alias object_id __id__

  def printf(*args)
    if args.any?
      print format(*args)
    end

    nil
  end

  def proc(&block)
    unless block
      raise ArgumentError, 'tried to create Proc object without a block'
    end

    `block.$$is_lambda = false`
    block
  end

  def puts(*strs)
    $stdout.puts(*strs)
  end

  def p(*args)
    args.each { |obj| $stdout.puts obj.inspect }

    args.length <= 1 ? args[0] : args
  end

  def print(*strs)
    $stdout.print(*strs)
  end

  def warn(*strs)
    $stderr.puts(*strs) unless $VERBOSE.nil? || strs.empty?
  end

  def raise(exception = undefined, string = nil, _backtrace = nil)
    %x{
      if (exception == null && #{$!} !== nil) {
        throw #{$!};
      }
      if (exception == null) {
        exception = #{RuntimeError.new};
      }
      else if (exception.$$is_string) {
        exception = #{RuntimeError.new exception};
      }
      // using respond_to? and not an undefined check to avoid method_missing matching as true
      else if (exception.$$is_class && #{exception.respond_to?(:exception)}) {
        exception = #{exception.exception string};
      }
      else if (#{exception.is_a?(Exception)}) {
        // exception is fine
      }
      else {
        exception = #{TypeError.new 'exception class/object expected'};
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
    %x{
      if (max === undefined) {
        return #{Random::DEFAULT.rand};
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
    Random::DEFAULT.rand(max)
  end

  def respond_to?(name, include_all = false)
    return true if respond_to_missing?(name, include_all)

    %x{
      var body = self['$' + name];

      if (typeof(body) === "function" && !body.$$stub) {
        return true;
      }
    }

    false
  end

  def respond_to_missing?(method_name, include_all = false)
    false
  end

  def require(file)
    file = Opal.coerce_to!(file, String, :to_str)
    `Opal.require(#{file})`
  end

  def require_relative(file)
    Opal.try_convert!(file, String, :to_str)
    file = File.expand_path File.join(`Opal.current_file`, '..', file)

    `Opal.require(#{file})`
  end

  # `path` should be the full path to be found in registered modules (`Opal.modules`)
  def require_tree(path)
    %x{
      var result = [];

      path = #{File.expand_path(path)}
      path = Opal.normalize(path);
      if (path === '.') path = '';
      for (var name in Opal.modules) {
        if (#{`name`.start_with?(path)}) {
          result.push([name, Opal.require(name)]);
        }
      }

      return result;
    }
  end

  alias send        __send__
  alias public_send __send__

  def singleton_class
    `Opal.get_singleton_class(self)`
  end

  def sleep(seconds = nil)
    %x{
      if (seconds === nil) {
        #{raise TypeError, "can't convert NilClass into time interval"}
      }
      if (!seconds.$$is_number) {
        #{raise TypeError, "can't convert #{seconds.class} into time interval"}
      }
      if (seconds < 0) {
        #{raise ArgumentError, 'time interval must be positive'}
      }
      var get_time = Opal.global.performance ?
        function() {return performance.now()} :
        function() {return new Date()}

      var t = get_time();
      while (get_time() - t <= seconds * 1000);
      return seconds;
    }
  end

  def srand(seed = Random.new_seed)
    Random.srand(seed)
  end

  def String(str)
    Opal.coerce_to?(str, String, :to_str) ||
      Opal.coerce_to!(str, String, :to_s)
  end

  def tap(&block)
    yield self
    self
  end

  def to_proc
    self
  end

  def to_s
    "#<#{self.class}:0x#{__id__.to_s(16)}>"
  end

  def catch(sym)
    yield
  rescue UncaughtThrowError => e
    return e.arg if e.sym == sym
    raise
  end

  def throw(*args)
    raise UncaughtThrowError, args
  end

  # basic implementation of open, delegate to File.open
  def open(*args, &block)
    File.open(*args, &block)
  end

  def yield_self
    return enum_for(:yield_self) { 1 } unless block_given?
    yield self
  end
end

class Object
  include Kernel
end
