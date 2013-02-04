class Array < `Array`
  %x{
    Array.prototype._isArray = true;
  }

  include Enumerable

  def self.[](*objects)
    %x{
      return objects;
    }
  end

  def self.new(size, obj = nil, &block)
    %x{
      var arr = [];

      if (size && size._isArray) {
        for (var i = 0; i < size.length; i++) {
          arr[i] = size[i];
        }
      }
      else {
        if (block === nil) {
          for (var i = 0; i < size; i++) {
            arr[i] = obj;
          }
        }
        else {
          for (var i = 0; i < size; i++) {
            arr[i] = block(i);
          }
        }
      }

      return arr;
    }
  end

  def &(other)
    %x{
      var result = [],
          seen   = {};

      for (var i = 0, length = #{self}.length; i < length; i++) {
        var item = #{self}[i];

        if (!seen[item]) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j];

            if ((item === item2) && !seen[item]) {
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
    %x{
      if (typeof(other) === 'string') {
        return #{self}.join(other);
      }

      var result = [];

      for (var i = 0; i < other; i++) {
        result = result.concat(#{self});
      }

      return result;
    }
  end

  def +(other)
    `#{self}.slice().concat(other.slice())`
  end

  def -(other)
    reject { |i| other.include? i }
  end

  def <<(object)
    `#{self}.push(object);`

    self
  end

  def <=>(other)
    %x{
      if (#{self.hash} === #{other.hash}) {
        return 0;
      }

      if (#{self}.length != other.length) {
        return (#{self}.length > other.length) ? 1 : -1;
      }

      for (var i = 0, length = #{self}.length, tmp; i < length; i++) {
        if ((tmp = #{`#{self}[i]` <=> `other[i]`}) !== 0) {
          return tmp;
        }
      }

      return 0;
    }
  end

  def ==(other)
    %x{
      if (!other || (#{self}.length !== other.length)) {
        return false;
      }

      for (var i = 0, length = #{self}.length; i < length; i++) {
        if (!#{`#{self}[i]` == `other[i]`}) {
          return false;
        }
      }

      return true;
    }
  end

  def [](index, length = undefined)
    %x{
      var size = #{self}.length;

      if (typeof index !== 'number') {
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

  def []=(index, value)
    %x{
      var size = #{self}.length;

      if (index < 0) {
        index += size;
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

  def clear
    `#{self}.splice(0, #{self}.length)`

    self
  end

  def clone
    `#{self}.slice()`
  end

  def collect(&block)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      }

      return result;
    }
  end

  def collect!(&block)
    %x{
      for (var i = 0, length = #{self}.length, val; i < length; i++) {
        if ((val = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
        }

        #{self}[i] = val;
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

  def count(object)
    %x{
      if (object == null) {
        return #{self}.length;
      }

      var result = 0;

      for (var i = 0, length = #{self}.length; i < length; i++) {
        if (#{`#{self}[i]` == object}) {
          result++;
        }
      }

      return result;
    }
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
    %x{
      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
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
    `#{self}.slice(number)`
  end

  alias dup clone

  def each(&block)
    `for (var i = 0, length = #{self}.length; i < length; i++) {`
      yield `#{self}[i]`
    `}`

    self
  end

  def each_index(&block)
    `for (var i = 0, length = #{self}.length; i < length; i++) {`
      yield `i`
    `}`

    self
  end

  def empty?
    `!#{self}.length`
  end

  def fetch(index, defaults, &block)
    %x{
      var original = index;

      if (index < 0) {
        index += #{self}.length;
      }

      if (index >= 0 && index < #{self}.length) {
        return #{self}[index];
      }

      if (defaults != null) {
        return defaults;
      }

      if (block !== nil) {
        return block(original);
      }

      #{ raise "Array#fetch" };
    }
  end

  def first(count)
    %x{
      if (count != null) {
        return #{self}.slice(0, count);
      }

      return #{self}.length === 0 ? nil : #{self}[0];
    }
  end

  def flatten(level)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item; i < length; i++) {
        item = #{self}[i];

        if (item._isArray) {
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

  def flatten!(level)
    %x{
      var size = #{self}.length;
      #{replace flatten level};

      return size === #{self}.length ? nil : #{self};
    }
  end

  def hash
    `#{self}._id || (#{self}._id = unique_id++)`
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
          if ((value = block(#{self}[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
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
            #{ raise "#{index} is out of bounds" };
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
    %x{
      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
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

  def last(count)
    %x{
      var length = #{self}.length;

      if (count == null) {
        return length === 0 ? nil : #{self}[length - 1];
      }
      else if (count < 0) {
        #{ raise "negative count given" };
      }

      if (count > length) {
        count = length;
      }

      return #{self}.slice(length - count, length);
    }
  end

  def length
    `#{self}.length`
  end

  alias map collect

  alias map! collect!

  def pop(count)
    %x{
      var length = #{self}.length;

      if (count == null) {
        return length === 0 ? nil : #{self}.pop();
      }

      if (count < 0) {
        #{ raise "negative count given" };
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
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, value; i < length; i++) {
        if ((value = block(#{self}[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          result.push(#{self}[i]);
        }
      }
      return result;
    }
  end

  def reject!(&block)
    %x{
      var original = #{self}.length;
      #{ delete_if &block };
      return #{self}.length === original ? nil : #{self};
    }
  end

  def replace(other)
    %x{
      #{self}.splice(0, #{self}.length);
      #{self}.push.apply(#{self}, other);
      return #{self};
    }
  end

  alias_native :reverse, :reverse

  def reverse!
    %x{
      #{self}.splice(0);
      #{self}.push.apply(#{self}, #{reverse});
      return #{self};
    }
  end

  def reverse_each(&block)
    reverse.each &block

    self
  end

  def rindex(object = undefined, &block)
    %x{
      if (block !== nil) {
        for (var i = #{self}.length - 1, value; i >= 0; i--) {
          if ((value = block(#{self}[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = #{self}.length - 1; i >= 0; i--) {
          if (#{`#{self}[i]` == `object`}) {
            return i;
          }
        }
      }

      return nil;
    }
  end

  def select(&block)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item, value; i < length; i++) {
        item = #{self}[i];

        if ((value = block(item)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(item);
        }
      }

      return result;
    }
  end

  def select!(&block)
    %x{
      var original = #{self}.length;
      #{ keep_if &block };
      return #{self}.length === original ? nil : #{self};
    }
  end

  def shift(count)
    %x{
      if (#{self}.length === 0) {
        return nil;
      }

      return count == null ? #{self}.shift() : #{self}.splice(0, count)
    }
  end

  alias size length

  alias slice :[]

  def slice!(index, length)
    %x{
      if (index < 0) {
        index += #{self}.length;
      }

      if (length != null) {
        return #{self}.splice(index, length);
      }

      if (index < 0 || index >= #{self}.length) {
        return nil;
      }

      return #{self}.splice(index, 1)[0];
    }
  end

  def take(count)
    `#{self}.slice(0, count)`
  end

  def take_while(&block)
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length, item, value; i < length; i++) {
        item = #{self}[i];

        if ((value = block(item)) === __breaker) {
          return __breaker.$v;
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

  def to_json
    %x{
      var result = [];

      for (var i = 0, length = #{self}.length; i < length; i++) {
        result.push(#{ `#{self}[i]`.to_json });
      }

      return '[' + result.join(', ') + ']';
    }
  end

  alias to_s inspect

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

  def sort(&block)
    %x{
      var copy = #{self}.slice();

      if (block !== nil) {
        return copy.sort(block);
      }

      return copy.sort();
    }
  end

  def sort!(&block)
    %x{
      if (block !== nil) {
        return #{self}.sort(block);
      }

      return #{self}.sort();
    }
  end

  def shuffle()
    %x{
        for (var i = #{self}.length - 1; i > 0; i--) {
          var j = Math.floor(Math.random() * (i + 1));
          var tmp = #{self}[i];
          #{self}[i] = #{self}[j];
          #{self}[j] = tmp;
        }

        return #{self};
    }
  end
end