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

  def chunk(state = undefined, &block)
    raise NotImplementedError
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

  def collect_concat(&block)
    return enum_for :collect_concat unless block_given?
    map { |item| yield item }.flatten(1)
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

  def cycle(n = nil, &block)
    return enum_for :cycle, n unless block

    unless n.nil?
      n = Opal.coerce_to! n, Integer, :to_int

      return if `n <= 0`
    end

    %x{
      var result,
          all  = [];

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = $opal.$yield1(block, param);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        all.push(param);
      }

      self.$each();

      if (result !== undefined) {
        return result;
      }

      if (all.length === 0) {
        return nil;
      }
    }

    if n.nil?
      %x{
        while (true) {
          for (var i = 0, length = all.length; i < length; i++) {
            var value = $opal.$yield1(block, all[i]);

            if (value === $breaker) {
              return $breaker.$v;
            }
          }
        }
      }
    else
      %x{
        while (n > 1) {
          for (var i = 0, length = all.length; i < length; i++) {
            var value = $opal.$yield1(block, all[i]);

            if (value === $breaker) {
              return $breaker.$v;
            }
          }

          n--;
        }
      }
    end
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
        if (number <= current) {
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
      var result   = [],
          dropping = true;

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)};

        if (dropping) {
          var value = $opal.$yield1(block, param);

          if (value === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          if (#{Opal.falsy?(`value`)}) {
            dropping = false;
            result.push(param);
          }
        }
        else {
          result.push(param);
        }
      };

      self.$each();

      return result;
    }
  end

  def each_cons(n, &block)
    raise NotImplementedError
  end

  def each_entry(&block)
    raise NotImplementedError
  end

  def each_slice(n, &block)
    n = Opal.coerce_to n, Integer, :to_int

    if `n <= 0`
      raise ArgumentError, 'invalid slice size'
    end

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

  def each_with_index(*args, &block)
    return enum_for :each_with_index, *args unless block_given?

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

      self.$each.apply(self, args);

      if (result !== undefined) {
        return result;
      }
    }

    self
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

  def entries(*args)
    %x{
      var result = [];

      self.$each._p = function() {
        result.push(#{Opal.destructure(`arguments`)});
      };

      self.$each.apply(self, args);

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
    if `number === undefined`
      result = nil

      %x{
        self.$each._p = function() {
          result = #{Opal.destructure(`arguments`)};

          return $breaker;
        };

        self.$each();
      }
    else
      result = []
      number = Opal.coerce_to number, Integer, :to_int

      if `number < 0`
        raise ArgumentError, 'attempt to take negative size'
      end

      if `number == 0`
        return []
      end

      %x{
        var current = 0,
            number  = #{Opal.coerce_to number, Integer, :to_int};

        self.$each._p = function() {
          result.push(#{Opal.destructure(`arguments`)});

          if (number <= ++current) {
            return $breaker;
          }
        };

        self.$each();
      }
    end

    result
  end

  alias flat_map collect_concat

  def grep(pattern, &block)
    %x{
      var result = [];

      if (block !== nil) {
        self.$each._p = function() {
          var param = #{Opal.destructure(`arguments`)},
              value = #{pattern === `param`};

          if (#{Opal.truthy?(`value`)}) {
            value = $opal.$yield1(block, param);

            if (value === $breaker) {
              result = $breaker.$v;
              return $breaker;
            }

            result.push(value);
          }
        };
      }
      else {
        self.$each._p = function() {
          var param = #{Opal.destructure(`arguments`)},
              value = #{pattern === `param`};

          if (#{Opal.truthy?(`value`)}) {
            result.push(param);
          }
        };
      }

      self.$each();

      return result;
    }
  end

  def group_by(&block)
    return enum_for :group_by unless block_given?

    hash = Hash.new

    %x{
      var result;

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = $opal.$yield1(block, param);

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        #{(hash[`value`] ||= []) << `param`};
      }

      self.$each();

      if (result !== undefined) {
        return result;
      }
    }

    hash
  end

  def include?(obj)
    %x{
      var result = false;

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)};

        if (#{`param` == obj}) {
          result = true;
          return $breaker;
        }
      }

      self.$each();

      return result;
    }
  end

  def inject(object = undefined, sym = undefined, &block)
    %x{
      var result = object;

      if (block !== nil && sym === undefined) {
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
      }
      else {
        if (sym === undefined) {
          if (!#{Symbol === object}) {
            #{raise TypeError, "#{object.inspect} is not a Symbol"};
          }

          sym    = object;
          result = undefined;
        }

        self.$each._p = function() {
          var value = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = value;
            return;
          }

          result = #{`result`.__send__ sym, `value`};
        };
      }

      self.$each();

      return result;
    }
  end

  def lazy
    Enumerator::Lazy.new(self, enumerator_size) {|enum, *args|
      enum.yield(*args)
    }
  end

  def enumerator_size
    respond_to?(:size) ? size : nil
  end
  private :enumerator_size

  alias map collect

  def max(&block)
    %x{
      var result;

      if (block !== nil) {
        self.$each._p = function() {
          var param = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = param;
            return;
          }

          var value = block(param, result);

          if (value === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          if (value === nil) {
            #{raise ArgumentError, "comparison failed"};
          }

          if (value > 0) {
            result = param;
          }
        };
      }
      else {
        self.$each._p = function() {
          var param = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = param;
            return;
          }

          if (#{Opal.compare(`param`, `result`)} > 0) {
            result = param;
          }
        };
      }

      self.$each();

      return result === undefined ? nil : result;
    }
  end

  def max_by(&block)
    return enum_for :max_by unless block

    %x{
      var result,
          by;

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = $opal.$yield1(block, param);

        if (result === undefined) {
          result = param;
          by     = value;
          return;
        }

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        if (#{`value` <=> `by`} > 0) {
          result = param
          by     = value;
        }
      };

      self.$each();

      return result === undefined ? nil : result;
    }
  end

  alias member? include?

  def min(&block)
    %x{
      var result;

      if (block !== nil) {
        self.$each._p = function() {
          var param = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = param;
            return;
          }

          var value = block(param, result);

          if (value === $breaker) {
            result = $breaker.$v;
            return $breaker;
          }

          if (value === nil) {
            #{raise ArgumentError, "comparison failed"};
          }

          if (value < 0) {
            result = param;
          }
        };
      }
      else {
        self.$each._p = function() {
          var param = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = param;
            return;
          }

          if (#{Opal.compare(`param`, `result`)} < 0) {
            result = param;
          }
        };
      }

      self.$each();

      return result === undefined ? nil : result;
    }
  end

  def min_by(&block)
    return enum_for :min_by unless block

    %x{
      var result,
          by;

      self.$each._p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = $opal.$yield1(block, param);

        if (result === undefined) {
          result = param;
          by     = value;
          return;
        }

        if (value === $breaker) {
          result = $breaker.$v;
          return $breaker;
        }

        if (#{`value` <=> `by`} < 0) {
          result = param
          by     = value;
        }
      };

      self.$each();

      return result === undefined ? nil : result;
    }
  end

  def minmax(&block)
    raise NotImplementedError
  end

  def minmax_by(&block)
    raise NotImplementedError
  end

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

  def partition(&block)
    raise NotImplementedError
  end

  alias reduce inject

  def reject(&block)
    return enum_for :reject unless block_given?

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
          result.push(param);
        }
      };

      self.$each();

      return result;
    }
  end
  def reverse_each(&block)
    raise NotImplementedError
  end

  alias select find_all

  def slice_before(pattern = undefined, &block)
    if `pattern === undefined && block === nil || arguments.length > 1`
      raise ArgumentError, "wrong number of arguments (#{`arguments.length`} for 1)"
    end

    Enumerator.new {|e|
      %x{
        var slice = [];

        if (block !== nil) {
          if (pattern === undefined) {
            self.$each._p = function() {
              var param = #{Opal.destructure(`arguments`)},
                  value = $opal.$yield1(block, param);

              if (#{Opal.truthy?(`value`)} && slice.length > 0) {
                #{e << `slice`};
                slice = [];
              }

              slice.push(param);
            };
          }
          else {
            self.$each._p = function() {
              var param = #{Opal.destructure(`arguments`)},
                  value = block(param, #{pattern.dup});

              if (#{Opal.truthy?(`value`)} && slice.length > 0) {
                #{e << `slice`};
                slice = [];
              }

              slice.push(param);
            };
          }
        }
        else {
          self.$each._p = function() {
            var param = #{Opal.destructure(`arguments`)},
                value = #{pattern === `param`};

            if (#{Opal.truthy?(`value`)} && slice.length > 0) {
              #{e << `slice`};
              slice = [];
            }

            slice.push(param);
          };
        }

        self.$each();

        if (slice.length > 0) {
          #{e << `slice`};
        }
      }
    }
  end

  def sort(&block)
    raise NotImplementedError
  end

  def sort_by(&block)
    return enum_for :sort_by unless block_given?

    map {
      arg = Opal.destructure(`arguments`)

      [block.call(arg), arg]
    }.sort { |a, b| a[0] <=> b[0] }.map { |arg| `arg[1]` }
  end

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

  def zip(*lists, &block)
    raise NotImplementedError
  end
end

