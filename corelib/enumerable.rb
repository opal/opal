module Enumerable
  def all?(&block)
    %x{
      var result = true;

      if (block !== nil) {
        self.$each._p = function() {
          var value = $opal.$yieldX(block, arguments);

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
          var value = $opal.$yieldX(block, arguments);

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

      self.$each._p = function() {
        var value = $opal.$yieldX(block, arguments);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        result.push(value);
      };

      self.$each();

      return result;
    }
  end

  def count(object = undefined, &block)
    %x{
      var result = 0;

      if (object != null) {
        block = function() {
          return #{Opal.destructure(`arguments`) == `object`};
        };
      }
      else if (block === nil) {
        block = function() { return true; };
      }

      self.$each._p = function() {
        var value = $opal.$yieldX(block, arguments);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        if (#{Opal.truthy?(`value`)}) {
          result++;
        }
      }

      self.$each();

      return result;
    }
  end

  def detect(ifnone = undefined, &block)
    return enum_for :detect, ifnone unless block_given?

    %x{
      var result = undefined;

      self.$each._p = function() {
        var params = #{Opal.destructure(`arguments`)},
            value  = $opal.$yield1(block, params);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        if (#{Opal.truthy?(`value`)}) {
          result = params;
          return $breaker;
        }
      };

      self.$each();

      if (result === undefined && ifnone !== undefined) {
        if (typeof(ifnone) === 'function') {
          result = ifnone();
        }
        else {
          result = ifnone;
        }
      }

      return result === undefined ? nil : result;
    }
  end

  def drop(number)
    number = Opal.coerce_to number, Integer, :to_int

    if `number < 0`
      raise ArgumentError, "attempt to drop negative size"
    end

    %x{
      var result  = [],
          current = 0;

      self.$each._p = function() {
        if (number < current) {
          result.push(#{Opal.destructure(`arguments`)});
        }

        current++;
      };

      self.$each()

      return result;
    }
  end

  def drop_while(&block)
    return enum_for :drop_while unless block_given?

    %x{
      var result = [];

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = $opal.$yield1(block, param);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        if (#{Opal.truthy?(`value`)}) {
          return;
        }

        result.push(param);
      };

      self.$each();

      return result;
    }
  end

  def each_slice(n, &block)
    n = Opal.coerce_to n, Integer, :to_int

    return enum_for :each_slice, n unless block_given?

    %x{
      var result,
          slice = []

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)};

        slice.push(param);

        if (slice.length === n) {
          if (block(slice) === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          slice = [];
        }
      };

      self.$each();

      if (result !== undefined) {
        return result;
      }

      // our "last" group, if smaller than n then won't have been yielded
      if (slice.length > 0) {
        if (block(slice) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    nil
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block_given?

    %x{
      var result,
          index = 0;

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = block(param, index);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        index++;
      };

      self.$each();

      if (result !== undefined) {
        return result;
      }
    }

    nil
  end

  def each_with_object(object, &block)
    return enum_for :each_with_object, object unless block_given?

    %x{
      var result;

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = block(param, object);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }
      };

      self.$each();

      if (result !== undefined) {
        return result;
      }
    }

    object
  end

  def entries
    %x{
      var result = [];

      self.$each._p = function() {
        result.push(#{Opal.destructure(`arguments`)});
      };

      self.$each();

      return result;
    }
  end

  alias find detect

  def find_all(&block)
    return enum_for :find_all unless block_given?

    %x{
      var result = [];

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = $opal.$yield1(block, param);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        if (#{Opal.truthy?(`value`)}) {
          result.push(param);
        }
      };

      self.$each();

      return result;
    }
  end

  def find_index(object = undefined, &block)
    return enum_for :find_index if `object === undefined && block === nil`

    %x{
      var result = nil,
          index  = 0;

      if (object != null) {
        self.$each._p = function() {
          var param = #{Opal.destructure(`arguments`)};

          if (#{`param` == `object`}) {
            result = index;
            return $breaker;
          }

          index += 1;
        };
      }
      else if (block !== nil) {
        self.$each._p = function() {
          var value = $opal.$yieldX(block, arguments);

          if (value === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          if (#{Opal.truthy?(`value`)}) {
            result = index;
            return $breaker;
          }

          index += 1;
        };
      }

      self.$each();

      return result;
    }
  end

  def first(number = undefined)
    %x{
      if (number == null) {
        var result = nil;

        self.$each._p = function() {
          result = #{Opal.destructure(`arguments`)};
          return $breaker;
        };
      }
      else {
        var current = 0,
            result  = [],
            number  = #{Opal.coerce_to number, Integer, :to_int};

        self.$each._p = function() {
          if (number <= current) {
            return $breaker;
          }

          result.push(#{Opal.destructure(`arguments`)});

          current++;
        };
      }

      self.$each();

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

    %x{
      var result;

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = $opal.$yield1(block, param);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        #{hash[`value`] << `param`};
      }

      self.$each();

      if (result !== undefined) {
        return result;
      }
    }

    hash
  end

  def include?(obj)
    any? { |v| v == obj }
  end

  def inject(object = undefined, &block)
    %x{
      var result = object;

      self.$each._p = function() {
        var value = #{Opal.destructure(`arguments`)};

        if (result === undefined) {
          result = value;
          return;
        }

        value = $opal.$yieldX(block, [result, value]);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        result = value;
      };

      self.$each();

      return result;
    }
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
      var result = true;

      if (block !== nil) {
        self.$each._p = function() {
          var value = $opal.$yieldX(block, arguments);

          if (value === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          if (#{Opal.truthy?(`value`)}) {
            result = false;
            return $breaker;
          }
        }
      }
      else {
        self.$each._p = function() {
          var value = #{Opal.destructure(`arguments`)};

          if (#{Opal.truthy?(`value`)}) {
            result = false;
            return $breaker;
          }
        };
      }

      self.$each();

      return result;
    }
  end

  def one?(&block)
    %x{
      var result = false;

      if (block !== nil) {
        self.$each._p = function() {
          var value = $opal.$yieldX(block, arguments);

          if (value === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          if (#{Opal.truthy?(`value`)}) {
            if (result === true) {
              result = false;
              return $breaker;
            }

            result = true;
          }
        }
      }
      else {
        self.$each._p = function() {
          var value = #{Opal.destructure(`arguments`)};

          if (#{Opal.truthy?(`value`)}) {
            if (result === true) {
              result = false;
              return $breaker;
            }

            result = true;
          }
        }
      }

      self.$each();

      return result;
    }
  end

  def sort_by(&block)
    return enum_for :sort_by unless block_given?

    map {
      arg = Opal.destructure(`arguments`)

      [block.call(arg), arg]
    }.sort.map { |arg| `arg[1]` }
  end

  alias select find_all

  alias reduce inject

  def take(num)
    first(num)
  end

  def take_while(&block)
    return enum_for :take_while unless block

    %x{
      var result = [];

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = $opal.$yield1(block, param);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        if (#{Opal.falsy?(`value`)}) {
          return $breaker;
        }

        result.push(param);
      };

      self.$each();

      return result;
    }
  end

  alias to_a entries
end

