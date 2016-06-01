module Enumerable
  def all?(&block)
    if block_given?

      each do |*value|
        unless yield(*value)
          return false
        end
      end

    else

      each do |*value|
        unless Opal.destructure(value)
          return false
        end
      end

    end

    true
  end

  def any?(&block)
    if block_given?

      each do |*value|
        if yield(*value)
          return true
        end
      end

    else

      each do |*value|
        if Opal.destructure(value)
          return true
        end
      end

    end

    false
  end

  def chunk(state = undefined, &original_block)
    Kernel.raise ArgumentError, "no block given" unless original_block

    ::Enumerator.new do |yielder|
      %x{
        var block, previous = nil, accumulate = [];

        if (state == undefined || state === nil) {
          block = original_block;
        } else {
          block = #{Proc.new { |val| original_block.yield(val, state.dup)}}
        }

        function releaseAccumulate() {
          if (accumulate.length > 0) {
            #{yielder.yield(`previous`, `accumulate`)}
          }
        }

        self.$each.$$p = function(value) {
          var key = Opal.yield1(block, value);

          if (key === nil) {
            releaseAccumulate();
            accumulate = [];
            previous = nil;
          } else {
            if (previous === nil || previous === key) {
              accumulate.push(value);
            } else {
              releaseAccumulate();
              accumulate = [value];
            }

            previous = key;
          }
        }

        self.$each();

        releaseAccumulate();
      }
    end
  end

  def collect(&block)
    return enum_for(:collect){self.enumerator_size} unless block_given?

    %x{
      var result = [];

      self.$each.$$p = function() {
        var value = Opal.yieldX(block, arguments);

        result.push(value);
      };

      self.$each();

      return result;
    }
  end

  def collect_concat(&block)
    return enum_for(:collect_concat){self.enumerator_size} unless block_given?
    map { |item| yield item }.flatten(1)
  end

  def count(object = undefined, &block)
    result = 0

    if `object != null`
      block = proc do |*args|
        `Opal.destructure(args)` == object
      end
    elsif block.nil?
      block = proc { true }
    end

    each do |*args|
      `result++` if block.call(*args)
    end

    result
  end

  def cycle(n = nil, &block)
    return enum_for(:cycle, n) {
      if n == nil
        respond_to?(:size) ? Float::INFINITY : nil
      else
        n = Opal.coerce_to!(n, Integer, :to_int)
        n > 0 ? self.enumerator_size * n : 0
      end
    } unless block_given?

    unless n.nil?
      n = Opal.coerce_to! n, Integer, :to_int

      return if `n <= 0`
    end

    %x{
      var result,
          all = [], i, length, value;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        all.push(param);
      }

      self.$each();

      if (result !== undefined) {
        return result;
      }

      if (all.length === 0) {
        return nil;
      }

      if (n === nil) {
        while (true) {
          for (i = 0, length = all.length; i < length; i++) {
            value = Opal.yield1(block, all[i]);
          }
        }
      }
      else {
        while (n > 1) {
          for (i = 0, length = all.length; i < length; i++) {
            value = Opal.yield1(block, all[i]);
          }

          n--;
        }
      }
    }
  end

  def detect(ifnone = undefined, &block)
    return enum_for :detect, ifnone unless block_given?

    each do |*args|
      value = Opal.destructure(args)
      if yield(value)
        return value
      end
    end

    %x{
      if (ifnone !== undefined) {
        if (typeof(ifnone) === 'function') {
          return ifnone();
        } else {
          return ifnone;
        }
      }
    }

    nil
  end

  def drop(number)
    number = Opal.coerce_to number, Integer, :to_int

    if `number < 0`
      raise ArgumentError, "attempt to drop negative size"
    end

    %x{
      var result  = [],
          current = 0;

      self.$each.$$p = function() {
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

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)};

        if (dropping) {
          var value = Opal.yield1(block, param);

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
    if `arguments.length != 1`
      raise ArgumentError, "wrong number of arguments (#{`arguments.length`} for 1)"
    end

    n = Opal.try_convert n, Integer, :to_int

    if `n <= 0`
      raise ArgumentError, 'invalid size'
    end

    unless block_given?
      return enum_for(:each_cons, n) {
        enum_size = self.enumerator_size
        if enum_size.nil?
          nil
        elsif enum_size == 0 || enum_size < n
          0
        else
          enum_size - n + 1
        end
      }
    end

    %x{
      var buffer = [], result = nil;

      self.$each.$$p = function() {
        var element = #{Opal.destructure(`arguments`)};
        buffer.push(element);
        if (buffer.length > n) {
          buffer.shift();
        }
        if (buffer.length == n) {
          Opal.yield1(block, buffer.slice(0, n));
        }
      }

      self.$each();

      return result;
    }
  end

  def each_entry(*data, &block)
    unless block_given?
      return to_enum(:each_entry, *data) { enumerator_size }
    end

    %x{
      self.$each.$$p = function() {
        var item = #{Opal.destructure(`arguments`)};

        Opal.yield1(block, item);
      }

      self.$each.apply(self, data);

      return self;
    }
  end

  def each_slice(n, &block)
    n = Opal.coerce_to n, Integer, :to_int

    if `n <= 0`
      raise ArgumentError, 'invalid slice size'
    end

    return enum_for(:each_slice, n){respond_to?(:size) ? (size / n).ceil : nil} unless block_given?

    %x{
      var result,
          slice = []

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)};

        slice.push(param);

        if (slice.length === n) {
          Opal.yield1(block, slice);
          slice = [];
        }
      };

      self.$each();

      if (result !== undefined) {
        return result;
      }

      // our "last" group, if smaller than n then won't have been yielded
      if (slice.length > 0) {
        Opal.yield1(block, slice);
      }
    }

    nil
  end

  def each_with_index(*args, &block)
    return enum_for(:each_with_index, *args){self.enumerator_size} unless block_given?

    %x{
      var result,
          index = 0;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)};

        block(param, index);

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
    return enum_for(:each_with_object, object){self.enumerator_size} unless block_given?

    %x{
      var result;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)};

        block(param, object);
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

      self.$each.$$p = function() {
        result.push(#{Opal.destructure(`arguments`)});
      };

      self.$each.apply(self, args);

      return result;
    }
  end

  alias find detect

  def find_all(&block)
    return enum_for(:find_all){self.enumerator_size} unless block_given?

    %x{
      var result = [];

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

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

    index = 0

    if `object != null`
      each do |*value|
        if Opal.destructure(value) == object
          return index
        end

        `index += 1`
      end
    else
      each do |*value|
        if yield(*value)
          return index
        end

        `index += 1`
      end
    end

    nil
  end

  def first(number = undefined)
    if `number === undefined`
      each do |value|
        return value
      end
    else
      result = []
      number = Opal.coerce_to number, Integer, :to_int

      if `number < 0`
        raise ArgumentError, 'attempt to take negative size'
      end

      if `number == 0`
        return []
      end

      current = 0

      each do |*args|
        `result.push(#{Opal.destructure(args)})`

        if `number <= ++current`
          return result
        end
      end

      result
    end
  end

  alias flat_map collect_concat

  def grep(pattern, &block)
    %x{
      var result = [];

      if (block !== nil) {
        self.$each.$$p = function() {
          var param = #{Opal.destructure(`arguments`)},
              value = #{pattern === `param`};

          if (#{Opal.truthy?(`value`)}) {
            value = Opal.yield1(block, param);

            result.push(value);
          }
        };
      }
      else {
        self.$each.$$p = function() {
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
    return enum_for(:group_by){self.enumerator_size} unless block_given?

    hash = Hash.new

    %x{
      var result;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

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
    each do |*args|
      if Opal.destructure(args) == obj
        return true
      end
    end

    false
  end

  def inject(object = undefined, sym = undefined, &block)
    %x{
      var result = object;

      if (block !== nil && sym === undefined) {
        self.$each.$$p = function() {
          var value = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = value;
            return;
          }

          value = Opal.yieldX(block, [result, value]);

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

        self.$each.$$p = function() {
          var value = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = value;
            return;
          }

          result = #{`result`.__send__ sym, `value`};
        };
      }

      self.$each();

      return result == undefined ? nil : result;
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

  alias map collect

  def max(n = undefined, &block)
    %x{
      if (n === undefined || n === nil) {
        var result, value;

        self.$each.$$p = function() {
          var item = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = item;
            return;
          }

          if (block !== nil) {
            value = Opal.yieldX(block, [item, result]);
          } else {
            value = #{`item` <=> `result`};
          }

          if (value === nil) {
            #{raise ArgumentError, "comparison failed"};
          }

          if (value > 0) {
            result = item;
          }
        }

        self.$each();

        if (result === undefined) {
          return nil;
        } else {
          return result;
        }
      }
    }

    n = Opal.coerce_to(n, Integer, :to_int)

    sort(&block).reverse.first(n)
  end

  def max_by(&block)
    return enum_for(:max_by){self.enumerator_size} unless block

    %x{
      var result,
          by;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        if (result === undefined) {
          result = param;
          by     = value;
          return;
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
        self.$each.$$p = function() {
          var param = #{Opal.destructure(`arguments`)};

          if (result === undefined) {
            result = param;
            return;
          }

          var value = block(param, result);

          if (value === nil) {
            #{raise ArgumentError, "comparison failed"};
          }

          if (value < 0) {
            result = param;
          }
        };
      }
      else {
        self.$each.$$p = function() {
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
    return enum_for(:min_by){self.enumerator_size} unless block

    %x{
      var result,
          by;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        if (result === undefined) {
          result = param;
          by     = value;
          return;
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
    block ||= proc { |a,b| a <=> b }

    %x{
      var min = nil, max = nil, first_time = true;

      self.$each.$$p = function() {
        var element = #{Opal.destructure(`arguments`)};
        if (first_time) {
          min = max = element;
          first_time = false;
        } else {
          var min_cmp = #{block.call(`min`, `element`)};

          if (min_cmp === nil) {
            #{raise ArgumentError, 'comparison failed'}
          } else if (min_cmp > 0) {
            min = element;
          }

          var max_cmp = #{block.call(`max`, `element`)};

          if (max_cmp === nil) {
            #{raise ArgumentError, 'comparison failed'}
          } else if (max_cmp < 0) {
            max = element;
          }
        }
      }

      self.$each();

      return [min, max];
    }
  end

  def minmax_by(&block)
    raise NotImplementedError
  end

  def none?(&block)
    if block_given?

      each do |*value|
        if yield(*value)
          return false
        end
      end

    else

      each do |*value|
        if Opal.destructure(value)
          return false
        end
      end

    end

    true
  end

  def one?(&block)
    count = 0

    if block_given?

      each do |*value|
        if yield(*value)
          count += 1

          return false if count > 1
        end
      end

    else

      each do |*value|
        if Opal.destructure(value)
          count += 1

          return false if count > 1
        end
      end

    end

    count == 1
  end

  def partition(&block)
    return enum_for(:partition){self.enumerator_size} unless block_given?

    %x{
      var truthy = [], falsy = [], result;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        if (#{Opal.truthy?(`value`)}) {
          truthy.push(param);
        }
        else {
          falsy.push(param);
        }
      };

      self.$each();

      return [truthy, falsy];
    }
  end

  alias reduce inject

  def reject(&block)
    return enum_for(:reject){self.enumerator_size} unless block_given?

    %x{
      var result = [];

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        if (#{Opal.falsy?(`value`)}) {
          result.push(param);
        }
      };

      self.$each();

      return result;
    }
  end

  def reverse_each(&block)
    return enum_for(:reverse_each){self.enumerator_size} unless block_given?

    %x{
      var result = [];

      self.$each.$$p = function() {
        result.push(arguments);
      };

      self.$each();

      for (var i = result.length - 1; i >= 0; i--) {
        Opal.yieldX(block, result[i]);
      }

      return result;
    }
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
            self.$each.$$p = function() {
              var param = #{Opal.destructure(`arguments`)},
                  value = Opal.yield1(block, param);

              if (#{Opal.truthy?(`value`)} && slice.length > 0) {
                #{e << `slice`};
                slice = [];
              }

              slice.push(param);
            };
          }
          else {
            self.$each.$$p = function() {
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
          self.$each.$$p = function() {
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
    ary = to_a
    block = -> a,b {a <=> b} unless block_given?
    return ary.sort(&block)
  end

  def sort_by(&block)
    return enum_for(:sort_by){self.enumerator_size} unless block_given?

    dup = map {
      arg = Opal.destructure(`arguments`)
      [yield(arg), arg]
    }
    dup.sort! { |a, b| `a[0]` <=> `b[0]` }
    dup.map! { |i| `i[1]` }
  end

  def take(num)
    first(num)
  end

  def take_while(&block)
    return enum_for :take_while unless block

    result = []

    each do |*args|
      value = Opal.destructure(args)

      unless yield(value)
        return result
      end

      `result.push(value)`
    end
  end

  alias to_a entries

  def zip(*others, &block)
    to_a.zip(*others)
  end
end
