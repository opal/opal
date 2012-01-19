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
      var array         = [];
          array.o$klass = this;

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

      for (var i = 0, length = this.length; i < length; i++) {
        var item = this[i],
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
      if (typeof(other) === 'string') {
        return this.join(other);
      }

      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result = result.concat(this);
      }

      return result;
    }
  end

  def +(other)
    `this.slice(0).concat(other.slice(0))`
  end

  def <<(object)
    `this.push(object);`

    self
  end

  def <=>(other)
    %x{
      if (#{self.hash} === #{other.hash}) {
        return 0;
      }

      if (this.length != other.length) {
        return (this.length > other.length) ? 1 : -1;
      }

      for (var i = 0, length = this.length, tmp; i < length; i++) {
        if ((tmp = #{`this[i]` <=> `other[i]`}) !== 0) {
          return tmp;
        }
      }

      return 0;
    }
  end

  def ==(other)
    %x{
      if (this.length !== other.length) {
        return false;
      }

      for (var i = 0, length = this.length; i < length; i++) {
        if (!#{`this[i]` == `other[i]`}) {
          return false;
        }
      }

      return true;
    }
  end

  # TODO: does not yet work with ranges
  def [](index, length = undefined)
    %x{
      var size = this.length;

      if (typeof index !== 'number') {
        if (index.o$flags & T_RANGE) {
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
          return this.slice(index, length);
        }
        else {
          throw RubyException.$new('bad arg for Array#[]');
        }
      }

      if (index < 0) {
        index += size;
      }

      if (length !== undefined) {
        if (length < 0 || index > size || index < 0) {
          return nil;
        }

        return this.slice(index, index + length);
      }
      else {
        if (index >= size || index < 0) {
          return nil;
        }

        return this[index];
      }
    }
  end

  # TODO: need to expand functionality
  def []=(index, value)
    %x{
      var size = this.length;

      if (index < 0) {
        index += size;
      }

      return this[index] = value;
    }
  end

  def assoc(object)
    %x{
      for (var i = 0, length = this.length, item; i < length; i++) {
        if (item = this[i], item.length && #{`item[0]` == object}) {
          return item;
        }
      }

      return nil;
    }
  end

  def at(index)
    %x{
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      return this[index];
    }
  end

  def clear
    `this.splice(0);`

    self
  end

  def clone
    `this.slice(0)`
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = $yield.call($context, this[i])) === $breaker) {
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
      for (var i = 0, length = this.length, val; i < length; i++) {
        if ((val = $yield.call($context, this[i])) === $breaker) {
          return $breaker.$v;
        }

        this[i] = val;
      }
    }

    self
  end

  def compact
    %x{
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        if ((item = this[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def compact!
    %x{
      var original = this.length;

      for (var i = 0, length = this.length; i < length; i++) {
        if (this[i] === nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : this;
    }
  end

  def concat(other)
    %x{
      for (var i = 0, length = other.length; i < length; i++) {
        this.push(other[i]);
      }
    }

    self
  end

  def count(object = undefined)
    %x{
      if (object === undefined) {
        return this.length;
      }

      var result = 0;

      for (var i = 0, length = this.length; i < length; i++) {
        if (#{`this[i]` == object}) {
          result++;
        }
      }

      return result;
    }
  end

  def delete(object)
    %x{
      var original = this.length;

      for (var i = 0, length = original; i < length; i++) {
        if (#{`this[i]` == object}) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : object;
    }
  end

  def delete_at(index)
    %x{
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      var result = this[index];

      this.splice(index, 1);

      return result;
    }
  end

  def delete_if(&block)
    return enum_for :delete_if unless block_given?

    %x{
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = $yield.call($context, this[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }
    }

    self
  end

  def drop(number)
    `this.slice(number)`
  end

  def drop_while(&block)
    return enum_for :drop_while unless block_given?

    %x{
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = $yield.call($context, this[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          return this.slice(i);
        }
      }

      return [];
    }
  end

  def each(&block)
    return enum_for :each unless block_given?

    %x{
      for (var i = 0, length = this.length; i < length; i++) {
        if ($yield.call($context, this[i]) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def each_index(&block)
    return enum_for :each_index unless block_given?

    %x{
      for (var i = 0, length = this.length; i < length; i++) {
        if ($yield.call($context, i) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block_given?

    %x{
      for (var i = 0, length = this.length; i < length; i++) {
        if ($yield.call($context, this[i], i) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def empty?
    `this.length === 0`
  end

  def fetch(index, defaults = undefined, &block)
    %x{
      var original = index;

      if (index < 0) {
        index += this.length;
      }

      if (index >= 0 && index < this.length) {
        return this[index];
      }

      if (defaults !== undefined) {
        return defaults;
      }

      if (block !== nil) {
        return $yield.call($context, original);
      }

      throw RubyIndexError.$new('Array#fetch');
    }
  end

  def first(count = undefined)
    %x{
      if (count !== undefined) {
        return this.slice(0, count);
      }

      return this.length === 0 ? nil : this[0];
    }
  end

  def flatten(level = undefined)
    %x{
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (item.o$flags & T_ARRAY) {
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
      var size = this.length;
      #{replace flatten level};

      return size === this.length ? nil : this;
    }
  end

  def grep(pattern)
    %x{
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (#{pattern === `item`}) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def hash
    `this.o$id || (this.o$id = unique_id++)`
  end

  def include?(member)
    %x{
      for (var i = 0, length = this.length; i < length; i++) {
        if (#{`this[i]` == member}) {
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
        for (var i = 0, length = this.length, value; i < length; i++) {
          if ((value = $yield.call($context, this[i])) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = 0, length = this.length; i < length; i++) {
          if (#{`this[i]` == object}) {
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
        result = this[0];
        i      = 1;
      }
      else {
        result = initial;
        i      = 0;
      }

      for (var length = this.length, value; i < length; i++) {
        if ((value = $yield.call($context, result, this[i])) === $breaker) {
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
          index += this.length + 1;

          if (index < 0) {
            throw RubyIndexError.$new(index + ' is out of bounds');
          }
        }
        if (index > this.length) {
          for (var i = this.length; i < index; i++) {
            this.push(nil);
          }
        }

        this.splice.apply(this, [index, 0].concat(objects));
      }
    }

    self
  end

  def inspect
    %x{
      var inspect = [];

      for (var i = 0, length = this.length; i < length; i++) {
        inspect.push(#{`this[i]`.inspect});
      }

      return '[' + inspect.join(', ') + ']';
    }
  end

  def join(sep = '')
    %x{
      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result.push(#{`this[i]`.to_s});
      }

      return result.join(sep);
    }
  end

  def keep_if(&block)
    return enum_for :keep_if unless block_given?
    %x{
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = $yield.call($context, this[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }
    }

    self
  end

  def last(count = undefined)
    %x{
      var length = this.length;

      if (count === undefined) {
        return length === 0 ? nil : this[length - 1];
      }
      else if (count < 0) {
        throw RubyArgError.$new('negative count given');
      }

      if (count > length) {
        count = length;
      }

      return this.slice(length - count, length);
    }
  end

  def length
    `this.length`
  end

  alias map collect

  alias map! collect!

  def pop(count = undefined)
    %x{
      var length = this.length;

      if (count === undefined) {
        return length === 0 ? nil : this.pop();
      }

      if (count < 0) {
        throw RubyArgError.$new('negative count given');
      }

      return count > length ? this.splice(0) : this.splice(length - count, length);
    }
  end

  def push(*objects)
    %x{
      for (var i = 0, length = objects.length; i < length; i++) {
        this.push(objects[i]);
      }
    }

    self
  end

  def rassoc(object)
    %x{
      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

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

      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = $yield.call($context, this[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          result.push(this[i]);
        }
      }
      return result;
    }
  end

  def reject!(&block)
    return enum_for :reject! unless block_given?

    %x{
      var original = this.length;

      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = $yield.call($context, this[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return original === this.length ? nil : this;
    }
  end

  def replace(other)
    %x{
      this.splice(0);
      this.push.apply(this, other);
      return this;
    }
  end

  def reverse
    `this.reverse()`
  end

  def reverse!
    %x{
      this.splice(0);
      this.push.apply(this, #{reverse});
      return this;
    }
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
        for (var i = this.length - 1, value; i >= 0; i--) {
          if ((value = $yield.call($context, this[i])) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = this.length - 1; i >= 0; i--) {
          if (#{`this[i]` == `object`}) {
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

      for (var i = 0, length = this.length, item, value; i < length; i++) {
        item = this[i];

        if ((value = $yield.call($context, item)) === $breaker) {
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
      var original = this.length;

      for (var i = 0, length = original, item, value; i < length; i++) {
        item = this[i];

        if ((value = $yield.call($context, item)) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : this;
    }
  end

  def shift(count = undefined)
    `count === undefined ? this.shift() : this.splice(0, count)`
  end

  alias size length

  alias slice :[]

  def slice!(index, length = undefined)
    %x{
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      if (length !== undefined) {
        return this.splice(index, index + length);
      }

      return this.splice(index, 1)[0];
    }
  end

  def take(count)
    `this.slice(0, count)`
  end

  def take_while(&block)
    return enum_for :take_while unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = this.length, item, value; i < length; i++) {
        item = this[i];

        if ((value = $yield.call($context, item)) === $breaker) {
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

  alias to_s inspect

  def uniq
    %x{
      var result = [],
          seen   = {};

      for (var i = 0, length = this.length, item, hash; i < length; i++) {
        item = this[i];
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
      var original = this.length,
          seen     = {};

      for (var i = 0, length = original, item, hash; i < length; i++) {
        item = this[i];
        hash = #{item.hash};

        if (!seen[hash]) {
          seen[hash] = true;
        }
        else {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : this;
    }
  end

  def unshift(*objects)
    %x{
      for (var i = 0, length = objects.length; i < length; i++) {
        this.unshift(objects[i]);
      }

      return this;
    }
  end

  def zip(*others)
    %x{
      var result = [], size = this.length, part, o;

      for (var i = 0; i < size; i++) {
        part = [this[i]];

        for (var j = 0, jj = others.length; j < jj; j++) {
          o = others[j][i];

          if (o === undefined) {
            o = nil;
          }

          part[j + 1] = o;
        }

        result[i] = part;
      }

      return result;
    }
  end
end
