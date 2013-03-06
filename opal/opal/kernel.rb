module Kernel
  # bridged from BasicObject
  alias :initialize :initialize
  alias :== :==
  alias :__send__ :__send__
  alias :eql? :eql?
  alias :equal? :equal?
  alias :instance_eval :instance_eval
  alias :instance_exec :instance_exec

  def method_missing(symbol, *args, &block)
    raise NoMethodError, "undefined method `#{symbol}' for #{inspect}"
  end

  def =~(obj)
    false
  end

  def ===(other)
    `#{self} == other`
  end

  def as_json
    nil
  end

  def method(name)
    %x{
      var recv = #{self},
          meth = recv['$' + name],
          func = function() {
            return meth.apply(recv, __slice.call(arguments, 0));
          };

      if (!meth) {
        #{ raise NameError };
      }

      func._klass = #{Method};
      return func;
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

  def Array(object)
    %x{
      if (object.$to_ary) {
        return #{object.to_ary};
      }
      else if (object.$to_a) {
        return #{object.to_a};
      }

      return [object];
    }
  end

  def class
    `#{self}._klass`
  end

  def define_singleton_method(name, &body)
    %x{
      if (body === nil) {
        no_block_given();
      }

      var jsid   = '$' + name;
      body._jsid = jsid;
      body._sup  = #{self}[jsid];
      body._s    = null;

      #{self}[jsid] = body;

      return #{self};
    }
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
        if (prec_str === undefined) {
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

  def inspect
    to_s
  end

  def instance_of?(klass)
    `#{self}._klass === klass`
  end

  def instance_variable_defined?(name)
    `__hasOwn.call(#{self}, name.substr(1))`
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
        result.push(name);
      }

      return result;
    }
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

  def proc(&block)
    %x{
      if (block === nil) {
        no_block_given();
      }
      block.is_lambda = false;
      return block;
    }
  end

  def puts(*strs)
    %x{
      for (var i = 0; i < strs.length; i++) {
        if(strs[i] instanceof Array) {
          #{ puts *`strs[i]` }
        } else {
          __opal.puts(#{ `strs[i]`.to_s });
        }
      }
    }
    nil
  end

  def p(*args)
    `console.log.apply(console, args);`
    args.length <= 1 ? args[0] : args
  end

  alias print puts

  def raise(exception = "", string = undefined)
    %x{
      if (typeof(exception) === 'string') {
        exception = #{RuntimeError.new exception};
      }
      else if (!#{exception.is_a? Exception}) {
        exception = #{exception.new string};
      }

      throw exception;
    }
  end

  def rand(max = undefined)
    `max == null ? Math.random() : Math.floor(Math.random() * max)`
  end

  def respond_to?(name)
    `!!#{self}['$' + name]`
  end

  alias send __send__

  def singleton_class
    %x{
      if (#{self}._isClass) {
        if (#{self}._singleton) {
          return #{self}._singleton;
        }

        var meta = new __opal.Class;
        meta._klass = __opal.Class;
        #{self}._singleton = meta;
        meta.prototype = #{self};
        meta._isSingleton = true;

        return meta;
      }

      if (!#{self}._isObject) {
        return #{self}._klass;
      }

      if (#{self}._singleton) {
        return #{self}._singleton;
      }

      else {
        var orig_class = #{self}._klass,
            class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

        function Singleton() {};
        var meta = Opal.boot(orig_class, Singleton);
        meta._name = class_id;

        meta.prototype = #{self};
        #{self}._singleton = meta;
        meta._klass = orig_class._klass;

        return meta;
      }
    }
  end

  alias sprintf format

  def tap(&block)
    yield self
    self
  end

  def to_json
    to_s.to_json
  end

  def to_proc
    self
  end

  def to_s
    `return "#<" + #{self}._klass._name + ":" + #{self}._id + ">";`
  end
end
