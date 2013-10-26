module Enumerable
  def all?(&block)
    %x{
      var result = true;

      if (block !== nil) {
        self.$each._p = function() {
          var value = Opal.$yieldX(block, arguments);

          if (value === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          if (#{Opal.falsy?(`value`)}) {
            result = false;
            return $breaker;
          }
        }
      }
      else {
        self.$each._p = function(obj) {
          if (arguments.length == 1 && #{Opal.falsy?(`obj`)}) {
            result = false;
            return $breaker;
          }
        }
      }

      self.$each();

      return result;
    }
  end

  def any?(&block)
    %x{
      var result = false;

      if (block !== nil) {
        self.$each._p = function() {
          var value = Opal.$yieldX(block, arguments);

          if (value === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          if (#{Opal.truthy?(`value`)}) {
            result = true;
            return $breaker;
          }
        };
      }
      else {
        self.$each._p = function(obj) {
          if (arguments.length != 1 || #{Opal.truthy?(`obj`)}) {
            result = true;
            return $breaker;
          }
        }
      }

      self.$each();

      return result;
    }
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [];

      var proc = function() {
        var value, args = $slice.call(arguments);

        if (block.length > 1 && args.length === 1 && args[0]._isArray) {
          args = args[0]
        }

        if ((value = block.apply(null, args)) === $breaker) {
          return $breaker.$v;
        }

        result.push(value);
      };

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def reduce(object = undefined, &block)
    %x{
      var result = #{object} == undefined ? 0 : #{object};

      var proc = function() {
        var obj = $slice.call(arguments), value;

        if ((value = block.apply(nil, [result].concat(obj))) === $breaker) {
          result = $breaker.$v;
          $breaker.$v = nil;

          return $breaker;
        }

        result = value;
      };

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def count(object = undefined, &block)
    %x{
      var result = 0;

      if (object != null) {
        block = function() {
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          return #{ `param` == `object` };
        };
      }
      else if (block === nil) {
        block = function() { return true; };
      }

      var proc = function() {
        var value, param = $slice.call(arguments);

        if ((value = block.apply(null, param)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result++;
        }
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def detect(ifnone = undefined, &block)
    %x{
      var result = nil;

      #{self}.$each._p = function() {
        var value;
        var param = arguments.length == 1 ?
          arguments[0] : $slice.call(arguments);

        if ((value = block(param)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result       = param;
          $breaker.$v = nil;

          return $breaker;
        }
      };

      #{self}.$each();

      if (result !== nil) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return #{ifnone.call};
      }

      return ifnone == null ? nil : ifnone;
    }
  end

  def drop(number)
    %x{
      var result  = [],
          current = 0;

      if (number < 0) {
        #{raise ArgumentError};
      }

      #{self}.$each._p = function(e) {
        if (number < current) {
          result.push(e);
        }

        current++;
      };

      #{self}.$each()

      return result;
    }
  end

  def drop_while(&block)
    return enum_for :drop_while unless block_given?

    %x{
      var result = [];

      #{self}.$each._p = function() {
        var value;
        var param = arguments.length == 1 ?
          arguments[0] : $slice.call(arguments);

        if ((value = block(param)) === $breaker) {
          return $breaker;
        }

        if (value === false || value === nil) {
          result.push(param);
          return value;
        }

        return $breaker;
      };

      #{self}.$each();

      return result;
    }
  end

  def each_slice(n, &block)
    return enum_for :each_slice, n unless block_given?

    %x{
      var all = [];

      #{self}.$each._p = function() {
        var param = arguments.length == 1 ?
          arguments[0] : $slice.call(arguments);

        all.push(param);

        if (all.length == n) {
          block(all.slice(0));
          all = [];
        }
      };

      #{self}.$each();

      // our "last" group, if smaller than n then wont have been yielded
      if (all.length > 0) {
        block(all.slice(0));
      }

      return nil;
    }
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block_given?

    %x{
      var index = 0;

      #{self}.$each._p = function() {
        var value;
        var param = arguments.length == 1 ?
          arguments[0] : $slice.call(arguments);

        if ((value = block(param, index)) === $breaker) {
          return $breaker.$v;
        }

        index++;
      };
      #{self}.$each();

      return nil;
    }
  end

  def each_with_object(object = undefined, &block)
    return enum_for :each_with_object, object unless block_given?

    %x{
      #{self}.$each._p = function() {
        var value;
        var param = arguments.length == 1 ?
          arguments[0] : $slice.call(arguments);

        if ((value = block(param, object)) === $breaker) {
          return $breaker.$v;
        }
      };

      #{self}.$each();

      return object;
    }
  end

  def entries
    %x{
      var result = [];

      #{self}.$each._p = function() {
        if (arguments.length == 1) {
          result.push(arguments[0]);
        }
        else {
          result.push($slice.call(arguments));
        }
      };

      #{self}.$each();

      return result;
    }
  end

  alias find detect

  def find_all(&block)
    %x{
      var result = [];

      #{self}.$each._p = function() {
        var value;
        var param = arguments.length == 1 ?
          arguments[0] : $slice.call(arguments);

        if ((value = block(param)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(param);
        }
      };

      #{self}.$each();

      return result;
    }
  end

  def find_index(object = undefined, &block)
    %x{
      var proc, result = nil, index = 0;

      if (object != null) {
        proc = function() {
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          if (#{ `param` == `object` }) {
            result = index;
            return $breaker;
          }

          index += 1;
        };
      }
      else if (block !== nil) {
        proc = function() {
          var value;
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          if ((value = block(param)) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== nil) {
            result       = index;
            $breaker.$v = index;

            return $breaker;
          }

          index += 1;
        };
      }
      else {
        return #{enum_for :find_index};
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def first(number = undefined)
    %x{
      var result  = [],
          current = 0,
          proc;

      if (number == null) {
        result = nil;
        proc   = function() {
          result = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          return $breaker;
        };
      }
      else {
        proc = function() {
          if (number <= current) {
            return $breaker;
          }

          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          result.push(param);

          current++;
        };
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def grep(pattern, &block)
    %x{
      var result = [],
          proc;

      if (block !== nil) {
        proc = function() {
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          var value = #{pattern === `param`};

          if (value !== false && value !== nil) {
            if ((value = block(param)) === $breaker) {
              return $breaker.$v;
            }

            result.push(value);
          }
        };
      }
      else {
        proc = function() {
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          var value = #{pattern === `param`};

          if (value !== false && value !== nil) {
            result.push(param);
          }
        };
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def group_by(&block)
    return enum_for :group_by unless block_given?

    hash = Hash.new { |h, k| h[k] = [] }

    each do |el|
      hash[block.call(el)] << el
    end

    hash
  end

  def include?(obj)
    any? { |v| v == obj }
  end

  alias map collect

  def max(&block)
    %x{
      var proc, result;
      var arg_error = false;

      if (block !== nil) {
        proc = function() {
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          if (result == undefined) {
            result = param;
          }
          else if ((value = block(param, result)) === $breaker) {
            result = $breaker.$v;

            return $breaker;
          }
          else {
            if (value > 0) {
              result = param;
            }

            $breaker.$v = nil;
          }
        }
      }
      else {
        proc = function() {
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          var modules = param.$class().__inc__;

          if (modules == undefined || modules.length == 0 || modules.indexOf(Opal.Comparable) == -1) {
            arg_error = true;

            return $breaker;
          }

          if (result == undefined || #{`param` > `result`}) {
            result = param;
          }
        }
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      if (arg_error) {
        #{raise ArgumentError, "Array#max"};
      }

      return (result == undefined ? nil : result);
    }
  end

  def min(&block)
    %x{
      var proc,
          result,
          arg_error = false;

      if (block !== nil) {
        proc = function() {
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          if (result == undefined) {
            result = param;
          }
          else if ((value = block(param, result)) === $breaker) {
            result = $breaker.$v;

            return $breaker;
          }
          else {
            if (value < 0) {
              result = param;
            }

            $breaker.$v = nil;
          }
        }
      }
      else {
        proc = function(obj) {
          var param = arguments.length == 1 ?
            arguments[0] : $slice.call(arguments);

          var modules = param.$class().__inc__;

          if (modules == undefined || modules.length == 0 || modules.indexOf(Opal.Comparable) == -1) {
            arg_error = true;

            return $breaker;
          }

          if (result == undefined || #{`param` < `result`}) {
            result = param;
          }
        }
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      if (arg_error) {
        #{raise ArgumentError, "Array#min"};
      }

      return result == undefined ? nil : result;
    }
  end

  alias member? include?

  def none?(&block)
    %x{
      var result = true,
          proc;

      if (block !== nil) {
        proc = function(obj) {
          var value,
              args = $slice.call(arguments);

          if ((value = block.apply(#{self}, args)) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== nil) {
            result       = false;
            $breaker.$v = nil;

            return $breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if (arguments.length == 1 && (obj !== false && obj !== nil)) {
            result       = false;
            $breaker.$v = nil;

            return $breaker;
          }
          else {
            for (var i = 0, length = arguments.length; i < length; i++) {
              if (arguments[i] !== false && arguments[i] !== nil) {
                result       = false;
                $breaker.$v = nil;

                return $breaker;
              }
            }
          }
        };
      }

      #{self}.$each._p = proc;
      #{self}.$each();

      return result;
    }
  end

  def sort_by(&block)
    return enum_for :sort_by unless block_given?

    map { |*f|
      # FIXME: this should probably belongs to somewhere more
      f = `#{f}.length === 1 ? #{f}[0] : #{f}`
      `[#{block.call(f)}, #{f}]`
    }.sort.map { |f| `#{f}[1]` }
  end

  alias select find_all

  def take(num)
    first num
  end

  alias to_a entries

  alias inject reduce
end

