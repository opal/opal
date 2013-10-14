module Kernel
  def method_missing(symbol, *args, &block)
    raise NoMethodError, "undefined method `#{symbol}' for #{inspect}"
  end

  def =~(obj)
    false
  end

  def ===(other)
    self == other
  end

  def <=>(other)
    %x{
      if (#{self == other}) {
        return 0;
      }

      return nil;
    }
  end

  def method(name)
    %x{
      var meth = self['$' + name];

      if (!meth || meth.rb_stub) {
        #{raise NameError, "undefined method `#{name}' for class `#{self.class.name}'"};
      }

      return #{Method.new(self, `meth`, name)};
    }
  end

  def methods(all = true)
    %x{
      var methods = [];
      for(var k in #{self}) {
        if(k[0] == "$" && typeof (#{self})[k] === "function") {
          if(all === #{false} || all === #{nil}) {
            if(!Object.hasOwnProperty.call(#{self}, k)) {
              continue;
            }
          }
          methods.push(k.substr(1));
        }
      }
      return methods;
    }
  end

  def Array(object, *args, &block)
    %x{
      if (object == null || object === nil) {
        return [];
      }
      else if (#{native?(object)}) {
        return #{Native::Array.new(object, *args, &block).to_a};
      }
      else if (#{object.respond_to? :to_ary}) {
        return #{object.to_ary};
      }
      else if (#{object.respond_to? :to_a}) {
        return #{object.to_a};
      }
      else {
        return [object];
      }
    }
  end

  # Opal does not support #caller, but we stub it as an empty array to not
  # break dependant libs
  def caller
    []
  end

  def class
    `#{self}._klass`
  end

  def define_singleton_method(name, &body)
    %x{
      if (body === nil) {
        throw new Error("no block given");
      }

      var jsid   = '$' + name;
      body._jsid = jsid;
      body._sup  = #{self}[jsid];
      body._s    = null;

      #{self}[jsid] = body;

      return #{self};
    }
  end

  def dup
    copy = self.class.allocate

    %x{
      for (var name in #{self}) {
        if (name.charAt(0) !== '$') {
          copy[name] = #{self}[name];
        }
      }
    }

    copy.initialize_copy self
    copy
  end

  def enum_for(method = :each, *args)
    Enumerator.new self, method, *args
  end

  def equal?(other)
    `#{self} === other`
  end

  def extend(*mods)
    %x{
      for (var i = 0, length = mods.length; i < length; i++) {
        #{ self.singleton_class.include `mods[i]` };
      }

      return #{self};
    }
  end

  def format(format, *args)
    %x{
      var idx = 0;
      return format.replace(/%(\\d+\\$)?([-+ 0]*)(\\d*|\\*(\\d+\\$)?)(?:\\.(\\d*|\\*(\\d+\\$)?))?([cspdiubBoxXfgeEG])|(%%)/g, function(str, idx_str, flags, width_str, w_idx_str, prec_str, p_idx_str, spec, escaped) {
        if (escaped) {
          return '%';
        }

        var width,
        prec,
        is_integer_spec = ("diubBoxX".indexOf(spec) != -1),
        is_float_spec = ("eEfgG".indexOf(spec) != -1),
        prefix = '',
        obj;

        if (width_str === undefined) {
          width = undefined;
        } else if (width_str.charAt(0) == '*') {
          var w_idx = idx++;
          if (w_idx_str) {
            w_idx = parseInt(w_idx_str, 10) - 1;
          }
          width = #{`args[w_idx]`.to_i};
        } else {
          width = parseInt(width_str, 10);
        }
        if (!prec_str) {
          prec = is_float_spec ? 6 : undefined;
        } else if (prec_str.charAt(0) == '*') {
          var p_idx = idx++;
          if (p_idx_str) {
            p_idx = parseInt(p_idx_str, 10) - 1;
          }
          prec = #{`args[p_idx]`.to_i};
        } else {
          prec = parseInt(prec_str, 10);
        }
        if (idx_str) {
          idx = parseInt(idx_str, 10) - 1;
        }
        switch (spec) {
        case 'c':
          obj = args[idx];
          if (obj._isString) {
            str = obj.charAt(0);
          } else {
            str = String.fromCharCode(#{`obj`.to_i});
          }
          break;
        case 's':
          str = #{`args[idx]`.to_s};
          if (prec !== undefined) {
            str = str.substr(0, prec);
          }
          break;
        case 'p':
          str = #{`args[idx]`.inspect};
          if (prec !== undefined) {
            str = str.substr(0, prec);
          }
          break;
        case 'd':
        case 'i':
        case 'u':
          str = #{`args[idx]`.to_i}.toString();
          break;
        case 'b':
        case 'B':
          str = #{`args[idx]`.to_i}.toString(2);
          break;
        case 'o':
          str = #{`args[idx]`.to_i}.toString(8);
          break;
        case 'x':
        case 'X':
          str = #{`args[idx]`.to_i}.toString(16);
          break;
        case 'e':
        case 'E':
          str = #{`args[idx]`.to_f}.toExponential(prec);
          break;
        case 'f':
          str = #{`args[idx]`.to_f}.toFixed(prec);
          break;
        case 'g':
        case 'G':
          str = #{`args[idx]`.to_f}.toPrecision(prec);
          break;
        }
        idx++;
        if (is_integer_spec || is_float_spec) {
          if (str.charAt(0) == '-') {
            prefix = '-';
            str = str.substr(1);
          } else {
            if (flags.indexOf('+') != -1) {
              prefix = '+';
            } else if (flags.indexOf(' ') != -1) {
              prefix = ' ';
            }
          }
        }
        if (is_integer_spec && prec !== undefined) {
          if (str.length < prec) {
            str = #{'0' * `prec - str.length`} + str;
          }
        }
        var total_len = prefix.length + str.length;
        if (width !== undefined && total_len < width) {
          if (flags.indexOf('-') != -1) {
            str = str + #{' ' * `width - total_len`};
          } else {
            var pad_char = ' ';
            if (flags.indexOf('0') != -1) {
              str = #{'0' * `width - total_len`} + str;
            } else {
              prefix = #{' ' * `width - total_len`} + prefix;
            }
          }
        }
        var result = prefix + str;
        if ('XEG'.indexOf(spec) != -1) {
          result = result.toUpperCase();
        }
        return result;
      });
    }
  end

  def hash
    `#{self}._id`
  end

  def initialize_copy(other)
  end

  def inspect
    to_s
  end

  def instance_of?(klass)
    `#{self}._klass === klass`
  end

  def instance_variable_defined?(name)
    `#{self}.hasOwnProperty(name.substr(1))`
  end

  def instance_variable_get(name)
    %x{
      var ivar = #{self}[name.substr(1)];

      return ivar == null ? nil : ivar;
    }
  end

  def instance_variable_set(name, value)
    `#{self}[name.substr(1)] = value`
  end

  def instance_variables
    %x{
      var result = [];

      for (var name in #{self}) {
        if (name.charAt(0) !== '$') {
          result.push('@' + name);
        }
      }

      return result;
    }
  end

  def Integer(str)
    `parseInt(str)`
  end

  def is_a?(klass)
    %x{
      var search = #{self}._klass;

      while (search) {
        if (search === klass) {
          return true;
        }

        search = search._super;
      }

      return false;
    }
  end

  alias kind_of? is_a?

  def lambda(&block)
    `block.is_lambda = true`

    block
  end

  def loop(&block)
    `while (true) {`
      yield
    `}`

    self
  end

  def nil?
    false
  end

  def object_id
    `#{self}._id || (#{self}._id = Opal.uid())`
  end

  def printf(*args)
    if args.length > 0
      fmt = args.shift
      print format(fmt, *args)
    end
    nil
  end

  alias private_methods methods

  def proc(&block)
    %x{
      if (block === nil) {
        #{ raise ArgumentError, 'no block given' };
      }
      block.is_lambda = false;
      return block;
    }
  end

  def puts(*strs)
    $stdout.puts(*strs)
  end

  def p(*args)
    args.each { |obj| $stdout.puts obj.inspect }

    args.length <= 1 ? args[0] : args
  end

  alias print puts

  def raise(exception = undefined, string = undefined)
    %x{
      if (exception == null && #$!) {
        exception = #$!;
      }
      else if (typeof(exception) === 'string') {
        exception = #{RuntimeError.new exception};
      }
      else if (!#{exception.is_a? Exception}) {
        exception = #{exception.new string};
      }

      throw exception;
    }
  end

  alias fail raise

  def rand(max = undefined)
    %x{
      if(!max) {
        return Math.random();
      } else {
        if (max._isRange) {
          var arr = max.$to_a();
          return arr[#{rand(`arr.length`)}];
        } else {
          return Math.floor(Math.random() * Math.abs(parseInt(max)));
        }
      }
    }
  end

  alias srand rand

  def respond_to?(name, include_all = false)
    %x{
      var body = #{self}['$' + name];
      return (!!body) && !body.rb_stub;
    }
  end

  alias send        __send__
  alias public_send __send__

  def singleton_class
    %x{
      if (#{self}._isClass) {
        if (#{self}.__meta__) {
          return #{self}.__meta__;
        }

        var meta = new $opal.Class._alloc;
        meta._klass = $opal.Class;
        #{self}.__meta__ = meta;
        // FIXME - is this right? (probably - methods defined on
        // class' singleton should also go to subclasses?)
        meta._proto = #{self}.constructor.prototype;
        meta._isSingleton = true;
        meta.__inc__ = [];
        meta._methods = [];

        meta._scope = #{self}._scope;

        return meta;
      }

      if (#{self}._isClass) {
        return #{self}._klass;
      }

      if (#{self}.__meta__) {
        return #{self}.__meta__;
      }

      else {
        var orig_class = #{self}._klass,
            class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

        var Singleton = function () {};
        var meta = Opal.boot(orig_class, Singleton);
        meta._name = class_id;

        meta._proto = #{self};
        #{self}.__meta__ = meta;
        meta._klass = orig_class._klass;
        meta._scope = orig_class._scope;
        meta.__parent = orig_class;

        return meta;
      }
    }
  end

  alias sprintf format

  def String(str)
    `String(str)`
  end

  def tap(&block)
    yield self
    self
  end

  def to_proc
    self
  end

  def to_s
    `return "#<" + #{self}._klass._name + ":" + #{self}._id + ">";`
  end

  alias to_str to_s

  def freeze
    @___frozen___ = true
    self
  end

  def frozen?
    @___frozen___ || false
  end

  def eval(str)
    raise NotImplementedError unless defined?(Opal::Parser)
    code = Opal::Parser.new.parse str
    `eval(#{code})`
  end

  def respond_to_missing? method_name
    false
  end
end
