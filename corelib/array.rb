class Array
  include Enumerable

  def self.[](*objects)
    `
      var result = self.m$allocate();
      result.splice.apply(result, [0, 0].concat(objects));

      return result;
    `
  end

  def self.allocate
    `
      var ary = [];
      ary.$k = self;
      return ary;
    `
  end

  def self.new(length = 0, fill = nil)
    `[]`
  end

  def &(other)
    `
      var result = [],
          seen   = [];

      for (var i = 0, length = self.length; i < self.length; i++) {
        var item = self[i],
            hash = item.$h();

        if (seen.indexOf(hash) == -1) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j],
                hash2 = item2.$h();

            if ((hash == hash2) && seen.indexOf(hash) == -1) {
              seen.push(hash);
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
      if (typeof other === 'string') {
        return self.join(other);
      }

      var result = [];

      for (var i = 0, length = parseInt(other); i < length; i++) {
        result = result.concat(self);
      }

      return result;
    `
  end

  def +(other)
    `self.slice(0).concat(other.slice())`
  end

  def -(other)
    raise NotImplementedError, 'Array#- not yet implemented'
  end

  def <<(object)
    `self.push(object)`
    self
  end

  def <=>(other)
    `
      if (self.m$hash() === other.m$hash()) {
        return 0;
      }

      var tmp;

      for (var i = 0, length = self.length; i < length; i++) {
        if (tmp = self[i].m$$cmp(other[i]) != 0) {
          return tmp;
        }
      }

      if (self.length == other.length) {
        return 0;
      }
      else if (self.length > other.length) {
        return 1;
      }
      else {
        return -1;
      }
    `
  end

  def ==(other)
    `if (self.length !== other.length) return false;

    for (var i = 0; i < self.length; i++) {
      if (!self[i].m$eq$(other[i])) {
        return false;
      }
    }

    return true;`
  end

  # TODO: does not yet work with ranges
  def [](index, length = undefined)
    `
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
    `
  end

  # TODO: need to expand functionality.
  def []=(index, value)
    `
      var size = self.length;

      if (index < 0) {
        index += self.length;
      }

      return self[index] = value;
    `
  end

  def assoc(object)
    `
      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (item.length && item[0].m$eq$(object)) {
          return item;
        }
      }

      return nil;
    `
  end

  def at(index)
    `
      if (index < 0) index += self.length;

      if (index < 0 || index >= self.length) {
        return nil;
      }

      return self[index];
    `
  end

  def clear
    `self.splice(0)`
    self
  end

  def clone
    `self.slice(0)`
  end

  def collect(&block)
    `
      if (block === nil) {
        return self.m$enum_for("collect");
      }

      var result = [], val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, self[i])) === $breaker) {
          return $breaker.$v;
        }

        result[i] = val;
      }

      return result;
    `
  end

  def collect!(&block)
    `
      if (block === nil) {
        return self.m$enum_for("collect!");
      }

      var val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, self[i])) === $breaker) {
          return $breaker.$v;
        }

        self[i] = val;
      }

      return self;
    `
  end

  def combination(*)
    raise NotImplementedError, 'Array#combination not yet implemented'
  end

  def compact
    `
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (item !== nil) {
          result.push(item);
        }
      }

      return result;
    `
  end

  def compact!
    `
      var original = self.length

      for (var i = 0; i < self.length; i++) {
        if (self[i] === nil) {
          self.splice(i, 1);

          i--;
        }
      }

      return original == self.length ? nil : self;
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
      if (object === undefined) {
        return self.length;
      }

      var result = 0;

      for (var i = 0, length = self.length; i < length; i++) {
        if (self[i].m$eq$(object)) {
          result++;
        }
      }

      return result;
    `
  end

  def cycle(*)
    raise NotImplementedError, 'Array#cycle not yet implemented'
  end

  def delete(object)
    `
      var original = self.length;

      for (var i = 0, length = self.length; i < length; i++) {
        if (self[i].m$eq$(object)) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }

      return original == self.length ? nil : object;
    `
  end

  def delete_at(index)
    `
      if (index < 0) {
        index += self.length;
      }

      if (index < 0 || index >= self.length) {
        return nil;
      }

      var result = self[index];
      self.splice(index, 1);

      return result;
    `
  end

  def delete_if(&block)
    `
      if (block === nil) {
        return self.m$enum_for("delete_if");
      }

      var val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (val !== false && val !== nil) {
          self.splice(i, 1);
          i--;
          length--;
        }
      }

      return self;
    `
  end

  def drop(number)
    `
      if (number > self.length) {
        return [];
      }

      return self.slice(number);
    `
  end

  def drop_while(&block)
    `
      if (block === nil) {
        return self.m$enum_for("drop_while");
      }

      var val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (val === false || val === nil) {
          return self.slice(i);
        }
      }

      return [];
    `
  end

  alias_method :dup, :clone

  def each(&block)
    `
      if (block === nil) {
        return self.m$enum_for("each");
      }

      for (var i = 0, length = self.length; i < length; i++) {
        if ($iterator.call($context, self[i]) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  def each_index(&block)
    `
      if (block === nil) {
        return self.m$enum_for("each_index");
      }

      for (var i = 0, length = self.length; i < length; i++) {
        if ($iterator.call($context, i) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  def empty?
    `self.length === 0`
  end

  alias_method :eql?, :==

  def fetch(index, defaults = undefined, &block)
    `
      var original = index;

      if (index < 0) {
        index += self.length;
      }
      if (index >= 0 && index < self.length) {
        return self[index];
      }

      if (defaults === undefined) {
        rb_raise(rb_eIndexError, "Array#fetch");
      }
      else if (block !== nil) {
        return $iterator.call($context, original);
      }
      else {
        return defaults;
      }
    `
  end

  def fill(*)
    raise NotImplementedError, 'Array#fill not yet implemented'
  end

  def find_index(*)
    raise NotImplementedError, 'Arra#find_index not yet implemented'
  end

  def first(count = undefined)
    `
      if (count === undefined) {
        if (self.length == 0) {
          return nil;
        }

        return self[0];
      }

      return self.slice(0, count);
    `
  end

  def flatten(level = undefined)
    `
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i]

        if (item.$f & T_ARRAY) {
          if (level === undefined) {
            result = result.concat(item.m$flatten());
          }
          else if (level == 0) {
            result.push(item);
          }
          else {
            result = result.concat(item.m$flatten(level - 1));
          }
        }
        else {
          result.push(item);
        }
      }

      return result;
    `
  end

  # TODO: improve this
  def flatten!(level = undefined)
    result = flatten(level)

    return clear.replace result unless self == result
  end

  def hash
    `self.id || (self.id = rb_hash_yield++)`
  end

  def include?(member)
    `
      for (var i = 0, length = self.length; i < length; i++) {
        if (self[i].m$eq$(member)) {
          return true;
        }
      }

      return false;
    `
  end

  def index(object = undefined, &block)
    `
      if (block === nil && object === undefined) {
        return self.m$enum_for("index");
      }
      else if (block !== nil) {
        for (var i = 0, length = self.length; i < length; i++) {
          var val;

          if ((val = $iterator.call($context, self[i])) === $breaker) {
            return $breaker.$v;
          }

          if (val !== false && val !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = 0, length = self.length; i < length; i++) {
          if (self[i].m$eq$(object)) {
            return i;
          }
        }
      }

      return nil;
    `
  end

  def insert(index, *objects)
    `
      if (objects.length !== 0) {
        if (index < 0) {
          // insert is different as elements are added AFTER for negative index
          index += self.length + 1;

          if (index < 0) {
            rb_raise(rb_eIndexError, index + " out of bounds");
          }
        }

        // If we are inserting past current length, then fill with nil
        if (index > self.length) {
          for (var i = self.length; i < index; i++) {
            self[i] = nil;
          }
        }
        self.splice.apply(self, [index, 0].concat(objects));
      }
    `
    self
  end

  def inspect
    "[#{map { |o| o.inspect }.join(', ')}]"
  end

  def join(sep = '')
    `
      var result = [];

      for (var i = 0; i < self.length; i++) {
        result.push(self[i].m$to_s());
      }

      return result.join(sep);
    `
  end

  def keep_if(&block)
    `
      if (block === nil) {
        return self.m$enum_for("keep_if");
      }

      var val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, self[i])) === $breaker) {
          return $breaker.$v;
        }

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

      if (count === undefined) {
        if (length === 0) return nil;
        return self[length - 1];
      }
      else if (count < 0) {
        rb_raise(rb_eArgError, "negative count given");
      }
      else {
        if (count > length) {
          count = length;
        }

        return self.slice(length - count, length);
      }
    `
  end

  def length
    `self.length`
  end

  alias_method :map, :collect

  alias_method :map!, :collect!

  def pack(*)
    raise NotImplementedError, 'Array#pack not yet implemented'
  end

  def permutation(*)
    raise NotImplementedError, 'Array#permutation not yet implemented'
  end

  def pop(count = undefined)
    `
      var length = self.length;

      if (count === undefined) {
        if (length === 0) return nil;

        return self.pop();
      }
      else {
        if (count < 0) rb_raise(rb_eArgError, "negative count given");
        if (count > length) return self.splice(0);

        return self.splice(length - count, length);
      }
    `
  end

  def product(*)
    raise NotImplementedError, 'Array#product not yet implemented'
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
      var item;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];

        if (item.length && item[1] !== undefined) {
          if (item[1].m$eq$(object)) {
            return item;
          }
        }
      }

      return nil;
    `
  end

  def reject(&block)
    `
      if (block === nil) {
        return self.m$enum_for("reject");
      }

      var result = [], val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (val === false || val === nil) {
          result.push(self[i]);
        }
      }

      return result
    `
  end

  def reject!(&block)
    `
      if (block === nil) {
        return self.m$enum_for("reject!");
      }

      var original = self.length, val;

      for (var i = 0, length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, self[i])) === $breaker) {
          return $breaker.$v;
        }

        if (val !== false && val !== nil) {
          self.splice(i, 1);
          length--;
          i--;
        }
      }

      return original == self.length ? nil : self;
    `
  end

  def repeated_combination(*)
    raise NotImplementedError, 'Array#repeated_combination not yet implemented'
  end

  def repeated_permutation(*)
    raise NotImplementedError, 'Array#repeated_permutation not yet implemented'
  end

  def replace(other)
    clear.push(*other)
  end

  def reverse
    `self.reverse()`
  end

  def reverse!
    replace reverse
  end

  def reverse_each(&block)
    `
      if (block === nil) {
        return self.m$enum_for("reverse_each");
      }

      for (var i = self.length - 1; i >= 0; i--) {
        if ($iterator.call($context, self[i]) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  def rindex(object = undefined, &block)
    `
      if (block === nil && object === undefined) {
        return self.m$enum_for("rindex");
      }
      else if (block !== nil) {
        for (var i = self.length - 1; i >= 0; i--) {
          var val;

          if ((val = $iterator.call($context, self[i])) === $breaker) {
            return $breaker.$v;
          }

          if (val !== false && val !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = self.length - 1; i >= 0; i--) {
          if (self[i].m$eq$(object)) {
            return i;
          }
        }
      }

      return nil;
    `
  end

  def rotate(*)
    raise NotImplementedError, 'Array#rotate not yet implemented'
  end

  def rotate!(*)
    raise NotImplementedError, 'Array#rotate! not yet implemented'
  end

  def sample(*)
    raise NotImplementedError, 'Array#sample not yet implemented'
  end

  def select(&block)
    `
      if (block === nil) {
        return self.m$enum_for("select");
      }

      var result = [], arg, val;

      for (var i = 0, length = self.length; i < length; i++) {
        arg = self[i];

        if ((val = $iterator.call($context, arg)) === $breaker) {
          return $breaker.$v;
        }

        if (val !== false && val !== nil) {
          result.push(arg);
        }
      }

      return result;
    `
  end

  def select!(&block)
    `
      if (block === nil) {
        return self.m$enum_for("select!");
      }

      var original = self.length, arg, val;

      for (var i = 0, length = self.length; i < length; i++) {
        arg = self[i];

        if ((val = $iterator.call($context, arg)) === $breaker) {
          return $breaker.$v;
        }

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
    `
      if (count !== undefined) {
        return self.splice(0, count);
      }

      return self.shift();
    `
  end

  def shuffle(*)
    raise NotImplementedError, 'Array#shuffle not yet implemented'
  end

  def shuffle!(*)
    raise NotImplementedError, 'Array#shuffle! not yet implemented'
  end

  alias_method :size, :length

  # TODO: does not yet work with ranges
  def slice(index, length = undefined)
    `
      if (index < 0) {
        index += self.length;
      }

      if (index >= self.length || index < 0) {
        return nil;
      }

      if (length !== undefined) {
        return self.slice(index, index + length);
      }

      return self.slice(index, 1)[0];
    `
  end

  # TODO: does not yet work with ranges
  def slice!(index, length = undefined)
    `
      if (index < 0) {
        index += self.length;
      }

      if (index >= self.length || index < 0) {
        return nil;
      }

      if (length !== undefined) {
        return self.splice(index, index + length);
      }

      return self.splice(index, 1)[0];
    `
  end

  def sort(*)
    raise NotImplementedError, 'Array#sort not yet implemented'
  end

  def sort!(*)
    raise NotImplementedError, 'Array#sort! not yet implemented'
  end

  def sort_by!(*)
    raise NotImplementedError, 'Array#sort_by! not yet implemented'
  end

  def take(count)
    `self.slice(0, count)`
  end

  def take_while(&block)
    `
      if (block === nil) {
        return self.m$enum_for("take_while");
      }

      var result = [], item, val;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];

        if ((val = $iterator.call($context, item)) === $breaker) {
          return $breaker.$v;
        }

        if (val === false || val === nil) {
          return result;
        }

        result.push(item);
      }

      return result;
    `
  end

  def to_a
    self
  end

  def to_ary
    self
  end

  alias_method :to_s, :inspect

  def transpose(*)
    raise NotImplementedError, 'Array#transpose not yet implemented'
  end

  def uniq
    `
      var result = [], seen = [], item, hash;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];
        hash = item.$h();

        if (seen.indexOf(hash) == -1) {
          seen.push(hash);
          result.push(item);
        }
      }

      return result;
    `
  end

  def uniq!
    `
      var seen = [], original = self.length, item, hash;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];
        hash = item.$h();

        if (seen.indexOf(hash) == -1) {
          seen.push(hash);
        }
        else {
          self.splice(i, 1);

          i--; length--;
        }
      }

      return self.length === original ? nil : self;
    `
  end

  def unshift(*objects)
    `
      for (var i = objsects.length - 1; i >= 0; i--) {
        self.unshift(objects[i]);
      }

      return self;
    `
  end

  def values_at(*)
    raise NotImplementedError, 'Array#values_at not yet implemented'
  end

  def zip(*)
    raise NotImplementedError, 'Array#zip not yet implemented'
  end

  def |(*)
    raise NotImplementedError, 'Array#| not yet implemented'
  end

  # Enumerable reimplementation
  def each_with_index(&block)
    `
      if (block === nil) {
        return self.m$enum_for("each_with_index");
      }

      for (var i = 0, length = self.length; i < length; i++) {
        if ($iterator.call($context, self[i], i) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  def grep(pattern)
    `
      var result = [], item;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];

        if (pattern.m$eqq$(item)) {
          result.push(item);
        }
      }

      return result;
    `
  end

  def inject(initial = undefined, &block)
    `
      if (block === nil) {
        return self.m$enum_for("inject");
      }

      if (initial === undefined) {
        var i = 1, result = self[0];
      }
      else {
        var i = 0, result = initial;
      }

      var val;

      for (var length = self.length; i < length; i++) {
        if ((val = $iterator.call($context, result, self[i])) === $breaker) {
          return $breaker.$v;
        }

        result = val;
      }

      return result;
    `
  end
end
