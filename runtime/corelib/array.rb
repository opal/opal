class Array
  include Enumerable

  def self.[](*objects)
    %x{
      var result = #{allocate};

      result.splice.apply(result, [0, 0].concat(objects));

      return result;
    }
  end

  def self.allocate
    %x{
      var array    = [];
          array.$k = self;

      return array;
    }
  end

  def self.new(*a)
    `[]`
  end

  def &(other)
    %x{
      var result = [],
          seen   = {};

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i],
            hash = item;

        if (!seen[hash]) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j],
                hash2 = item2;

            if ((hash === hash2) && !seen[hash]) {
              seen[hash] = true;

              result.push(item);
            }
          }
        }
      }

      return result;
    }
  end

  def *(other)
    %x{
      if (typeof(othe) === 'string') {
        return self.join(other);
      }

      for (var i = 0, result = [], length = self.length; i < length; i++) {
        result = result.concat(self);
      }

      return result;
    }
  end

  def +(other)
    `self.slice(0).concat(other.slice(0))`
  end

  def <<(object)
    `self.push(object);`

    self
  end

  def <=>(other)
    %x{
      if (#{self.hash} === #{other.hash}) {
        return 0;
      }

      if (self.length != other.length) {
        return (self.length > other.length) ? 1 : -1;
      }

      for (var i = 0, length = self.length, tmp; i < length; i++) {
        if ((tmp = #{`self[i]` <=> `other[i]`}) !== 0) {
          return tmp;
        }
      }

      return 0;
    }
  end

  def ==(other)
    %x{
      if (self.length !== other.length) {
        return false;
      }

      for (var i = 0, length = self.length; i < length; i++) {
        if (!#{`self[i]` == `other[i]`}) {
          return false;
        }
      }

      return true;
    }
  end

  # TODO: does not yet work with ranges
  def [](index, length = undefined)
    %x{
      var size = self.length;

      if (index < 0) {
        index += size;
      }

      if (length !== undefined) {
        if (length < 0 || index > size || index < 0) {
          return nil;
        }

        return self.slice(index, index + length);
      }
      else {
        if (index >= size || index < 0) {
          return nil;
        }

        return self[index];
      }
    }
  end

  # TODO: need to expand functionality
  def []=(index, value)
    %x{
      var size = self.length;

      if (index < 0) {
        index += size;
      }

      return self[index] = value;
    }
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
      if (index < 0) {
        index += self.length;
      }

      if (index < 0 || index >= self.length) {
        return nil;
      }

      return self[index];
    }
  end

  def clear
    `self.splice(0);`

    self
  end

  def clone
    `self.slice(0)`
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = self.length, value; i < length; i++) {
        if ((value = $yielder.call($context, null, self[i])) === $breaker) {
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
      for (var i = 0, length = self.length, val; i < length; i++) {
        if ((val = $yielder.call($context, null, self[i])) === $breaker) {
          return $breaker.$v;
        }

        self[i] = val;
      }
    }

    self
  end

  def compact
    %x{
      var result = [];

      for (var i = 0, length = self.length, item; i < length; i++) {
        if ((item = self[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def compact!
    %x{
      var original = self.length;

      for (var i = 0, length = self.length; i < length; i++) {
        if (self[i] === nil) {
          self.splice(i, 1);

          length--;
          i--;
        }
      }

      return self.length === original ? nil : self;
    }
  end

  def concat(other)
    %x{
      for (var i = 0, length = other.length; i < length; i++) {
        self.push(other[i]);
      }
    }

    self
  end

  def count(object = undefined)
    %x{
      if (object === undefined) {
        return self.length;
      }

      var result = 0;

      for (var i = 0, length = self.length; i < length; i++) {
        if (#{`self[i]` == object}) {
          result++;
        }
      }

      return result;
    }
  end

  def delete(object)
    %x{
      var original = self.length;

      for (var i = 0, length = original; i < length; i++) {
        if (#{`self[i]` == object}) {
          self.splice(i, 1);

          length--;
          i--;
        }
      }

      return self.length === original ? nil : object;
    }
  end

  def delete_at(index)
    %x{
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
    return enum_for :delete_if unless block_given?

    %x{
      for (var i = 0, length = self.length, value; i < length; i++) {
        if ((value = $yielder.call($context, null, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          self.splice(i, 1);

          length--;
          i--;
        }
      }
    }

    self
  end

  def drop(number)
    `number > self.length ? [] : self.slice(number)`
  end

  def drop_while(&block)
    return enum_for :drop_while unless block_given?

    %x{
      for (var i = 0, length = self.length, value; i < length; i++) {
        if ((value = $yielder.call($context, null, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          return self.slice(i);
        }
      }

      return [];
    }
  end

  def each(&block)
    return enum_for :each unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        if ($yielder.call($context, null, self[i]) === $breaker) {
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
        if ($yielder.call($context, null, i) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        if ($yielder.call($context, null, self[i], i) === $breaker) {
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
        index += self.length;
      }

      if (index >= 0 && index < self.length) {
        return self[index];
      }

      if (defaults !== undefined) {
        return defaults;
      }

      if (block !== nil) {
        return $yielder.call($context, null, original);
      }

      raise(RubyIndexError, 'Array#fetch');
    }
  end

  def first(count = undefined)
    %x{
      if (count !== undefined) {
        return self.slice(0, count);
      }

      return self.length === 0 ? nil : self[0];
    }
  end

  def flatten(level = undefined)
    %x{
      var result = [];

      for (var i = 0, length = self.length, item; i < length; i++) {
        item = self[i];

        if (item.$f & T_ARRAY) {
          if (level === undefined) {
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
      var flattenable = false;

      for (var i = 0, length = self.length; i < length; i++) {
        if (self[i].$f & T_ARRAY) {
          flattenable = true;

          break;
        }
      }

      return flattenable ? #{replace flatten level} : nil;
    }
  end

  def grep(pattern)
    %x{
      var result = [];

      for (var i = 0, length = self.length, item; i < length; i++) {
        item = self[i];

        if (#{pattern === `item`}) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def hash
    `self.$id || (self.$id = unique_id++)`
  end

  def include?(member)
    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        if (#{`self[i]` == member}) {
          return true;
        }
      }

      return false;
    }
  end

  def index(object = undefined, &block)
    return enum_for :index unless block_given? && object == undefined

    %x{
      if (block !== nil) {
        for (var i = 0, length = self.length, value; i < length; i++) {
          if ((value = $yielder.call($context, null, self[i])) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = 0, length = self.length; i < length; i++) {
          if (#{`self[i]` == object}) {
            return i;
          }
        }
      }

      return nil
    }
  end

  def inject(initial = undefined, &block)
    return enum_for :inject unless block_given?

    %x{
      var result, i;

      if (initial === undefined) {
        result = self[0];
        i      = 1;
      }
      else {
        result = initial;
        i      = 0;
      }

      for (var length = self.length, value; i < length; i++) {
        if ((value = $yielder.call($context, null, result, self[i])) === $breaker) {
          return $breaker.$v;
        }

        result = value;
      }

      return result;
    }
  end

  def insert(index, *objects)
    %x{
      if (objects.length > 0) {
        if (index < 0) {
          index += self.length + 1;

          if (index < 0) {
            raise(RubyIndexError, index + ' is out of bounds');
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

  def inspect
    %x{
      var inspect = [];

      for (var i = 0, length = self.length; i < length; i++) {
        inspect.push(#{`self[i]`.inspect});
      }

      return '[' + inspect.join(', ') + ']';
    }
  end

  def join(sep = '')
    %x{
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        result.push(#{`self[i]`.to_s});
      }

      return result.join(sep);
    }
  end

  def keep_if(&block)
    return enum_for :keep_if unless block_given?
    %x{
      for (var i = 0, length = self.length, value; i < length; i++) {
        if ((value = $yielder.call($context, null, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          self.splice(i, 1);

          length--;
          i--;
        }
      }
    }

    self
  end

  def last(count = undefined)
    %x{
      var length = self.length;

      if (count === undefined) {
        return length === 0 ? nil : self[length - 1];
      }
      else if (count < 0) {
        raise(RubyArgError, 'negative count given');
      }

      if (count > length) {
        count = length;
      }

      return self.slice(length - count, length);
    }
  end

  def length
    `self.length`
  end

  alias_method :map, :collect

  alias_method :map!, :collect!

  def pop(count = undefined)
    %x{
      var length = self.length;

      if (count === undefined) {
        return length === 0 ? nil : self.pop();
      }

      if (count < 0) {
        raise(RubyArgError, 'negative count given');
      }

      return count > length ? self.splice(0) : self.splice(length - count, length);
    }
  end

  def push(*objects)
    %x{
      for (var i = 0, length = objects.length; i < length; i++) {
        self.push(objects[i]);
      }
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
    return enum_for :reject unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = self.length, value; i < length; i++) {
        if ((value = $yielder.call($context, null, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          result.push(self[i]);
        }
      }
      return result;
    }
  end

  def reject!(&block)
    return enum_for :reject! unless block_given?

    %x{
      var original = self.length;

      for (var i = 0, length = self.length, value; i < length; i++) {
        if ((value = $yielder.call($context, null, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          self.splice(i, 1);

          length--;
          i--;
        }
      }

      return original === self.length ? nil : self;
    }
  end

  def replace(other)
    clear
    concat other
  end

  def reverse
    `self.reverse()`
  end

  def reverse!
    replace(reverse)
  end

  def reverse_each(&block)
    return enum_for :reverse_each unless block_given?

    reverse.each &block

    self
  end

  def rindex(object = undefined, &block)
    return enum_for :rindex unless block_given? && object == undefined

    %x{
      if (block !== nil) {
        for (var i = self.length - 1, value; i >= 0; i--) {
          if ((value = $yielder.call($context, null, self[i])) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = self.length - 1; i >= 0; i--) {
          if (#{`self[i]` == `object`}) {
            return i;
          }
        }
      }

      return nil;
    }
  end

  def select(&block)
    return enum_for :select unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = self.length, item, value; i < length; i++) {
        item = self[i];

        if ((value = $yielder.call($context, null, item)) === $breaker) {
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
      var original = self.length;

      for (var i = 0, length = original, item, value; i < length; i++) {
        item = self[i];

        if ((value = $yielder.call($context, null, item)) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          self.splice(i, 1);

          length--;
          i--;
        }
      }

      return self.length === original ? nil : self;
    }
  end

  def shift(count = undefined)
    `count === undefined ? self.shift() : self.splice(0, count)`
  end

  alias_method :size, :length

  alias_method :slice, :[]

  def slice!(index, length = undefined)
    %x{
      if (index < 0) {
        index += self.length;
      }

      if (index < 0 || index >= self.length) {
        return nil;
      }

      if (length !== undefined) {
        return self.splice(index, index + length);
      }

      return self.splice(index, 1)[0];
    }
  end

  def take(count)
    `self.slice(0, count)`
  end

  def take_while(&block)
    return enum_for :take_while unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = self.length, item, value; i < length; i++) {
        item = self[i];

        if ((value = $yielder.call($context, null, item)) === $breaker) {
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

  alias_method :to_ary, :to_a

  def to_native
    map { |obj| Opal.object?(obj) ? obj.to_native : obj }
  end

  alias_method :to_s, :inspect

  def uniq
    %x{
      var result = [],
          seen   = {};

      for (var i = 0, length = self.length, item, hash; i < length; i++) {
        item = self[i];
        hash = #{item.hash};

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
      var original = self.length,
          seen     = {};

      for (var i = 0, length = original, item, hash; i < length; i++) {
        item = self[i];
        hash = #{item.hash};

        if (!seen[hash]) {
          seen[hash] = true;
        }
        else {
          self.splice(i, 1);

          length--;
          i--;
        }
      }

      return self.length === original ? nil : self;
    }
  end

  def unshift(*objects)
    %x{
      for (var i = 0, length = objects.length; i < length; i++) {
        self.unshift(objects[i]);
      }

      return self;
    }
  end
end
