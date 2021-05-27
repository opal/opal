# helpers: falsy, truthy, coerce_to

module Enumerable
  %x{
    function comparableForPattern(value) {
      if (value.length === 0) {
        value = [nil];
      }

      if (value.length > 1) {
        value = [value];
      }

      return value;
    }
  }

  def all?(pattern = undefined, &block)
    if `pattern !== undefined`
      each do |*value|
        comparable = `comparableForPattern(value)`

        return false unless pattern.public_send(:===, *comparable)
      end
    elsif block_given?
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

  def any?(pattern = undefined, &block)
    if `pattern !== undefined`
      each do |*value|
        comparable = `comparableForPattern(value)`

        return true if pattern.public_send(:===, *comparable)
      end
    elsif block_given?
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

  def chunk(&block)
    return to_enum(:chunk) { enumerator_size } unless block_given?

    ::Enumerator.new do |yielder|
      %x{
        var previous = nil, accumulate = [];

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

  def chunk_while(&block)
    raise ArgumentError, 'no block given' unless block_given?

    slice_when { |before, after| !(yield before, after) }
  end

  def collect(&block)
    return enum_for(:collect) { enumerator_size } unless block_given?

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
    return enum_for(:collect_concat) { enumerator_size } unless block_given?
    map { |item| yield item }.flatten(1)
  end

  def count(object = undefined, &block)
    result = 0

    %x{
      if (object != null && block !== nil) {
        #{warn('warning: given block not used')}
      }
    }

    if `object != null`
      block = proc do |*args|
        Opal.destructure(args) == object
      end
    elsif block.nil?
      block = proc { true }
    end

    each do |*args|
      `result++` if `Opal.yieldX(block, args)`
    end

    result
  end

  def cycle(n = nil, &block)
    unless block_given?
      return enum_for(:cycle, n) do
        if n.nil?
          respond_to?(:size) ? Float::INFINITY : nil
        else
          n = Opal.coerce_to!(n, Integer, :to_int)
          n > 0 ? enumerator_size * n : 0
        end
      end
    end

    unless n.nil?
      n = Opal.coerce_to! n, Integer, :to_int

      return if `n <= 0`
    end

    %x{
      var all = [], i, length, value;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        all.push(param);
      }

      self.$each();

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
    number = `$coerce_to(number, #{Integer}, 'to_int')`

    if `number < 0`
      raise ArgumentError, 'attempt to drop negative size'
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

          if ($falsy(value)) {
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
      return enum_for(:each_cons, n) do
        enum_size = enumerator_size
        if enum_size.nil?
          nil
        elsif enum_size == 0 || enum_size < n
          0
        else
          enum_size - n + 1
        end
      end
    end

    %x{
      var buffer = [];

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

      return nil;
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
    n = `$coerce_to(#{n}, #{Integer}, 'to_int')`

    if `n <= 0`
      raise ArgumentError, 'invalid slice size'
    end

    return enum_for(:each_slice, n) { respond_to?(:size) ? (size / n).ceil : nil } unless block_given?

    %x{
      var slice = []

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)};

        slice.push(param);

        if (slice.length === n) {
          Opal.yield1(block, slice);
          slice = [];
        }
      };

      self.$each();

      // our "last" group, if smaller than n then won't have been yielded
      if (slice.length > 0) {
        Opal.yield1(block, slice);
      }
    }

    nil
  end

  def each_with_index(*args, &block)
    return enum_for(:each_with_index, *args) { enumerator_size } unless block_given?

    %x{
      var index = 0;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)};

        block(param, index);

        index++;
      };

      self.$each.apply(self, args);
    }

    self
  end

  def each_with_object(object, &block)
    return enum_for(:each_with_object, object) { enumerator_size } unless block_given?

    %x{
      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)};

        block(param, object);
      };

      self.$each();
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

  def filter_map(&block)
    return enum_for(:filter_map) { enumerator_size } unless block_given?

    map(&block).select(&:itself)
  end

  alias find detect

  def find_all(&block)
    return enum_for(:find_all) { enumerator_size } unless block_given?

    %x{
      var result = [];

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        if ($truthy(value)) {
          result.push(param);
        }
      };

      self.$each();

      return result;
    }
  end

  alias filter find_all

  def find_index(object = undefined, &block)
    return enum_for :find_index if `object === undefined && block === nil`

    %x{
      if (object != null && block !== nil) {
        #{warn('warning: given block not used')}
      }
    }

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
      number = `$coerce_to(number, #{Integer}, 'to_int')`

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
    result = []

    each do |*value|
      cmp = `comparableForPattern(value)`
      next unless pattern.__send__(:===, *cmp)
      if block_given?
        value = [value] if value.length > 1
        value = yield(*value)
      elsif value.length <= 1
        value = value[0]
      end

      result.push(value)
    end

    result
  end

  def grep_v(pattern, &block)
    result = []

    each do |*value|
      cmp = `comparableForPattern(value)`
      next if pattern.__send__(:===, *cmp)
      if block_given?
        value = [value] if value.length > 1
        value = yield(*value)
      elsif value.length <= 1
        value = value[0]
      end

      result.push(value)
    end

    result
  end

  def group_by(&block)
    return enum_for(:group_by) { enumerator_size } unless block_given?

    hash = {}

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
    Enumerator::Lazy.new(self, enumerator_size) do |enum, *args|
      enum.yield(*args)
    end
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
            #{raise ArgumentError, 'comparison failed'};
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

      n = $coerce_to(n, #{Integer}, 'to_int');
    }

    sort(&block).reverse.first(n)
  end

  def max_by(n = nil, &block)
    return enum_for(:max_by, n) { enumerator_size } unless block

    unless n.nil?
      return sort_by(&block).reverse.take n
    end

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

  def min(n = nil, &block)
    unless n.nil?
      if block_given?
        return sort { |a, b| yield a, b }.take n
      else
        return sort.take n
      end
    end

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
            #{raise ArgumentError, 'comparison failed'};
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

  def min_by(n = nil, &block)
    return enum_for(:min_by, n) { enumerator_size } unless block

    unless n.nil?
      return sort_by(&block).take n
    end

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
    block ||= proc { |a, b| a <=> b }

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
    return enum_for(:minmax_by) { enumerator_size } unless block

    %x{
      var min_result = nil,
          max_result = nil,
          min_by,
          max_by;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        if ((min_by === undefined) || #{`value` <=> `min_by`} < 0) {
          min_result = param;
          min_by     = value;
        }

        if ((max_by === undefined) || #{`value` <=> `max_by`} > 0) {
          max_result = param;
          max_by     = value;
        }
      };

      self.$each();

      return [min_result, max_result];
    }
  end

  def none?(pattern = undefined, &block)
    if `pattern !== undefined`
      each do |*value|
        comparable = `comparableForPattern(value)`

        return false if pattern.public_send(:===, *comparable)
      end
    elsif block_given?
      each do |*value|
        if yield(*value)
          return false
        end
      end
    else
      each do |*value|
        item = Opal.destructure(value)

        return false if item
      end
    end

    true
  end

  def one?(pattern = undefined, &block)
    count = 0

    if `pattern !== undefined`
      each do |*value|
        comparable = `comparableForPattern(value)`

        if pattern.public_send(:===, *comparable)
          count += 1
          return false if count > 1
        end
      end
    elsif block_given?
      each do |*value|
        next unless yield(*value)
        count += 1

        return false if count > 1
      end
    else
      each do |*value|
        next unless Opal.destructure(value)
        count += 1

        return false if count > 1
      end
    end

    count == 1
  end

  def partition(&block)
    return enum_for(:partition) { enumerator_size } unless block_given?

    %x{
      var truthy = [], falsy = [], result;

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        if ($truthy(value)) {
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
    return enum_for(:reject) { enumerator_size } unless block_given?

    %x{
      var result = [];

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)},
            value = Opal.yield1(block, param);

        if ($falsy(value)) {
          result.push(param);
        }
      };

      self.$each();

      return result;
    }
  end

  def reverse_each(&block)
    return enum_for(:reverse_each) { enumerator_size } unless block_given?

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
    if `pattern === undefined && block === nil`
      raise ArgumentError, 'both pattern and block are given'
    end

    if `pattern !== undefined && block !== nil || arguments.length > 1`
      raise ArgumentError, "wrong number of arguments (#{`arguments.length`} expected 1)"
    end

    Enumerator.new do |e|
      %x{
        var slice = [];

        if (block !== nil) {
          if (pattern === undefined) {
            self.$each.$$p = function() {
              var param = #{Opal.destructure(`arguments`)},
                  value = Opal.yield1(block, param);

              if ($truthy(value) && slice.length > 0) {
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

              if ($truthy(value) && slice.length > 0) {
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

            if ($truthy(value) && slice.length > 0) {
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
    end
  end

  def slice_after(pattern = undefined, &block)
    if `pattern === undefined && block === nil`
      raise ArgumentError, 'both pattern and block are given'
    end

    if `pattern !== undefined && block !== nil || arguments.length > 1`
      raise ArgumentError, "wrong number of arguments (#{`arguments.length`} expected 1)"
    end

    if `pattern !== undefined`
      block = proc { |e| pattern === e }
    end

    Enumerator.new do |yielder|
      %x{
        var accumulate;

        self.$each.$$p = function() {
          var element = #{Opal.destructure(`arguments`)},
              end_chunk = Opal.yield1(block, element);

          if (accumulate == null) {
            accumulate = [];
          }

          if ($truthy(end_chunk)) {
            accumulate.push(element);
            #{yielder.yield(`accumulate`)};
            accumulate = null;
          } else {
            accumulate.push(element)
          }
        }

        self.$each();

        if (accumulate != null) {
          #{yielder.yield(`accumulate`)};
        }
      }
    end
  end

  def slice_when(&block)
    raise ArgumentError, 'wrong number of arguments (0 for 1)' unless block_given?

    Enumerator.new do |yielder|
      %x{
        var slice = nil, last_after = nil;

        self.$each_cons.$$p = function() {
          var params = #{Opal.destructure(`arguments`)},
              before = params[0],
              after = params[1],
              match = Opal.yieldX(block, [before, after]);

          last_after = after;

          if (slice === nil) {
            slice = [];
          }

          if ($truthy(match)) {
            slice.push(before);
            #{yielder.yield(`slice`)};
            slice = [];
          } else {
            slice.push(before);
          }
        }

        self.$each_cons(2);

        if (slice !== nil) {
          slice.push(last_after);
          #{yielder.yield(`slice`)};
        }
      }
    end
  end

  def sort(&block)
    ary = to_a
    block = ->(a, b) { a <=> b } unless block_given?
    ary.sort(&block)
  end

  def sort_by(&block)
    return enum_for(:sort_by) { enumerator_size } unless block_given?

    dup = map do
      arg = Opal.destructure(`arguments`)
      [yield(arg), arg]
    end
    dup.sort! { |a, b| `a[0]` <=> `b[0]` }
    dup.map! { |i| `i[1]` }
  end

  def sum(initial = 0)
    result = initial

    each do |*args|
      item = if block_given?
               yield(*args)
             else
               Opal.destructure(args)
             end
      result += item
    end

    result
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

  def uniq(&block)
    hash = {}

    each do |*args|
      value = Opal.destructure(args)

      produced = if block_given?
                   yield(value)
                 else
                   value
                 end

      unless hash.key?(produced)
        hash[produced] = value
      end
    end

    hash.values
  end

  def tally
    group_by(&:itself).transform_values(&:count)
  end

  alias to_a entries

  def to_h(*args, &block)
    return map(&block).to_h(*args) if block_given?

    %x{
      var hash = #{{}};

      self.$each.$$p = function() {
        var param = #{Opal.destructure(`arguments`)};
        var ary = #{Opal.coerce_to?(`param`, Array, :to_ary)}, key, val;
        if (!ary[Opal.s.$$is_array]) {
          #{raise TypeError, "wrong element type #{`ary`.class} (expected array)"}
        }
        if (ary.length !== 2) {
          #{raise ArgumentError, "wrong array length (expected 2, was #{`ary`.length})"}
        }
        key = ary[0];
        val = ary[1];

        Opal.hash_put(hash, key, val);
      };

      self.$each.apply(self, args);

      return hash;
    }
  end

  def zip(*others, &block)
    to_a.zip(*others)
  end
end
