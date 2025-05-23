# helpers: truthy, falsy, yield1, hash_get, hash_put, hash_delete, coerce_to, respond_to, deny_frozen_access, freeze, opal32_init, opal32_add
# backtick_javascript: true

require 'corelib/enumerable'
require 'corelib/numeric'

class ::Array < `Array`
  include ::Enumerable

  # Mark all javascript arrays as being valid ruby arrays
  `Opal.prop(self.$$prototype, '$$is_array', true)`

  %x{
    // Recent versions of V8 (> 7.1) only use an optimized implementation when Array.prototype is unmodified.
    // For instance, "array-splice.tq" has a "fast path" (ExtractFastJSArray, defined in "src/codegen/code-stub-assembler.cc")
    // but it's only enabled when "IsPrototypeInitialArrayPrototype()" is true.
    //
    // Older versions of V8 were using relatively fast JS-with-extensions code even when Array.prototype is modified:
    // https://github.com/v8/v8/blob/7.0.1/src/js/array.js#L599-L642
    //
    // In short, Array operations are slow in recent versions of V8 when the Array.prototype has been tampered.
    // So, when possible, we are using faster open-coded version to boost the performance.

    // As of V8 8.4, depending on the size of the array, this is up to ~25x times faster than Array#shift()
    // Implementation is heavily inspired by: https://github.com/nodejs/node/blob/ba684805b6c0eded76e5cd89ee00328ac7a59365/lib/internal/util.js#L341-L347
    function shiftNoArg(list) {
      var r = list[0];
      var index = 1;
      var length = list.length;
      for (; index < length; index++) {
        list[index - 1] = list[index];
      }
      list.pop();
      return r;
    }

    function toArraySubclass(obj, klass) {
      if (klass.$$name === Opal.Array) {
        return obj;
      } else {
        return klass.$allocate().$replace(#{`obj`.to_a});
      }
    }

    // A helper for keep_if and delete_if, filter is either Opal.truthy
    // or Opal.falsy.
    function filterIf(self, filter, block) {
      var value, raised = null, updated = new Array(self.length);

      for (var i = 0, i2 = 0; i < self.length; i++) {
        if (!raised) {
          try {
            value = $yield1(block, self[i])
          } catch(error) {
            raised = error;
          }
        }

        if (raised || filter(value)) {
          updated[i2] = self[i]
          i2 += 1;
        }
      }

      if (i2 !== i) {
        self.splice.apply(self, [0, updated.length].concat(updated));
        self.splice(i2, updated.length);
      }

      if (raised) throw raised;
    }

    function convertToArray(array) {
      if (!array.$$is_array) {
        array = $coerce_to(array, #{::Array}, 'to_ary');
      }
      return #{`array`.to_a};
    }

    function fast_push(arr, objects) {
      // push.apply() for arrays longer than 32767 may cause various argument errors in browsers
      // but it is significantly faster than a for loop, which pushes each element separately
      // but apply() has a overhead by itself, for a small number of elements
      // the for loop is significantly faster
      // this is using the best option depending on objects.length
      var length = objects.length;
      if (length > 6 && length < 32767) {
        arr.push.apply(arr, objects);
      } else {
        for (var i = 0; i < length; i++) {
          arr.push(objects[i]);
        }
      }
    }
  }

  def self.[](*objects)
    `toArraySubclass(objects, self)`
  end

  def initialize(size = nil, obj = nil, &block)
    %x{
      $deny_frozen_access(self);

      if (obj !== nil && block !== nil) {
        #{::Kernel.warn('warning: block supersedes default value argument')}
      }

      if (size > #{::Integer::MAX}) {
        #{::Kernel.raise ::ArgumentError, 'array size too big'}
      }

      if (arguments.length > 2) {
        #{::Kernel.raise ::ArgumentError, "wrong number of arguments (#{`arguments.length`} for 0..2)"}
      }

      if (arguments.length === 0) {
        if (self.length > 0) self.splice(0, self.length);
        return self;
      }

      if (arguments.length === 1) {
        if (size.$$is_array) {
          #{replace(size.to_a)}
          return self;
        } else if (#{size.respond_to? :to_ary}) {
          #{replace(size.to_ary)}
          return self;
        }
      }

      size = $coerce_to(size, #{::Integer}, 'to_int');

      if (size < 0) {
        #{::Kernel.raise ::ArgumentError, 'negative array size'}
      }

      self.splice(0, self.length);
      var i, value;

      if (block === nil) {
        for (i = 0; i < size; i++) {
          self.push(obj);
        }
      }
      else {
        for (i = 0, value; i < size; i++) {
          value = block(i);
          self[i] = value;
        }
      }

      return self;
    }
  end

  def self.try_convert(obj)
    ::Opal.coerce_to? obj, ::Array, :to_ary
  end

  def &(other)
    %x{
      other = convertToArray(other)

      if (self.length === 0 || other.length === 0) {
        return [];
      }

      var result = [], hash = #{{}}, i, length, item;

      for (i = 0, length = other.length; i < length; i++) {
        $hash_put(hash, other[i], true);
      }

      for (i = 0, length = self.length; i < length; i++) {
        item = self[i];
        if ($hash_delete(hash, item) !== undefined) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def |(other)
    other = `convertToArray(other)`

    %x{
      var hash = #{{}}, i, length, item;

      for (i = 0, length = self.length; i < length; i++) {
        $hash_put(hash, self[i], true);
      }

      for (i = 0, length = other.length; i < length; i++) {
        $hash_put(hash, other[i], true);
      }

      return hash.$keys();
    }
  end

  def *(other)
    return join(other.to_str) if other.respond_to? :to_str

    other = `$coerce_to(other, #{::Integer}, 'to_int')`

    if `other < 0`
      ::Kernel.raise ::ArgumentError, 'negative argument'
    end

    %x{
      var result = [],
          converted = #{to_a};

      for (var i = 0; i < other; i++) {
        result = result.concat(converted);
      }

      return result;
    }
  end

  def +(other)
    other = `convertToArray(other)`

    `self.concat(other)`
  end

  def -(other)
    other = `convertToArray(other)`

    return [] if `self.length === 0`
    return `self.slice()` if `other.length === 0`

    %x{
      var result = [], hash = #{{}}, i, length, item;

      for (i = 0, length = other.length; i < length; i++) {
        $hash_put(hash, other[i], true);
      }

      for (i = 0, length = self.length; i < length; i++) {
        item = self[i];
        if ($hash_get(hash, item) === undefined) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def <<(object)
    `$deny_frozen_access(self)`
    `self.push(object)`

    self
  end

  def <=>(other)
    if ::Array === other
      other = other.to_a
    elsif other.respond_to? :to_ary
      other = other.to_ary.to_a
    else
      return
    end

    %x{
      if (#{self} === #{other}) {
        return 0;
      }

      var count = Math.min(self.length, other.length);

      for (var i = 0; i < count; i++) {
        var tmp = #{`self[i]` <=> `other[i]`};

        if (tmp !== 0) {
          return tmp;
        }
      }

      return #{`self.length` <=> `other.length`};
    }
  end

  def ==(other)
    %x{
      var recursed = {};

      function _eqeq(array, other) {
        var i, length, a, b;

        if (array === other)
          return true;

        if (!other.$$is_array) {
          if ($respond_to(other, '$to_ary')) {
            return #{`other` == `array`};
          } else {
            return false;
          }
        }

        if (array.$$constructor !== Array)
          array = #{`array`.to_a};
        if (other.$$constructor !== Array)
          other = #{`other`.to_a};

        if (array.length !== other.length) {
          return false;
        }

        recursed[#{`array`.object_id}] = true;

        for (i = 0, length = array.length; i < length; i++) {
          a = array[i];
          b = other[i];
          if (a.$$is_array) {
            if (b.$$is_array && b.length !== a.length) {
              return false;
            }
            if (!recursed.hasOwnProperty(#{`a`.object_id})) {
              if (!_eqeq(a, b)) {
                return false;
              }
            }
          } else {
            if (!#{`a` == `b`}) {
              return false;
            }
          }
        }

        return true;
      }

      return _eqeq(self, other);
    }
  end

  %x{
    function $array_slice_range(self, index) {
      var size = self.length,
          exclude, from, to, result;

      exclude = index.excl;
      from    = index.begin === nil ? 0 : $coerce_to(index.begin, Opal.Integer, 'to_int');
      to      = index.end === nil ? -1 : $coerce_to(index.end, Opal.Integer, 'to_int');

      if (from < 0) {
        from += size;

        if (from < 0) {
          return nil;
        }
      }

      if (index.excl_rev && index.begin !== nil) {
        from += 1;
      }

      if (from > size) {
        return nil;
      }

      if (to < 0) {
        to += size;

        if (to < 0) {
          return [];
        }
      }

      if (!exclude || index.end === nil) {
        to += 1;
      }

      result = self.slice(from, to);
      return result;
    }

    function $array_slice_arithmetic_seq(self, index) {
      var array, out = [], i = 0, pseudorange;

      if (index.step < 0) {
        pseudorange = {
          begin: index.range.end,
          end: index.range.begin,
          excl: false,
          excl_rev: index.range.excl
        };
        array = $array_slice_range(self, pseudorange).$reverse();
      }
      else {
        array = $array_slice_range(self, index.range);
      }

      while (i < array.length) {
        out.push(array[i]);
        i += Math.abs(index.step);
      }

      return out;
    }

    function $array_slice_index_length(self, index, length) {
      var size = self.length,
          exclude, from, to, result;

      index = $coerce_to(index, Opal.Integer, 'to_int');

      if (index < 0) {
        index += size;

        if (index < 0) {
          return nil;
        }
      }

      if (length === undefined) {
        if (index >= size || index < 0) {
          return nil;
        }

        return self[index];
      }
      else {
        length = $coerce_to(length, Opal.Integer, 'to_int');

        if (length < 0 || index > size || index < 0) {
          return nil;
        }

        result = self.slice(index, index + length);
      }
      return result;
    }
  }

  def [](index, length = undefined)
    %x{
      if (index.$$is_range) {
        return $array_slice_range(self, index);
      }
      else if (index.$$is_arithmetic_seq) {
        return $array_slice_arithmetic_seq(self, index);
      }
      else {
        return $array_slice_index_length(self, index, length);
      }
    }
  end

  def []=(index, value, extra = undefined)
    `$deny_frozen_access(self)`

    data = nil
    %x{
      var i, size = self.length;

      if (index.$$is_range) {
        if (value.$$is_array)
          data = #{value.to_a};
        else if (#{value.respond_to? :to_ary})
          data = #{value.to_ary.to_a};
        else
          data = [value];

        var exclude = index.excl,
            from    = index.begin === nil ? 0 : $coerce_to(index.begin, Opal.Integer, 'to_int'),
            to      = index.end === nil ? -1 : $coerce_to(index.end, Opal.Integer, 'to_int');

        if (from < 0) {
          from += size;

          if (from < 0) {
            #{::Kernel.raise ::RangeError, "#{index.inspect} out of range"};
          }
        }

        if (to < 0) {
          to += size;
        }

        if (!exclude || index.end === nil) {
          to += 1;
        }

        if (from > size) {
          for (i = size; i < from; i++) {
            self[i] = nil;
          }
        }

        if (to < 0) {
          self.splice.apply(self, [from, 0].concat(data));
        }
        else {
          self.splice.apply(self, [from, to - from].concat(data));
        }

        return value;
      } else {
        if (extra === undefined) {
          #{length = 1}
        } else {
          length = value;
          value  = extra;

          if (value.$$is_array)
            data = #{value.to_a};
          else if (#{value.respond_to? :to_ary})
            data = #{value.to_ary.to_a};
          else
            data = [value];
        }

        var old;

        index  = $coerce_to(index, #{::Integer}, 'to_int');
        length = $coerce_to(length, #{::Integer}, 'to_int');

        if (index < 0) {
          old    = index;
          index += size;

          if (index < 0) {
            #{::Kernel.raise ::IndexError, "index #{`old`} too small for array; minimum #{`-self.length`}"};
          }
        }

        if (length < 0) {
          #{::Kernel.raise ::IndexError, "negative length (#{length})"}
        }

        if (index > size) {
          for (i = size; i < index; i++) {
            self[i] = nil;
          }
        }

        if (extra === undefined) {
          self[index] = value;
        }
        else {
          self.splice.apply(self, [index, length].concat(data));
        }

        return value;
      }
    }
  end

  def any?(pattern = undefined, &block)
    %x{
      if (self.length === 0) return false;

      // A special optimized fastpath for Array#any? if no argument
      // or block is given. Since Array#any? in this form is often
      // used instead of !Array#empty?, and Enumerable#any? uses
      // closure exceptions, this shortpath may provide some
      // optimization gains.
      if (pattern == null && !#{block_given?}) {
        for (var i = 0; i < self.length; i++) {
          if ($truthy(self[i])) return true;
        }
        return false;
      }
    }

    # For other cases, defer to Enumerable#any?
    super
  end

  def assoc(object)
    %x{
      for (var i = 0, length = self.length, item; i < length; i++) {
        if (item = self[i], item.length && #{`item[0]` == object}) {
          return item;
        }
      }

      return nil;
    }
  end

  def at(index)
    %x{
      index = $coerce_to(index, #{::Integer}, 'to_int')

      if (index < 0) {
        index += self.length;
      }

      if (index < 0 || index >= self.length) {
        return nil;
      }

      return self[index];
    }
  end

  def bsearch_index(&block)
    return enum_for :bsearch_index unless block_given?

    %x{
      var min = 0,
          max = self.length,
          mid,
          val,
          ret,
          smaller = false,
          satisfied = nil;

      while (min < max) {
        mid = min + Math.floor((max - min) / 2);
        val = self[mid];
        ret = $yield1(block, val);

        if (ret === true) {
          satisfied = mid;
          smaller = true;
        }
        else if (ret === false || ret === nil) {
          smaller = false;
        }
        else if (ret.$$is_number) {
          if (ret === 0) { return mid; }
          smaller = (ret < 0);
        }
        else {
          #{::Kernel.raise ::TypeError, "wrong argument type #{`ret`.class} (must be numeric, true, false or nil)"}
        }

        if (smaller) { max = mid; } else { min = mid + 1; }
      }

      return satisfied;
    }
  end

  def bsearch(&block)
    return enum_for :bsearch unless block_given?

    index = bsearch_index(&block)

    %x{
      if (index != null && index.$$is_number) {
        return self[index];
      } else {
        return index;
      }
    }
  end

  def cycle(n = nil, &block)
    unless block_given?
      return enum_for(:cycle, n) do
        if n.nil?
          ::Float::INFINITY
        else
          n = ::Opal.coerce_to!(n, ::Integer, :to_int)
          n > 0 ? enumerator_size * n : 0
        end
      end
    end

    return if empty? || n == 0

    %x{
      var i, length, value;

      if (n === nil) {
        while (true) {
          for (i = 0, length = self.length; i < length; i++) {
            value = $yield1(block, self[i]);
          }
        }
      }
      else {
        n = #{::Opal.coerce_to!(n, ::Integer, :to_int)};
        if (n <= 0) {
          return self;
        }

        while (n > 0) {
          for (i = 0, length = self.length; i < length; i++) {
            value = $yield1(block, self[i]);
          }

          n--;
        }
      }
    }

    self
  end

  def clear
    `$deny_frozen_access(self)`

    `self.splice(0, self.length)`

    self
  end

  def count(object = undefined, &block)
    if `object !== undefined` || block
      super
    else
      size
    end
  end

  def initialize_copy(other)
    replace other
  end

  def collect(&block)
    return enum_for(:collect) { size } unless block_given?

    %x{
      var result = [];

      for (var i = 0; i < self.length; i++) {
        var value = $yield1(block, self[i]);
        result[i] = value;
      }

      return result;
    }
  end

  def collect!(&block)
    return enum_for(:collect!) { size } unless block_given?

    %x{
      $deny_frozen_access(self);

      for (var i = 0; i < self.length; i++) {
        var value = $yield1(block, self[i]);
        self[i] = value;
      }
    }

    self
  end

  %x{
    function binomial_coefficient(n, k) {
      if (n === k || k === 0) {
        return 1;
      }

      if (k > 0 && n > k) {
        return binomial_coefficient(n - 1, k - 1) + binomial_coefficient(n - 1, k);
      }

      return 0;
    }
  }

  def combination(n)
    num = ::Opal.coerce_to! n, ::Integer, :to_int
    return enum_for(:combination, num) { `binomial_coefficient(#{self}.length, num)` } unless block_given?

    %x{
      var i, length, stack, chosen, lev, done, next;

      if (num === 0) {
        #{yield []}
      } else if (num === 1) {
        for (i = 0, length = self.length; i < length; i++) {
          #{yield `[self[i]]`}
        }
      }
      else if (num === self.length) {
        #{yield `self.slice()`}
      }
      else if (num >= 0 && num < self.length) {
        stack = [];
        for (i = 0; i <= num + 1; i++) {
          stack.push(0);
        }

        chosen = [];
        lev = 0;
        done = false;
        stack[0] = -1;

        while (!done) {
          chosen[lev] = self[stack[lev+1]];
          while (lev < num - 1) {
            lev++;
            next = stack[lev+1] = stack[lev] + 1;
            chosen[lev] = self[next];
          }
          #{ yield `chosen.slice()` }
          lev++;
          do {
            done = (lev === 0);
            stack[lev]++;
            lev--;
          } while ( stack[lev+1] + num === self.length + lev + 1 );
        }
      }
    }
    self
  end

  def repeated_combination(n)
    num = ::Opal.coerce_to! n, ::Integer, :to_int

    unless block_given?
      return enum_for(:repeated_combination, num) { `binomial_coefficient(self.length + num - 1, num)` }
    end

    %x{
      function iterate(max, from, buffer, self) {
        if (buffer.length == max) {
          var copy = buffer.slice();
          #{yield `copy`}
          return;
        }
        for (var i = from; i < self.length; i++) {
          buffer.push(self[i]);
          iterate(max, i, buffer, self);
          buffer.pop();
        }
      }

      if (num >= 0) {
        iterate(num, 0, [], self);
      }
    }
    self
  end

  def compact
    %x{
      var result = [];

      for (var i = 0, length = self.length, item; i < length; i++) {
        item = self[i];
        if (item !== nil && item != null) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def compact!
    %x{
      $deny_frozen_access(self);

      var original = self.length;

      for (var i = 0, length = self.length, item; i < length; i++) {
        item = self[i];
        if (item === nil || item == null) {
          self.splice(i, 1);

          length--;
          i--;
        }
      }

      return self.length === original ? nil : self;
    }
  end

  def concat(*others)
    `$deny_frozen_access(self)`

    others = others.map do |other|
      `other = convertToArray(other)`

      if other.equal?(self)
        other = other.dup
      end

      other
    end

    others.each do |other|
      %x{
        for (var i = 0, length = other.length; i < length; i++) {
          self.push(other[i]);
        }
      }
    end

    self
  end

  def delete(object)
    %x{
      var original = self.length;

      for (var i = 0, length = original; i < length; i++) {
        if (#{`self[i]` == object}) {
          $deny_frozen_access(self);

          self.splice(i, 1);

          length--;
          i--;
        }
      }

      if (self.length === original) {
        if (#{block_given?}) {
          return #{yield};
        }
        return nil;
      }
      return object;
    }
  end

  def delete_at(index)
    %x{
      $deny_frozen_access(self);

      index = $coerce_to(index, #{::Integer}, 'to_int');

      if (index < 0) {
        index += self.length;
      }

      if (index < 0 || index >= self.length) {
        return nil;
      }

      var result = self[index];

      self.splice(index, 1);

      return result;
    }
  end

  def delete_if(&block)
    return enum_for(:delete_if) { size } unless block_given?
    %x{
      $deny_frozen_access(self);

      filterIf(self, $falsy, block)
    }
    self
  end

  def difference(*arrays)
    arrays.reduce(to_a.dup) { |a, b| a - b }
  end

  def dig(idx, *idxs)
    item = self[idx]

    %x{
      if (item === nil || idxs.length === 0) {
        return item;
      }
    }

    unless item.respond_to?(:dig)
      ::Kernel.raise ::TypeError, "#{item.class} does not have #dig method"
    end

    item.dig(*idxs)
  end

  def drop(number)
    %x{
      number = $coerce_to(number, #{::Integer}, 'to_int');

      if (number < 0) {
        #{::Kernel.raise ::ArgumentError}
      }

      return self.slice(number);
    }
  end

  def dup
    %x{
      if (self.$$class === Opal.Array &&
          self.$$class.$allocate.$$pristine &&
          self.$copy_instance_variables.$$pristine &&
          self.$initialize_dup.$$pristine) {
        return self.slice(0);
      }
    }

    super
  end

  def each(&block)
    return enum_for(:each) { size } unless block_given?

    %x{
      for (var i = 0; i < self.length; i++) {
        $yield1(block, self[i]);
      }
    }

    self
  end

  def each_index(&block)
    return enum_for(:each_index) { size } unless block_given?

    %x{
      for (var i = 0; i < self.length; i++) {
        $yield1(block, i);
      }
    }

    self
  end

  def empty?
    `self.length === 0`
  end

  def eql?(other)
    %x{
      var recursed = {};

      function _eql(array, other) {
        var i, length, a, b;

        if (!other.$$is_array) {
          return false;
        }

        other = #{other.to_a};

        if (array.length !== other.length) {
          return false;
        }

        recursed[#{`array`.object_id}] = true;

        for (i = 0, length = array.length; i < length; i++) {
          a = array[i];
          b = other[i];
          if (a.$$is_array) {
            if (b.$$is_array && b.length !== a.length) {
              return false;
            }
            if (!recursed.hasOwnProperty(#{`a`.object_id})) {
              if (!_eql(a, b)) {
                return false;
              }
            }
          } else {
            if (!#{`a`.eql?(`b`)}) {
              return false;
            }
          }
        }

        return true;
      }

      return _eql(self, other);
    }
  end

  def fetch(index, defaults = undefined, &block)
    %x{
      var original = index;

      index = $coerce_to(index, #{::Integer}, 'to_int');

      if (index < 0) {
        index += self.length;
      }

      if (index >= 0 && index < self.length) {
        return self[index];
      }

      if (block !== nil && defaults != null) {
        #{warn('warning: block supersedes default value argument')}
      }

      if (block !== nil) {
        return block(original);
      }

      if (defaults != null) {
        return defaults;
      }

      if (self.length === 0) {
        #{::Kernel.raise ::IndexError, "index #{`original`} outside of array bounds: 0...0"}
      }
      else {
        #{::Kernel.raise ::IndexError, "index #{`original`} outside of array bounds: -#{`self.length`}...#{`self.length`}"};
      }
    }
  end

  def fill(*args, &block)
    %x{
      $deny_frozen_access(self);

      var i, length, value;
    }

    if block
      if `args.length > 2`
        ::Kernel.raise ::ArgumentError, "wrong number of arguments (#{args.length} for 0..2)"
      end

      one, two = args
    else
      if `args.length == 0`
        ::Kernel.raise ::ArgumentError, 'wrong number of arguments (0 for 1..3)'
      elsif `args.length > 3`
        ::Kernel.raise ::ArgumentError, "wrong number of arguments (#{args.length} for 1..3)"
      end

      obj, one, two = args
    end

    if ::Range === one
      ::Kernel.raise ::TypeError, 'length invalid with range' if two

      left   = `one.begin === nil ? 0 : $coerce_to(one.begin, #{::Integer}, 'to_int')`
      `left += this.length` if `left < 0`
      ::Kernel.raise ::RangeError, "#{one.inspect} out of range" if `left < 0`

      right = `one.end === nil ? -1 : $coerce_to(one.end, #{::Integer}, 'to_int')`
      `right += this.length` if `right < 0`
      `right += 1` unless one.exclude_end?

      return self if `right <= left`
    elsif one
      left   = `$coerce_to(one, #{::Integer}, 'to_int')`
      `left += this.length` if `left < 0`
      left   = 0 if `left < 0`

      if two
        right = `$coerce_to(two, #{::Integer}, 'to_int')`

        return self if `right == 0`

        `right += left`
      else
        right = `this.length`
      end
    else
      left  = 0
      right = `this.length`
    end

    if `left > this.length`
      %x{
        for (i = this.length; i < right; i++) {
          self[i] = nil;
        }
      }
    end

    if `right > this.length`
      `this.length = right`
    end

    if block
      %x{
        for (length = this.length; left < right; left++) {
          value = block(left);
          self[left] = value;
        }
      }
    else
      %x{
        for (length = this.length; left < right; left++) {
          self[left] = #{obj};
        }
      }
    end

    self
  end

  def first(count = undefined)
    %x{
      if (count == null) {
        return self.length === 0 ? nil : self[0];
      }

      count = $coerce_to(count, #{::Integer}, 'to_int');

      if (count < 0) {
        #{::Kernel.raise ::ArgumentError, 'negative array size'};
      }

      return self.slice(0, count);
    }
  end

  def flatten(level = undefined)
    %x{
      function _flatten(array, level) {
        var result = [],
            i, length,
            item, ary;

        array = #{`array`.to_a};

        for (i = 0, length = array.length; i < length; i++) {
          item = array[i];

          if (!$respond_to(item, '$to_ary', true)) {
            result.push(item);
            continue;
          }

          ary = #{`item`.to_ary};

          if (ary === nil) {
            result.push(item);
            continue;
          }

          if (!ary.$$is_array) {
            #{::Kernel.raise ::TypeError, "can't convert #{`ary`.class} into Array (#{`ary`.class}#to_ary gives #{`ary`.class})"};
          }

          if (ary === self || ary === array) {
            #{::Kernel.raise ::ArgumentError, 'tried to flatten recursive array'};
          }

          switch (level) {
          case undefined:
            result = result.concat(_flatten(ary));
            break;
          case 0:
            result.push(ary);
            break;
          default:
            fast_push(result, _flatten(ary, level - 1));
          }
        }
        return result;
      }

      if (level !== undefined) {
        level = $coerce_to(level, #{::Integer}, 'to_int');
      }

      return _flatten(self, level);
    }
  end

  def flatten!(level = undefined)
    %x{
      $deny_frozen_access(self);

      var flattened = #{flatten level};

      if (self.length == flattened.length) {
        for (var i = 0, length = self.length; i < length; i++) {
          if (self[i] !== flattened[i]) {
            break;
          }
        }

        if (i == length) {
          return nil;
        }
      }

      #{replace `flattened`};
    }

    self
  end

  def freeze
    return self if frozen?

    `$freeze(self)`
  end

  `var $hash_ids`

  def hash
    %x{
      var top = ($hash_ids === undefined),
          result = $opal32_init(),
          hash_id = self.$object_id(),
          item, i, key, values;

      result = $opal32_add(result, 0xA);
      result = $opal32_add(result, self.length);

      if (top) {
        $hash_ids = new Map();
      }
      // return early for recursive structures
      else if ($hash_ids.has(hash_id)) {
        return $opal32_add(result, 0x01010101);
      }

      try {
        if (!top) {
          values = $hash_ids.values();
          for (item of values) {
            if (#{eql?(`item`)}) {
              return $opal32_add(result, 0x01010101);
            }
          }
        }

        $hash_ids.set(hash_id, self);

        for (i = 0; i < self.length; i++) {
          item = self[i];
          result = $opal32_add(result, item.$hash());
        }

        return result;
      } finally {
        if (top) {
          $hash_ids = undefined;
        }
      }
    }
  end

  def include?(member)
    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        if ($eqeq(self[i], member)) {
          return true;
        }
      }

      return false;
    }
  end

  def index(object = undefined, &block)
    %x{
      var i, length, value;

      if (object != null && block !== nil) {
        #{warn('warning: given block not used')}
      }

      if (object != null) {
        for (i = 0, length = self.length; i < length; i++) {
          if (#{`self[i]` == object}) {
            return i;
          }
        }
      }
      else if (block !== nil) {
        for (i = 0; i < self.length; i++) {
          value = block(self[i]);

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        return #{enum_for :index};
      }

      return nil;
    }
  end

  def insert(index, *objects)
    %x{
      $deny_frozen_access(self);

      index = $coerce_to(index, #{::Integer}, 'to_int');

      if (objects.length > 0) {
        if (index < 0) {
          index += self.length + 1;

          if (index < 0) {
            #{ ::Kernel.raise ::IndexError, "#{index} is out of bounds" };
          }
        }
        if (index > self.length) {
          for (var i = self.length; i < index; i++) {
            self.push(nil);
          }
        }

        self.splice.apply(self, [index, 0].concat(objects));
      }
    }

    self
  end

  `var inspect_stack = []`

  def inspect
    %x{
      var result = [],
      id = #{__id__},
      pushed = true;
    }

    begin
      %x{
        if (inspect_stack.indexOf(id) !== -1) {
          pushed = false;
          return '[...]';
        }
        inspect_stack.push(id)

        for (var i = 0, length = self.length; i < length; i++) {
          var item = #{self[`i`]};

          result.push(#{Opal.inspect(`item`)});
        }

        return '[' + result.join(', ') + ']';
      }
      nil
    ensure
      `if (pushed) inspect_stack.pop()`
    end
  end

  def intersection(*arrays)
    %x{
      if (arrays.length === 0) {
        return #{to_a.dup};
      }
      arrays = arrays.map(convertToArray);
      if (self.length === 0) {
        return [];
      }
    }

    arrays = arrays.sort_by(&:length)
    # When self is the smallest among the arrays
    if `self.length < arrays[0].length`
      return arrays.reduce(self, &:&)
    end

    # First, calculate intersection of argument arrays.
    # Array#& is faster when the argument size is small.
    # So `largest & shortest & second_shortest & ...` would be the fastest.
    largest = `arrays.pop()`
    intersection_of_args = arrays.reduce(largest, &:&)

    # self array must come last to maintain the order
    self & intersection_of_args
  end

  def intersect?(other)
    %x{
      var small, large, hash = #{{}}, i, length;
      if (self.length < other.length) {
        small = self;
        large = other;
      } else {
        small = other;
        large = self;
      }

      for (i = 0, length = small.length; i < length; i++) {
        $hash_put(hash, small[i], true);
      }

      for (i = 0, length = large.length; i < length; i++) {
        if ($hash_get(hash, large[i])) {
          return true;
        }
      }
      return false;
    }
  end

  def join(sep = nil)
    return '' if `self.length === 0`

    if `sep === nil`
      sep = $,
    end

    %x{
      var result = [];
      var i, length, item, tmp;

      for (i = 0, length = self.length; i < length; i++) {
        item = self[i];

        if ($respond_to(item, '$to_str')) {
          tmp = #{`item`.to_str};

          if (tmp !== nil) {
            result.push(#{`tmp`.to_s});

            continue;
          }
        }

        if ($respond_to(item, '$to_ary')) {
          tmp = #{`item`.to_ary};

          if (tmp === self) {
            #{::Kernel.raise ::ArgumentError};
          }

          if (tmp !== nil) {
            result.push(#{`tmp`.join(sep)});

            continue;
          }
        }

        if ($respond_to(item, '$to_s')) {
          tmp = #{`item`.to_s};

          if (tmp !== nil) {
            result.push(tmp);

            continue;
          }
        }

        #{::Kernel.raise ::NoMethodError.new("#{Opal.inspect(item)} doesn't respond to #to_str, #to_ary or #to_s", 'to_str')};
      }

      if (sep === nil) {
        return result.join('');
      }
      else {
        return result.join(#{::Opal.coerce_to!(sep, ::String, :to_str).to_s});
      }
    }
  end

  def keep_if(&block)
    return enum_for(:keep_if) { size } unless block_given?
    %x{
      $deny_frozen_access(self);

      filterIf(self, $truthy, block)
    }
    self
  end

  def last(count = undefined)
    %x{
      if (count == null) {
        return self.length === 0 ? nil : self[self.length - 1];
      }

      count = $coerce_to(count, #{::Integer}, 'to_int');

      if (count < 0) {
        #{::Kernel.raise ::ArgumentError, 'negative array size'};
      }

      if (count > self.length) {
        count = self.length;
      }

      return self.slice(self.length - count, self.length);
    }
  end

  def length
    `self.length`
  end

  def max(n = undefined, &block)
    each.max(n, &block)
  end

  def min(&block)
    each.min(&block)
  end

  %x{
    // Returns the product of from, from-1, ..., from - how_many + 1.
    function descending_factorial(from, how_many) {
      var count = how_many >= 0 ? 1 : 0;
      while (how_many) {
        count *= from;
        from--;
        how_many--;
      }
      return count;
    }
  }

  def permutation(num = undefined, &block)
    unless block_given?
      return enum_for(:permutation, num) do
        `descending_factorial(self.length, num === undefined ? self.length : num)`
      end
    end

    %x{
      var permute, offensive, output;

      if (num === undefined) {
        num = self.length;
      }
      else {
        num = $coerce_to(num, #{::Integer}, 'to_int');
      }

      if (num < 0 || self.length < num) {
        // no permutations, yield nothing
      }
      else if (num === 0) {
        // exactly one permutation: the zero-length array
        #{ yield [] }
      }
      else if (num === 1) {
        // this is a special, easy case
        for (var i = 0; i < self.length; i++) {
          #{ yield `[self[i]]` }
        }
      }
      else {
        // this is the general case
        #{ perm = Array.new(num) };
        #{ used = Array.new(`self.length`, false) };

        permute = function(num, perm, index, used, blk) {
          self = this;
          for(var i = 0; i < self.length; i++){
            if(#{ !used[`i`] }) {
              perm[index] = i;
              if(index < num - 1) {
                used[i] = true;
                permute.call(self, num, perm, index + 1, used, blk);
                used[i] = false;
              }
              else {
                output = [];
                for (var j = 0; j < perm.length; j++) {
                  output.push(self[perm[j]]);
                }
                $yield1(blk, output);
              }
            }
          }
        }

        if (#{block_given?}) {
          // offensive (both definitions) copy.
          offensive = self.slice();
          permute.call(offensive, num, perm, 0, used, block);
        }
        else {
          permute.call(self, num, perm, 0, used, block);
        }
      }
    }

    self
  end

  def repeated_permutation(n)
    num = ::Opal.coerce_to! n, ::Integer, :to_int
    return enum_for(:repeated_permutation, num) { num >= 0 ? size**num : 0 } unless block_given?

    %x{
      function iterate(max, buffer, self) {
        if (buffer.length == max) {
          var copy = buffer.slice();
          #{yield `copy`}
          return;
        }
        for (var i = 0; i < self.length; i++) {
          buffer.push(self[i]);
          iterate(max, buffer, self);
          buffer.pop();
        }
      }

      iterate(num, [], self.slice());
    }

    self
  end

  def pop(count = undefined)
    `$deny_frozen_access(self)`

    if `count === undefined`
      return if `self.length === 0`
      return `self.pop()`
    end

    count = `$coerce_to(count, #{::Integer}, 'to_int')`

    if `count < 0`
      ::Kernel.raise ::ArgumentError, 'negative array size'
    end

    return [] if `self.length === 0`

    if `count === 1`
      `[self.pop()]`
    elsif `count > self.length`
      `self.splice(0, self.length)`
    else
      `self.splice(self.length - count, self.length)`
    end
  end

  def product(*args, &block)
    %x{
      var result = #{block_given?} ? null : [],
          n = args.length + 1,
          counters = new Array(n),
          lengths  = new Array(n),
          arrays   = new Array(n),
          i, m, subarray, len, resultlen = 1;

      arrays[0] = self;
      for (i = 1; i < n; i++) {
        arrays[i] = $coerce_to(args[i - 1], #{::Array}, 'to_ary');
      }

      for (i = 0; i < n; i++) {
        len = arrays[i].length;
        if (len === 0) {
          return result || self;
        }
        resultlen *= len;
        if (resultlen > 2147483647) {
          #{::Kernel.raise ::RangeError, 'too big to product'}
        }
        lengths[i] = len;
        counters[i] = 0;
      }

      outer_loop: for (;;) {
        subarray = [];
        for (i = 0; i < n; i++) {
          subarray.push(arrays[i][counters[i]]);
        }
        if (result) {
          result.push(subarray);
        } else {
          #{yield `subarray`}
        }
        m = n - 1;
        counters[m]++;
        while (counters[m] === lengths[m]) {
          counters[m] = 0;
          if (--m < 0) break outer_loop;
          counters[m]++;
        }
      }

      return result || self;
    }
  end

  def push(*objects)
    %x{
      $deny_frozen_access(self);

      fast_push(self, objects);
    }

    self
  end

  def rassoc(object)
    %x{
      for (var i = 0, length = self.length, item; i < length; i++) {
        item = self[i];

        if (item.length && item[1] !== undefined) {
          if (#{`item[1]` == object}) {
            return item;
          }
        }
      }

      return nil;
    }
  end

  def reject(&block)
    return enum_for(:reject) { size } unless block_given?

    %x{
      var result = [];

      for (var i = 0, value; i < self.length; i++) {
        value = block(self[i]);

        if (value === false || value === nil) {
          result.push(self[i]);
        }
      }
      return result;
    }
  end

  def reject!(&block)
    return enum_for(:reject!) { size } unless block_given?

    `$deny_frozen_access(self)`

    original = length
    delete_if(&block)

    unless length == original
      self
    end
  end

  def replace(other)
    `$deny_frozen_access(self)`

    other = `convertToArray(other)`

    %x{
      if (self.length > 0) self.splice(0, self.length);
      fast_push(self, other);
    }

    self
  end

  def reverse
    `self.slice(0).reverse()`
  end

  def reverse!
    `$deny_frozen_access(self)`

    `self.reverse()`
  end

  def reverse_each(&block)
    return enum_for(:reverse_each) { size } unless block_given?

    %x{
      for (var i = self.length - 1; i >= 0; i--) {
        $yield1(block, self[i]);
      }
    }
    self
  end

  def rindex(object = undefined, &block)
    %x{
      var i, value;

      if (object != null && block !== nil) {
        #{warn('warning: given block not used')}
      }

      if (object != null) {
        for (i = self.length - 1; i >= 0; i--) {
          if (i >= self.length) {
            break;
          }
          if (#{`self[i]` == `object`}) {
            return i;
          }
        }
      }
      else if (block !== nil) {
        for (i = self.length - 1; i >= 0; i--) {
          if (i >= self.length) {
            break;
          }

          value = block(self[i]);

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else if (object == null) {
        return #{enum_for :rindex};
      }

      return nil;
    }
  end

  def rotate(n = 1)
    %x{
      var ary, idx, firstPart, lastPart;

      n = $coerce_to(n, #{::Integer}, 'to_int')

      if (self.length === 1) {
        return self.slice();
      }
      if (self.length === 0) {
        return [];
      }

      ary = self.slice();
      idx = n % ary.length;

      firstPart = ary.slice(idx);
      lastPart = ary.slice(0, idx);
      return firstPart.concat(lastPart);
    }
  end

  def rotate!(cnt = 1)
    %x{
      $deny_frozen_access(self);

      if (self.length === 0 || self.length === 1) {
        return self;
      }
      cnt = $coerce_to(cnt, #{::Integer}, 'to_int');
    }
    ary = rotate(cnt)
    replace ary
  end

  class self::SampleRandom
    def initialize(rng)
      @rng = rng
    end

    def rand(size)
      random = `$coerce_to(#{@rng.rand(size)}, #{::Integer}, 'to_int')`
      ::Kernel.raise ::RangeError, 'random value must be >= 0' if `random < 0`
      ::Kernel.raise ::RangeError, 'random value must be less than Array size' unless `random < size`

      random
    end
  end

  def sample(count = undefined, options = undefined)
    return at ::Kernel.rand(`self.length`) if `count === undefined`

    if `options === undefined`
      if (o = ::Opal.coerce_to? count, ::Hash, :to_hash)
        options = o
        count = nil
      else
        options = nil
        count = `$coerce_to(count, #{::Integer}, 'to_int')`
      end
    else
      count = `$coerce_to(count, #{::Integer}, 'to_int')`
      options = `$coerce_to(options, #{::Hash}, 'to_hash')`
    end

    if count && `count < 0`
      ::Kernel.raise ::ArgumentError, 'count must be greater than 0'
    end

    rng = options[:random] if options
    rng = if rng && rng.respond_to?(:rand)
            SampleRandom.new rng
          else
            ::Kernel
          end

    return `self[#{rng.rand(`self.length`)}]` unless count

    %x{

      var abandon, spin, result, i, j, k, targetIndex, oldValue;

      if (count > self.length) {
        count = self.length;
      }

      switch (count) {
        case 0:
          return [];
          break;
        case 1:
          return [self[#{rng.rand(`self.length`)}]];
          break;
        case 2:
          i = #{rng.rand(`self.length`)};
          j = #{rng.rand(`self.length - 1`)};
          if (i <= j) {
            j++;
          }
          return [self[i], self[j]];
          break;
        default:
          if (self.length / count > 3) {
            abandon = false;
            spin = 0;

            result = #{ Array.new(count) };
            i = 1;

            result[0] = #{rng.rand(`self.length`)};
            while (i < count) {
              k = #{rng.rand(`self.length`)};
              j = 0;

              while (j < i) {
                while (k === result[j]) {
                  spin++;
                  if (spin > 100) {
                    abandon = true;
                    break;
                  }
                  k = #{rng.rand(`self.length`)};
                }
                if (abandon) { break; }

                j++;
              }

              if (abandon) { break; }

              result[i] = k;

              i++;
            }

            if (!abandon) {
              i = 0;
              while (i < count) {
                result[i] = self[result[i]];
                i++;
              }

              return result;
            }
          }

          result = self.slice();

          for (var c = 0; c < count; c++) {
            targetIndex = #{rng.rand(`self.length - c`)} + c;
            oldValue = result[c];
            result[c] = result[targetIndex];
            result[targetIndex] = oldValue;
          }

          return count === self.length ? result : #{`result`[0, count]};
      }
    }
  end

  def select(&block)
    return enum_for(:select) { size } unless block_given?

    %x{
      var result = [];

      for (var i = 0, item, value; i < self.length; i++) {
        item = self[i];

        value = $yield1(block, item);

        if ($truthy(value)) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def select!(&block)
    return enum_for(:select!) { size } unless block_given?

    %x{
      $deny_frozen_access(self)

      var original = self.length;
      #{ keep_if(&block) };
      return self.length === original ? nil : self;
    }
  end

  def shift(count = undefined)
    `$deny_frozen_access(self)`

    if `count === undefined`
      return if `self.length === 0`
      return `shiftNoArg(self)`
    end

    count = `$coerce_to(count, #{::Integer}, 'to_int')`

    if `count < 0`
      ::Kernel.raise ::ArgumentError, 'negative array size'
    end

    return [] if `self.length === 0`

    `self.splice(0, count)`
  end

  def shuffle(rng = undefined)
    dup.to_a.shuffle!(rng)
  end

  def shuffle!(rng = undefined)
    %x{
      $deny_frozen_access(self);

      var randgen, i = self.length, j, tmp;

      if (rng !== undefined) {
        rng = #{::Opal.coerce_to?(rng, ::Hash, :to_hash)};

        if (rng !== nil) {
          rng = #{rng[:random]};

          if (rng !== nil && #{rng.respond_to?(:rand)}) {
            randgen = rng;
          }
        }
      }

      while (i) {
        if (randgen) {
          j = randgen.$rand(i).$to_int();

          if (j < 0) {
            #{::Kernel.raise ::RangeError, "random number too small #{`j`}"}
          }

          if (j >= i) {
            #{::Kernel.raise ::RangeError, "random number too big #{`j`}"}
          }
        }
        else {
          j = #{rand(`i`)};
        }

        tmp = self[--i];
        self[i] = self[j];
        self[j] = tmp;
      }

      return self;
    }
  end

  def slice!(index, length = undefined)
    `$deny_frozen_access(self)`

    result = nil

    if `length === undefined`
      if ::Range === index
        range = index
        result = self[range]

        range_start = `range.begin === nil ? 0 : $coerce_to(range.begin, #{::Integer}, 'to_int')`
        range_end = `range.end === nil ? -1 : $coerce_to(range.end, #{::Integer}, 'to_int')`

        %x{
          if (range_start < 0) {
            range_start += self.length;
          }

          if (range_end < 0) {
            range_end += self.length;
          } else if (range_end >= self.length) {
            range_end = self.length - 1;
            if (range.excl) {
              range_end += 1;
            }
          }

          var range_length = range_end - range_start;
          if (range.excl && range.end !== nil) {
            range_end -= 1;
          } else {
            range_length += 1;
          }

          if (range_start < self.length && range_start >= 0 && range_end < self.length && range_end >= 0 && range_length > 0) {
            self.splice(range_start, range_length);
          }
        }
      else
        start = `$coerce_to(index, #{::Integer}, 'to_int')`
        %x{
          if (start < 0) {
            start += self.length;
          }

          if (start < 0 || start >= self.length) {
            return nil;
          }

          result = self[start];

          if (start === 0) {
            self.shift();
          } else {
            self.splice(start, 1);
          }
        }
      end
    else
      start = `$coerce_to(index, #{::Integer}, 'to_int')`
      length = `$coerce_to(length, #{::Integer}, 'to_int')`

      %x{
        if (length < 0) {
          return nil;
        }

        var end = start + length;

        result = #{self[start, length]};

        if (start < 0) {
          start += self.length;
        }

        if (start + length > self.length) {
          length = self.length - start;
        }

        if (start < self.length && start >= 0) {
          self.splice(start, length);
        }
      }
    end
    result
  end

  def sort(&block)
    return self unless `self.length > 1`

    %x{
      if (block === nil) {
        block = function(a, b) {
          return #{`a` <=> `b`};
        };
      }

      return self.slice().sort(function(x, y) {
        var ret = block(x, y);

        if (ret === nil) {
          #{::Kernel.raise ::ArgumentError, "comparison of #{`x`.inspect} with #{`y`.inspect} failed"};
        }

        return #{`ret` > 0} ? 1 : (#{`ret` < 0} ? -1 : 0);
      });
    }
  end

  def sort!(&block)
    %x{
      $deny_frozen_access(self)

      var result;

      if (#{block_given?}) {
        result = #{`self.slice()`.sort(&block)};
      }
      else {
        result = #{`self.slice()`.sort};
      }

      self.length = 0;
      for(var i = 0, length = result.length; i < length; i++) {
        self.push(result[i]);
      }

      return self;
    }
  end

  def sort_by!(&block)
    return enum_for(:sort_by!) { size } unless block_given?

    `$deny_frozen_access(self)`

    replace sort_by(&block)
  end

  def take(count)
    %x{
      if (count < 0) {
        #{::Kernel.raise ::ArgumentError};
      }

      return self.slice(0, count);
    }
  end

  def take_while(&block)
    %x{
      var result = [];

      for (var i = 0, item, value; i < self.length; i++) {
        item = self[i];

        value = block(item);

        if (value === false || value === nil) {
          return result;
        }

        result.push(item);
      }

      return result;
    }
  end

  def to_a
    %x{
      if (self.$$class === Opal.Array) {
        return self;
      }
      else {
        return Opal.Array.$new(self);
      }
    }
  end

  def to_ary
    self
  end

  def to_h(&block)
    array = self
    array = array.map(&block) if block_given?

    %x{
      var i, len = array.length, ary, key, val, hash = #{{}};

      for (i = 0; i < len; i++) {
        ary = #{::Opal.coerce_to?(`array[i]`, ::Array, :to_ary)};
        if (!ary.$$is_array) {
          #{::Kernel.raise ::TypeError, "wrong element type #{`array[i]`.class} at #{`i`} (expected array)"}
        }
        if (ary.length !== 2) {
          #{::Kernel.raise ::ArgumentError, "element has wrong array length at #{`i`} (expected 2, was #{`ary`.length})"}
        }
        key = ary[0];
        val = ary[1];
        $hash_put(hash, key, val);
      }

      return hash;
    }
  end

  def transpose
    return [] if empty?

    result = []
    max    = nil

    each do |row|
      `row = convertToArray(row)`

      max ||= `row.length`

      if `row.length` != max
        ::Kernel.raise ::IndexError, "element size differs (#{`row.length`} should be #{max})"
      end

      `row.length`.times do |i|
        entry = (result[i] ||= [])
        entry << row.at(i)
      end
    end

    result
  end

  def union(*arrays)
    arrays.reduce(uniq) { |a, b| a | b }
  end

  def uniq(&block)
    %x{
      var hash = #{{}}, i, length, item, key;

      if (block === nil) {
        for (i = 0, length = self.length; i < length; i++) {
          item = self[i];
          if ($hash_get(hash, item) === undefined) {
            $hash_put(hash, item, item);
          }
        }
      }
      else {
        for (i = 0; i < self.length; i++) {
          item = self[i];
          key = $yield1(block, item);
          if ($hash_get(hash, key) === undefined) {
            $hash_put(hash, key, item);
          }
        }
      }

      return #{`hash`.values};
    }
  end

  def uniq!(&block)
    %x{
      $deny_frozen_access(self);

      var hash = #{{}}, i, item, key, delete_indexes = [];

      for (i = 0; i < self.length; i++) {
        item = self[i];
        key = (block === nil ? item : $yield1(block, item));

        if ($hash_get(hash, key) === undefined) {
          $hash_put(hash, key, item);
        } else {
          delete_indexes.push(i);
        }
      }

      for (i = delete_indexes.length - 1; i >= 0; i--) {
        self.splice(delete_indexes[i], 1);
      }

      return delete_indexes.length === 0 ? nil : self;
    }
  end

  def unshift(*objects)
    %x{
      $deny_frozen_access(self);

      var selfLength = self.length
      var objectsLength = objects.length
      if (objectsLength == 0) return self;
      var index = selfLength - objectsLength
      for (var i = 0; i < objectsLength; i++) {
        self.push(self[index + i])
      }
      var len = selfLength - 1
      while (len - objectsLength >= 0) {
        self[len] = self[len - objectsLength]
        len--
      }
      for (var j = 0; j < objectsLength; j++) {
        self[j] = objects[j]
      }
      return self;
    }
  end

  def values_at(*args)
    out = []

    args.each do |elem|
      if elem.is_a? ::Range
        finish = `#{elem.end} === nil ? -1 : $coerce_to(#{elem.end}, #{::Integer}, 'to_int')`
        start = `#{elem.begin} === nil ? 0 : $coerce_to(#{elem.begin}, #{::Integer}, 'to_int')`

        %x{
          if (start < 0) {
            start = start + self.length;
            #{next};
          }
        }

        %x{
          if (finish < 0) {
            finish = finish + self.length;
          }
          if (#{elem.exclude_end?} && #{elem.end} !== nil) {
            finish--;
          }
          if (finish < start) {
            #{next};
          }
        }

        start.upto(finish) { |i| out << at(i) }
      else
        i = `$coerce_to(elem, #{::Integer}, 'to_int')`
        out << at(i)
      end
    end

    out
  end

  def zip(*others, &block)
    %x{
      var result = [], size = self.length, part, o, i, j, jj;

      for (j = 0, jj = others.length; j < jj; j++) {
        o = others[j];
        if (o.$$is_array) {
          continue;
        }
        if (o.$$is_range || o.$$is_enumerator) {
          others[j] = o.$take(size);
          continue;
        }
        others[j] = #{(
          ::Opal.coerce_to?(`o`, ::Array, :to_ary) ||
          ::Opal.coerce_to!(`o`, ::Enumerator, :to_enum, :each)
        ).to_a};
      }

      for (i = 0; i < size; i++) {
        part = [self[i]];

        for (j = 0, jj = others.length; j < jj; j++) {
          o = others[j][i];

          if (o == null) {
            o = nil;
          }

          part[j + 1] = o;
        }

        result[i] = part;
      }

      if (block !== nil) {
        for (i = 0; i < size; i++) {
          Opal.yield1(block, result[i]);
        }

        return nil;
      }

      return result;
    }
  end

  def self.inherited(klass)
    %x{
      klass.$$prototype.$to_a = function() {
        return this.slice(0, this.length);
      }
    }
  end

  def instance_variables
    super.reject { |ivar| `/^@\d+$/.test(#{ivar})` || ivar == '@length' }
  end

  def pack(*args)
    ::Kernel.raise "To use Array#pack, you must first require 'corelib/array/pack'."
  end

  alias append push
  alias filter select
  alias filter! select!
  alias map collect
  alias map! collect!
  alias prepend unshift
  alias size length
  alias slice []
  alias to_s inspect

  ::Opal.pristine singleton_class, :allocate
  ::Opal.pristine self, :copy_instance_variables, :initialize_dup
end
