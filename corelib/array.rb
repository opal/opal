class Array
  include Enumerable

  # Mark all javascript arrays as being valid ruby arrays
  `def._isArray = true`

  def self.inherited(klass)
    replace = Class.new(Array::Wrapper)

    %x{
      klass._proto        = replace._proto;
      klass._proto._klass = klass;
      klass._alloc        = replace._alloc;
      klass.__parent      = #{Array::Wrapper};

      klass.$new   = replace.$new;
      klass["$[]"] = replace["$[]"];
    }
  end

  def self.[](*objects)
    objects
  end

  def initialize(*args)
    self.class.new(*args)
  end

  def self.new(size = nil, obj = nil, &block)
    if `arguments.length > 2`
      raise ArgumentError, "wrong number of arguments (#{`arguments.length`} for 0..2)"
    end

    if `arguments.length === 0`
      return []
    end

    if `arguments.length === 1`
      if Array === size
        return size.to_a
      elsif size.respond_to? :to_ary
        return size.to_ary
      end
    end

    size = Opal.coerce_to size, Integer, :to_int

    if `size < 0`
      raise ArgumentError, "negative array size"
    end

    %x{
      var result = [];

      if (block === nil) {
        for (var i = 0; i < size; i++) {
          result.push(obj);
        }
      }
      else {
        for (var i = 0, value; i < size; i++) {
          value = block(i);

          if (value === $breaker) {
            return $breaker.$v;
          }

          result[i] = value;
        }
      }

      return result;
    }
  end

  def self.try_convert(obj)
    return obj if Array === obj
    return obj.to_ary if obj.respond_to? :to_ary

    nil
  end

  def &(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to other, Array, :to_ary
    end

    %x{
      var result = [],
          seen   = {};

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (!seen[item]) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j];

            if (!seen[item2] && #{`item` == `item2`}) {
              seen[item] = true;
              result.push(item);
            }
          }
        }
      }

      return result;
    }
  end

  def *(other)
    return `self.join(#{other.to_str})` if other.respond_to? :to_str

    unless other.respond_to? :to_int
      raise TypeError, "no implicit conversion of #{other.class} into Integer"
    end

    other = Opal.coerce_to other, Integer, :to_int

    if `other < 0`
      raise ArgumentError, "negative argument"
    end

    %x{
      var result = [];

      for (var i = 0; i < other; i++) {
        result = result.concat(self);
      }

      return result;
    }
  end

  def +(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to other, Array, :to_ary
    end

    `self.concat(other)`
  end

  def -(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to other, Array, :to_ary
    end

    return [] if `self.length === 0`
    return clone if `other.length === 0`

    %x{
      var seen   = {},
          result = [];

      for (var i = 0, length = other.length; i < length; i++) {
        seen[other[i]] = true;
      }

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (!seen[item]) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def <<(object)
    `self.push(object);`

    self
  end

  def <=>(other)
    if Array === other
      other = other.to_a
    elsif other.respond_to? :to_ary
      other = other.to_ary
    else
      return
    end

    %x{
      if (#{hash} === #{other.hash}) {
        return 0;
      }

      if (self.length != other.length) {
        return (self.length > other.length) ? 1 : -1;
      }

      for (var i = 0, length = self.length; i < length; i++) {
        var tmp = #{`self[i]` <=> `other[i]`};

        if (tmp !== 0) {
          return tmp;
        }
      }

      return 0;
    }
  end

  def ==(other)
    return false unless Array === other

    other = other.to_a

    %x{
      if (self.length !== other.length) {
        return false;
      }

      for (var i = 0, length = self.length; i < length; i++) {
        var a = self[i],
            b = other[i];

        if (a._isArray && b._isArray && (a === self)) {
          continue;
        }

        if (!(#{`a` == `b`})) {
          return false;
        }
      }
    }

    true
  end

  def [](index, length = undefined)
    %x{
      var size = #{self}.length;

      if (typeof index !== 'number' && !index._isNumber) {
        if (index._isRange) {
          var exclude = index.exclude;
          length      = index.end;
          index       = index.begin;

          if (index > size) {
            return nil;
          }

          if (length < 0) {
            length += size;
          }

          if (!exclude) length += 1;
          return #{self}.slice(index, length);
        }
        else {
          #{ raise "bad arg for Array#[]" };
        }
      }

      if (index < 0) {
        index += size;
      }

      if (length !== undefined) {
        if (length < 0 || index > size || index < 0) {
          return nil;
        }

        return #{self}.slice(index, index + length);
      }
      else {
        if (index >= size || index < 0) {
          return nil;
        }

        return #{self}[index];
      }
    }
  end

  def []=(index, value, extra = undefined)
    %x{
      var size = #{self}.length;

      if (typeof index !== 'number' && !index._isNumber) {
        if (index._isRange) {
          var exclude = index.exclude;
          extra = value;
          value = index.end;
          index = index.begin;

          if (value < 0) {
            value += size;
          }

          if (!exclude) value += 1;

          value = value - index;
        }
        else {
          #{raise ArgumentError};
        }
      }

      if (index < 0) {
        index += size;
      }

      if (extra != null) {
        if (value < 0) {
          #{raise IndexError};
        }

        if (index > size) {
          for (var i = size; index > i; i++) {
            #{self}[i] = nil;
          }
        }

        #{self}.splice.apply(#{self}, [index, value].concat(extra));

        return extra;
      }

      if (index > size) {
        for (var i = size; i < index; i++) {
          #{self}[i] = nil;
        }
      }

      return #{self}[index] = value;
    }
  end

  def assoc(object)
    %x{
      for (var i = 0, length = #{self}.length, item; i < length; i++) {
        if (item = #{self}[i], item.length && #{`item[0]` == object}) {
          return item;
        }
      }

      return nil;
    }
  end

  def at(index)
    index = Opal.coerce_to index, Integer, :to_int

    %x{
      if (index < 0) {
        index += #{self}.length;
      }

      if (index < 0 || index >= #{self}.length) {
        return nil;
      }

      return #{self}[index];
    }
  end

  def cycle(n = nil, &block)
    return if `self.length === 0 || n === 0`
    return enum_for :cycle, n unless block

    if `n === nil`
      while true
        if `#{(value = each(&block))} !== self`
          return value
        end
      end
    else
      cycles = Opal.coerce_to n, Integer, :to_int

      unless Integer === cycles
        raise TypeError, "can't convert #{n.class} into Integer (#{n.class}#to_int gives #{cycles.class}"
      end

      while cycles > 0
        each(&block)

        cycles -= 1
      end
    end

    self
  end

  def clear
    `#{self}.splice(0, #{self}.length)`

    self
  end

  def clone
    `self.slice()`
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        var value = Opal.$yield1(block, self[i]);

        if (value === $breaker) {
          return $breaker.$v;
        }

        result.push(value);
      }

      return result;
    }
  end

  def collect!(&block)
    return enum_for :collect! unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        var value = Opal.$yield1(block, self[i]);

        if (value === $breaker) {
          return $breaker.$v;
        }

        self[i] = value;
      }
    }

    self
  end

  def compact
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item; i < length; i++) {
        if ((item = #{self}[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def compact!
    %x{
      var original = #{self}.length;

      for (var i = 0, length = #{self}.length; i < length; i++) {
        if (#{self}[i] === nil) {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }

      return #{self}.length === original ? nil : #{self};
    }
  end

  def concat(other)
    %x{
      for (var i = 0, length = other.length; i < length; i++) {
        #{self}.push(other[i]);
      }
    }

    self
  end

  def delete(object)
    %x{
      var original = #{self}.length;

      for (var i = 0, length = original; i < length; i++) {
        if (#{`#{self}[i]` == object}) {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }

      return #{self}.length === original ? nil : object;
    }
  end

  def delete_at(index)
    %x{
      if (index < 0) {
        index += #{self}.length;
      }

      if (index < 0 || index >= #{self}.length) {
        return nil;
      }

      var result = #{self}[index];

      #{self}.splice(index, 1);

      return result;
    }
  end

  def delete_if(&block)
    return enum_for :delete_if unless block_given?

    %x{
      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }
    }

    self
  end

  def drop(number)
    %x{
      if (number < 0) {
        #{raise ArgumentError}
      }

      return #{self}.slice(number);
    }
  end

  alias dup clone

  def each(&block)
    return enum_for :each unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        var value = $opal.$yield1(block, self[i]);

        if (value == $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def each_index(&block)
    return enum_for :each_index unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        var value = $opal.$yield1(block, i);

        if (value === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def empty?
    `self.length === 0`
  end

  def fetch(index, defaults = undefined, &block)
    %x{
      var original = index;

      if (index < 0) {
        index += #{self}.length;
      }

      if (index >= 0 && index < #{self}.length) {
        return #{self}[index];
      }

      if (block !== nil) {
        return block(original);
      }

      if (defaults != null) {
        return defaults;
      }

      #{ raise IndexError, "Array#fetch" };
    }
  end

  def fill(*args, &block)
    if block
      if `args.length > 2`
        raise ArgumentError, "wrong number of arguments (#{args.length} for 0..2)"
      end

      one, two = args
    else
      if `args.length == 0`
        raise ArgumentError, "wrong number of arguments (0 for 1..3)"
      elsif `args.length > 3`
        raise ArgumentError, "wrong number of arguments (#{args.length} for 1..3)"
      end

      obj, one, two = args
    end

    if Range === one
      raise TypeError, "length invalid with range" if two

      left   = Opal.coerce_to one.begin, Integer, :to_int
      `left += #@length` if `left < 0`
      raise RangeError, "#{one.inspect} out of range" if `left < 0`

      right  = Opal.coerce_to one.end, Integer, :to_int
      `right += #@length` if `right < 0`
      `right += 1` unless one.exclude_end?

      return self if `right <= left`
    elsif one
      left   = Opal.coerce_to one, Integer, :to_int
      `left += #@length` if `left < 0`
      left   = 0 if `left < 0`

      if two
        right = Opal.coerce_to two, Integer, :to_int

        return self if `right == 0`

        `right += left`
      else
        right = @length
      end
    else
      left  = 0
      right = @length
    end

    if `right > 2147483648`
      raise RangeError, "bignum too big to convert into `long'"
    elsif `right >= 536870910`
      raise ArgumentError, "argument too big"
    end

    if `left > #@length`
      %x{
        for (var i = #@length; i < right; i++) {
          self[i] = nil;
        }
      }
    end

    if `right > #@length`
      @length = right
    end

    if block
      %x{
        for (var length = #@length; left < right; left++) {
          var value = block(left);

          if (value === $breaker) {
            return $breaker.$v;
          }

          self[left] = value;
        }
      }
    else
      %x{
        for (var length = #@length; left < right; left++) {
          self[left] = #{obj};
        }
      }
    end

    self
  end

  def first(count = undefined)
    %x{
      if (count != null) {

        if (count < 0) {
          #{raise ArgumentError};
        }

        return #{self}.slice(0, count);
      }

      return #{self}.length === 0 ? nil : #{self}[0];
    }
  end

  def flatten(level = undefined)
    %x{
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (#{`item`.respond_to?(:to_ary)}) {
          item = #{`item`.to_ary};

          if (level == null) {
            result = result.concat(#{`item`.flatten});
          }
          else if (level === 0) {
            result.push(item);
          }
          else {
            result = result.concat(#{`item`.flatten(`level - 1`)});
          }
        }
        else {
          result.push(item);
        }
      }

      return result;
    }
  end

  def flatten!(level = undefined)
    %x{
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

  def hash
    `self._id || (self._id = Opal.uid())`
  end

  def include?(member)
    %x{
      for (var i = 0, length = #{self}.length; i < length; i++) {
        if (#{`#{self}[i]` == member}) {
          return true;
        }
      }

      return false;
    }
  end

  def index(object=undefined, &block)
    %x{
      if (object != null) {
        for (var i = 0, length = #{self}.length; i < length; i++) {
          if (#{`#{self}[i]` == object}) {
            return i;
          }
        }
      }
      else if (block !== nil) {
        for (var i = 0, length = #{self}.length, value; i < length; i++) {
          if ((value = block(#{self}[i])) === $breaker) {
            return $breaker.$v;
          }

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
      if (objects.length > 0) {
        if (index < 0) {
          index += #{self}.length + 1;

          if (index < 0) {
            #{ raise IndexError, "#{index} is out of bounds" };
          }
        }
        if (index > #{self}.length) {
          for (var i = #{self}.length; i < index; i++) {
            #{self}.push(nil);
          }
        }

        #{self}.splice.apply(#{self}, [index, 0].concat(objects));
      }
    }

    self
  end

  def inspect
    %x{
      var i, inspect, el, el_insp, length, object_id;

      inspect = [];
      object_id = #{object_id};
      length = #{self}.length;

      for (i = 0; i < length; i++) {
        el = #{self[`i`]};

        // Check object_id to ensure it's not the same array get into an infinite loop
        el_insp = #{`el`.object_id} === object_id ? '[...]' : #{`el`.inspect};

        inspect.push(el_insp);
      }
      return '[' + inspect.join(', ') + ']';
    }
  end

  def join(sep = '')
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length; i < length; i++) {
        result.push(#{`#{self}[i]`.to_s});
      }

      return result.join(sep);
    }
  end

  def keep_if(&block)
    return enum_for :keep_if unless block_given?

    %x{
      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }
    }

    self
  end

  def last(count = undefined)
    %x{
      var length = #{self}.length;

      if (count === nil || typeof(count) == 'string') {
        #{ raise TypeError, "no implicit conversion to integer" };
      }

      if (typeof(count) == 'object') {
        if (#{count.respond_to? :to_int}) {
          count = count['$to_int']();
        }
        else {
          #{ raise TypeError, "no implicit conversion to integer" };
        }
      }

      if (count == null) {
        return length === 0 ? nil : #{self}[length - 1];
      }
      else if (count < 0) {
        #{ raise ArgumentError, "negative count given" };
      }

      if (count > length) {
        count = length;
      }

      return #{self}.slice(length - count, length);
    }
  end

  def length
    `self.length`
  end

  alias map collect

  alias map! collect!

  def pop(count = undefined)
    %x{
      var length = #{self}.length;

      if (count == null) {
        return length === 0 ? nil : #{self}.pop();
      }

      if (count < 0) {
        #{ raise ArgumentError, "negative count given" };
      }

      return count > length ? #{self}.splice(0, #{self}.length) : #{self}.splice(length - count, length);
    }
  end

  def push(*objects)
    %x{
      for (var i = 0, length = objects.length; i < length; i++) {
        #{self}.push(objects[i]);
      }
    }

    self
  end

  def rassoc(object)
    %x{
      for (var i = 0, length = #{self}.length, item; i < length; i++) {
        item = #{self}[i];

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
    return enum_for :reject unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          result.push(#{self}[i]);
        }
      }
      return result;
    }
  end

  def reject!(&block)
    return enum_for :reject! unless block_given?

    %x{
      var original = #{self}.length;
      #{ delete_if &block };
      return #{self}.length === original ? nil : #{self};
    }
  end

  def replace(other)
    %x{
      self.splice(0, self.length);
      self.push.apply(self, other);
    }

    self
  end

  def reverse
    `#{self}.slice(0).reverse()`
  end

  def reverse!
    `#{self}.reverse()`
  end

  def reverse_each(&block)
    return enum_for :reverse_each unless block_given?

    reverse.each &block
    self
  end

  def rindex(object = undefined, &block)
    %x{
      if (object != null) {
        for (var i = #{self}.length - 1; i >= 0; i--) {
          if (#{`#{self}[i]` == `object`}) {
            return i;
          }
        }
      }
      else if (block !== nil) {
        for (var i = #{self}.length - 1, value; i >= 0; i--) {
          if ((value = block(#{self}[i])) === $breaker) {
            return $breaker.$v;
          }

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

  def sample(n = nil)
    return nil if !n && empty?
    return []  if  n && empty?

    if n
      (1 .. n).map {
        self[rand(length)]
      }
    else
      self[rand(length)]
    end
  end

  def select(&block)
    return enum_for :select unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item, value; i < length; i++) {
        item = #{self}[i];

        if ((value = block(item)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def select!(&block)
    return enum_for :select! unless block_given?

    %x{
      var original = #{self}.length;
      #{ keep_if &block };
      return #{self}.length === original ? nil : #{self};
    }
  end

  def shift(count = undefined)
    %x{
      if (#{self}.length === 0) {
        return nil;
      }

      return count == null ? #{self}.shift() : #{self}.splice(0, count)
    }
  end

  alias size length

  def shuffle
    clone.shuffle!
  end

  def shuffle!
    %x{
      for (var i = self.length - 1; i > 0; i--) {
        var tmp = self[i],
            j   = Math.floor(Math.random() * (i + 1));

        self[i] = self[j];
        self[j] = tmp;
      }
    }

    self
  end

  alias slice []

  def slice!(index, length = undefined)
    %x{
      if (index < 0) {
        index += self.length;
      }

      if (length != null) {
        return self.splice(index, length);
      }

      if (index < 0 || index >= self.length) {
        return nil;
      }

      return self.splice(index, 1)[0];
    }
  end

  def sort(&block)
    return self unless `self.length > 1`

    %x{
      if (!#{block_given?}) {
        block = function(a, b) {
          return #{`a` <=> `b`};
        };
      }

      try {
        return self.slice().sort(function(x, y) {
          var ret = block(x, y);

          if (ret === $breaker) {
            throw $breaker;
          }
          else if (ret === nil) {
            #{raise ArgumentError, "comparison of #{`x`.inspect} with #{`y`.inspect} failed"};
          }

          return #{`ret` > 0} ? 1 : (#{`ret` < 0} ? -1 : 0);
        });
      }
      catch (e) {
        if (e === $breaker) {
          return $breaker.$v;
        }
        else {
          throw e;
        }
      }
    }
  end

  def sort!(&block)
    %x{
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

  def take(count)
    %x{
      if (count < 0) {
        #{raise ArgumentError};
      }

      return #{self}.slice(0, count);
    }
  end

  def take_while(&block)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item, value; i < length; i++) {
        item = #{self}[i];

        if ((value = block(item)) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          return result;
        }

        result.push(item);
      }

      return result;
    }
  end

  def to_a
    self
  end

  alias to_ary to_a

  def to_n
    %x{
      var result = [], obj

      for (var i = 0, len = #{self}.length; i < len; i++) {
        obj = #{self}[i];

        if (#{`obj`.respond_to? :to_n}) {
          result.push(#{`obj`.to_n});
        }
        else {
          result.push(obj);
        }
      }

      return result;
    }
  end

  alias to_s inspect

  def transpose
    return [] if empty?

    result = []
    max    = nil

    each {|row|
      if Array === row
        row = row.to_a
      else
        row = Opal.coerce_to row, Array, :to_ary
      end

      max ||= `row.length`

      if `row.length` != max
        raise IndexError, "element size differs (#{`row.length`} should be #{max}"
      end

      `row.length`.times {|i|
        entry = (result[i] ||= [])
        entry << row.at(i)
      }
    }

    result
  end

  def uniq
    %x{
      var result = [],
          seen   = {};
   
      for (var i = 0, length = #{self}.length, item, hash; i < length; i++) {
        item = #{self}[i];
        hash = item;
   
        if (!seen[hash]) {
          seen[hash] = true;
   
          result.push(item);
        }
      }
   
      return result;
    }
  end

  def uniq!
    %x{
      var original = #{self}.length,
          seen     = {};

      for (var i = 0, length = original, item, hash; i < length; i++) {
        item = #{self}[i];
        hash = item;

        if (!seen[hash]) {
          seen[hash] = true;
        }
        else {
          #{self}.splice(i, 1);

          length--;
          i--;
        }
      }

      return #{self}.length === original ? nil : #{self};
    }
  end

  def unshift(*objects)
    %x{
      for (var i = objects.length - 1; i >= 0; i--) {
        #{self}.unshift(objects[i]);
      }

      return #{self};
    }
  end

  def zip(*others, &block)
    %x{
      var result = [], size = #{self}.length, part, o;

      for (var i = 0; i < size; i++) {
        part = [#{self}[i]];

        for (var j = 0, jj = others.length; j < jj; j++) {
          o = others[j][i];

          if (o == null) {
            o = nil;
          }

          part[j + 1] = o;
        }

        result[i] = part;
      }

      if (block !== nil) {
        for (var i = 0; i < size; i++) {
          block(result[i]);
        }

        return nil;
      }

      return result;
    }
  end
end

class Array::Wrapper < BasicObject
  def self.new(*args, &block)
    obj = allocate
    obj.initialize(*args, &block)
    obj
  end

  def self.[](*objects)
    obj = allocate
    `obj.literal = objects`
    obj
  end

  def initialize(*args, &block)
    @literal = Array.new(*args, &block)
  end

  def method_missing(*args, &block)
    result = @literal.__send__(*args, &block)

    if `result === #@literal`
      self
    elsif `result._isArray != null`
      result
    else
      result
    end
  end

  def respond_to?(name, *)
    super || @literal.respond_to?(name)
  end

  def is_a?(klass)
    `$opal.is_a(self, klass)`
  end

  alias kind_of? is_a?

  def instance_of?(klass)
    `self._klass === klass`
  end

  alias send __send__

  def class
    `self._klass`
  end

  def clone
    self.class[*@literal]
  end

  alias dup clone

  def to_a
    @literal
  end

  def to_ary
    self
  end

  # wrapped results
  def *(other)
    %x{
      var result = #{@literal * other};

      if (result._isArray) {
        return #{self.class[*`result`]}
      }
      else {
        return result;
      }
    }
  end

  def [](index, length = undefined)
    %x{
      var result = #{@literal.slice(index, length)};

      if (result._isArray && (index._isRange || length !== undefined)) {
        return #{self.class[*`result`]}
      }
      else {
        return result;
      }
    }
  end

  alias slice []

  def uniq
    self.class[*@literal.uniq]
  end
end
