class Array
  include Enumerable

  def self.[](*objects)
    `
      var result = #{allocate};
      result.splice.apply(result, [0, 0].concat(objects));
      return result;
    `
  end

  def self.allocate
    `
      var array = [];
      array.$k = self;
      return array;
    `
  end

  def self.new(*a)
    `[]`
  end

  def &(other)
    `
      var result = [], seen = {};

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i], hash = item;
        if (!seen[hash]) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j], hash2 = item2;

            if ((hash === hash2) && !seen[hash]) {
              seen[hash] = true;
              result.push(item);
            }
          }
        } 
      }
      return result;
    `
  end

  def *(other)
    `
      if (typeof other === 'string') return self.join(other);

      for (var i = 0, result = [], length = self.length; i < length; i++) {
        result = result.concat(self);
      }
      return result;
    `
  end

  def +(other)
    `self.slice(0).concat(other.slice(0))`
  end

  def <<(object)
    `
      self.push(object);
      return self;
    `
  end

  def <=>(other)
    `
      if (#{self.hash} === #{other.hash}) return 0;

      for (var i = 0, length = self.length, tmp; i < length; i++) {
        if (tmp = #{`self[i]` <=> `other[i]`} !== 0) return tmp;
      }

      return self.length === other.length ? 0 : (self.length > other.length ? 1 : -1);
    `
  end 

  def ==(other)
    `
      if (self.length !== other.length) return false;

      for (var i = 0, length = self.length; i < length; i++) {
        if (!#{`self[i]` == `other[i]`}) return false;
      }
      return true;
    `
  end

  # TODO: does not yet work with ranges
  def [](index, length = undefined)
    `
      var size = self.length;
      if (index < 0) index += size;

      if (length !== undefined) {
        if (length < 0 || index > size || index < 0) return nil;
        return self.slice(index, index + length);
      }
      else {
        if (index >= size || index < 0) return nil;
        return self[index];
      }
    `
  end

  # TODO: need to expand functionality
  def []=(index, value)
    `
      var size = self.length;
      if (index < 0) index += size;
      return self[index] = value;
    `
  end

  def assoc(object)
    `
      for (var i = 0, length = self.length, item; i < length; i++) {
        if (item = self[i], item.length && #{`item[0]` == object})
          return item;
      }
      return nil;
    `
  end

  def at(index)
    `
      if (index < 0) index += self.length;
      if (index < 0 || index >= self.length) return nil;
      return self[index];
    `
  end

  def clear
    `
      self.splice(0);
      return self;
    `
  end

  def clone
    `self.slice(0)`
  end

  def collect(&block)
    return enum_for :collect unless block_given?
    `
      var result = [], val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $yielder.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        result[i] = val;
      }
      return result;
    `
  end

  def collect!(&block)
    return enum_for :collect! unless block_given?
    `
      for (var i = 0, length = self.length, val; i < length; i++) {
        if ((val = $yielder.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        self[i] = val;
      }
      return self;
    `
  end

  def compact
    `
      var result = [], item;
      for (var i = 0, length = self.length; i < length; i++) {
        if ((item = self[i]) !== nil) result.push(item); 
      }
      return result;
    `
  end

  def compact!
    `
      var size = self.length;
      for (var i = 0, length = self.length; i < length; i++) {
        if (self[i] === nil) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self.length === size ? nil : self;
    `
  end

  def concat(other)
    `
      for (var i = 0, length = other.length; i < length; i++) {
        self.push(other[i]);
      }
      return self;
    `
  end

  def count(object = undefined)
    `
      if (object === undefined) return self.length;
      for (var i = 0, length = self.length, result = 0; i < length; i++) {
        if (#{`self[i]` == object}) result++;
      }
      return result;
    `
  end

  def delete(object)
    `
      var size = self.length;
      for (var i = 0, length = size; i < length; i++) {
        if (#{`self[i]` == object}) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self.length === size ? nil : object;
    `
  end

  def delete_at(index)
    `
      if (index < 0) index += self.length;
      if (index < 0 || index >= self.length) return nil;

      var result = self[index];
      self.splice(index, 1);
      return result;
    `
  end

  def delete_if(&block)
    return enum_for :delete_if unless block_given?
    `
      for (var i = 0, length = self.length, val; i < length; i++) {
        if ((val = $yielder.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        if (val !== false && val !== nil) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self;
    `
  end

  def drop(number)
    `number > self.length ? [] : self.slice(number)`
  end

  def drop_while(&block)
    return enum_for :drop_while unless block_given?
    `
      for (var i = 0, length = self.length, val; i < length; i++) {
        if ((val = $yielder.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        if (val === false || val === nil) return self.slice(i);
      }
      return [];
    `
  end

  def each(&block)
    return enum_for :each unless block_given?
    `
      for (var i = 0, length = self.length; i < length; i++) {
        if ($yielder.call($context, null, self[i]) === $breaker) 
          return $breaker.$v;
      }
      return self;
    `
  end

  def each_index(&block)
    return enum_for :each_index unless block_given?
    `
      for (var i = 0, length = self.length; i < length; i++) {
        if ($yielder.call($context, null, i) === $breaker) 
          return $breaker.$v;
      }
      return self;
    `
  end

  def each_with_index(&block)
    return enum_for :each_with_index unless block_given?
    `
      for (var i = 0, length = self.length; i < length; i++) {
        if ($yielder.call($context, null, self[i], i) === $breaker) 
          return $breaker.$v;
      }
      return self;
    `
  end

  def empty?
    `self.length === 0`
  end

  def fetch(index, defaults, &block)
    `
      var original = index;
      if (index < 0) index += self.length;
      if (index >= 0 && index < self.length) return self[index];
      if (defaults !==  undefined) return defaults;

      if (block !== nil) return $yielder.call($context, null, original);
      rb_raise(RubyIndexError, 'Array#fetch');
    `
  end

  def first(count = undefined)
    `
      if (count !== undefined) return self.slice(0, count);
      return self.length === 0 ? nil : self[0];
    `
  end

  def flatten(level = undefined)
    `
      var result = [], item;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];

        if (item.$f & T_ARRAY) {
          if (level === undefined)
            result = result.concat(#{`item`.flatten});
          else if (level === 0)
            result.push(item);
          else
            result = result.concat(#{`item`.flatten(`level - 1`)});
        }
        else {
          result.push(item);
        }
      }
      return result;
    `
  end

  def flatten!(level = undefined)
    `
      var result = #{self.flatten level};
      return self.length === result.length ? nil : #{self.clear.replace `result`};
    `
  end

  def grep(pattern)
    `
      var result = [], item;
      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];
        if (#{`pattern` === `item`}) result.push(item);
      }
      return result;
    `
  end

  def hash
    `self.$id || (self.$id = rb_hash_yield++)`
  end

  def include?(member)
    `
      for (var i = 0, length = self.length; i < length; i++) {
        if (#{`self[i]` == member}) return true;
      }
      return false;
    `
  end

  def index(object = undefined, &block)
    return enum_for :index unless block_given? && object == undefined
    `
      if (block !== nil) {
        for (var i = 0, length = self.length, val; i < length; i++) {
          if ((val = $yielder.call($context, null, self[i])) === $breaker)
            return $breaker.$v;

          if (val !== false && val !== nil) return i;
        }
      }
      else {
        for (var i = 0, length = self.length; i < length; i++) {
          if (#{`self[i]` == object}) return i;
        }
      }
      return nil;
    `
  end

  def inject(initial = undefined, &block)
    return enum_for :inject unless block_given?
    `
      var result, val, i;

      if (initial === undefined) {
        i = 1; result = self[0];
      }
      else {
        i = 0; result = initial;
      }

      for (var length = self.length; i < length; i++) {
        if ((val = $yielder.call($context, null, result, self[i])) === $breaker)
          return $breaker.$v;

        result = val;
      }
      return result;
    `
  end

  def insert(index, *objects)
    `
      if (objects.length > 0) {
        if (index < 0) {
          index += self.length + 1;
          if (index < 0) rb_raise(RubyIndexError, index + ' is out of bounds');
        }
        if (index > self.length) {
          for (var i = self.length; i < index; i++) self[i] = nil;
        }
        self.splice.apply(self, [index, 0].concat(objects));
      }
      return self;
    `
  end

  def inspect
    `
      var size = self.length, inspect = [];
      for (var i = 0; i < size; i++) inspect[i] = #{`self[i]`.inspect};
      return '[' + inspect.join(', ') + ']';
    `
  end

  def join(sep = '')
    `
      var result = [];
      for (var i = 0, length = self.length; i < length; i++) {
        result[i] = #{`self[i]`.to_s};
      }
      return result.join(sep);
    `
  end

  def keep_if(&block)
    return enum_for :keep_if unless block_given?
    `
      for (var i = 0, length = self.length, val; i < length; i++) {
        if ((val = $yielder.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        if (val === false || val === nil) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self;
    `
  end

  def last(count = undefined)
    `
      var length = self.length;
      if (count === undefined)
        return length === 0 ? nil : self[length - 1];
      else if (count < 0)
        rb_raise(RubyArgError, 'negative count given');

      if (count > length) count = length;
      return self.slice(length - count, length);
    `
  end

  def length
    `self.length`
  end

  alias_method :map, :collect

  alias_method :map!, :collect!

  def pop(count = undefined)
    `
      var length = self.length;
      if (count === undefined) return length === 0 ? nil : self.pop();
      if (count < 0) rb_raise(RubyArgError, 'negative count given');

      return count > length ? self.splice(0) : self.splice(length - count, length);
    `
  end

  def push(*objects)
    `
      for (var i = 0, length = objects.length; i < length; i++) {
        self.push(objects[i]);
      }
      return self;
    `
  end

  def rassoc(object)
    `
      for (var i = 0, length = self.length, item; i < length; i++) {
        item = self[i];
        if (item.length && item[1] !== undefined) {
          if (#{`item[1]` == object}) return item;
        }
      }
      return nil;
    `
  end

  def reject(&block)
    return enum_for :reject unless block_given?
    `
      var result = [], val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $yielder.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        if (val === false || val === nil) result.push(self[i]);
      }
      return result;
    `
  end

  def reject!(&block)
    return enum_for :reject! unless block_given?
    `
      var val, original = self.length;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $yielder.call($context, null, self[i])) === $breaker)
          return $breaker.$v;

        if (val !== false && val !== nil) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }  
      return original === self.length ? nil : self;
    `
  end

  def replace(other)
    `
      #{self.clear};
      for (var i = 0, length = other.length; i < length; i++) {
        self[i] = other[i];
      }
      return self;
    `
  end

  def reverse
    `self.reverse()`
  end

  def reverse!
    replace(reverse)
  end 

  def reverse_each(&block)
    return enum_for :reverse_each unless block_given?
    `
      for (var i = self.length - 1; i >= 0; i--) {
        if ($yielder.call($context, null, self[i]) === $breaker)
          return $breaker.$v;
      }
      return self;
    `
  end

  def rindex(object = undefined, &block)
    `
      if (block === nil && object === undefined) return self.m$enum_for(null, "rindex");

      if (block !== nil) {
        for (var i = self.length - 1, val; i >= 0; i--) {
          if ((val = $yielder.call($context, null, self[i])) === $breaker)
            return $breaker.$v;

          if (val !== false && val !== nil) return i;
        }
      }
      else {
        for (var i = self.length - 1; i >= 0; i--) {
          if (self[i].m$eq$(null, object)) return i;
        }
      }
      return nil;
    `
  end

  def select(&block)
    return enum_for :select unless block_given?
    `
      var arg, val, result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        arg = self[i];
        if ((val = $yielder.call($context, null, arg)) === $breaker)
          return $breaker.$v;

        if (val !== false && val !== nil) result.push(arg);
      }
      return result;
    `
  end

  def select!(&block)
    return enum_for :select! unless block_given?
    `
      var original = self.length, arg, val;

      for (var i = 0, length = original; i < length; i++) {
        arg = self[i];
        if ((val = $yielder.call($context, null, arg)) === $breaker)
          return $breaker.$v;

        if (val === false || val === nil) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self.length === original ? nil : self;
    `
  end

  def shift(count = undefined)
    `count === undefined ? self.shift() : self.splice(0, count)`
  end

  alias_method :size, :length

  alias_method :slice, :[]

  def slice!(index, length = undefined)
    `
      if (index < 0) index += self.length;
      if (index < 0 || index >= self.length) return nil;
      if (length !== undefined) return self.splice(index, index + length);
      return self.splice(index, 1)[0];
    `
  end

  def take(count)
    `self.slice(0, count)`
  end

  def take_while(&block)
    return enum_for :take_while unless block_given?
    `
      var result = [], item, val;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];
        if ((val = $yielder.call($context, null, item)) === $breaker)
          return $breaker.$v;

        if (val === false || val === nil) return result;
        result.push(item);
      }
      return result;
    `
  end

  def to_a
    self
  end

  alias_method :to_ary, :to_a

  alias_method :to_s, :inspect

  def uniq
    `
      var result = [], seen = {}, item, hash;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i]; hash = item.m$hash();
        if (!seen[hash]) {
          seen[hash] = true;
          result.push(item);
        }
      }
      return result;
    `
  end

  def uniq!
    `
      var seen = {}, original = self.length, item, hash;

      for (var i = 0, length = original; i < length; i++) {
        item = self[i]; hash = item.m$hash();
        if (!seen[hash]) seen[hash] = true;
        else {
          self.splice(i, 1);
          length--;
          i--;
        }
      }
      return self.length === original ? nil : self;
    `
  end

  def unshift(*objects)
    `
      for (var i = 0, length = objects.length; i < length; i++) {
        self.unshift(objects[i]);
      }
      return self;
    `
  end
end
