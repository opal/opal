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
    `var ary = [];
    ary.$m = self.$m_tbl;
    ary.$k = self;
    return ary;`
  end

  def self.new(length = 0, fill = nil)
    `new Array(length, fill)`
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
    return join other if Object === other && other.is_a?(String)

    `
      var result = [];

      for (var i = 0, length = #{Object === other ? other.to_i : `parseInt(other)`}; i < length; i++) {
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
      if (#{self.hash} == #{other.hash}) {
        return 0;
      }

      var tmp;

      for (var i = 0, length = self.length; i < length; i++) {
        if (tmp = #{`self[i]` <=> `other[i]`} != 0) {
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
      if (!#{`self[i]` == `other[i]`}) {
        return false;
      }
    }

    return true;`
  end

  # TODO: does not yet work with ranges
  def [](index, length = undefined)
    index += @length if index < 0

    return if index >= @length || index < 0

    `
      if (length !== undefined) {
        if (length <= 0) {
          return [];
        }

        return self.slice(index, index + length);
      }
      else {
        return self[index];
      }
    `
  end

  # TODO: need to expand functionality.
  def []=(index, value)
    index += @length if index < 0

    `self[index] = value`
  end

  def assoc(object)
    `
      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (item.length && #{`item[0]` == object}) {
          return item;
        }
      }
    `
  end

  def at(index)
    index += @length if index < 0

    return if index < 0 || index >= @length

    `self[index]`
  end

  def clear
    `self.splice(0)`

    self
  end

  def clone
    `self.slice(0)`
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    `
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        result.push(#{ yield `self[i]` });
      }

      return result;
    `
  end

  def collect!
    `
      for (var i = 0, length = self.length; i < length; i++) {
        self[i] = #{yield `self[i]`};
      }
    `

    self
  end

  def combination (*)
    raise NotImplementedError, 'Array#combination not yet implemented'
  end

  def compact
    `
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (item != null) {
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
        if (self[i] == null) {
          self.splice(i, 1);

          i--;
        }
      }

      return original == self.length ? null : self;
    `
  end

  def concat(other)
    `
      for (var i = 0, length = other.length; i < length; i++) {
        self.push(other[i]);
      }
    `

    self
  end

  def count(object = undefined)
    `
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
    `
  end

  def cycle(*)
    raise NotImplementedError, 'Array#cycle not yet implemented'
  end

  def delete(object)
    `
      var original = self.length;

      for (var i = 0, length = self.length; i < length; i++) {
        if (#{`self[i]` == obj}) {
          self.splice(i, 1);

          i--; length--;
        }
      }

      return original == self.length ? null : object;
    `
  end

  def delete_at(index)
    index += @length if index < 0

    return if index < 0 || index >= @length

    result = self[index]
    `self.splice(index, 1)`
    result
  end

  def delete_if
    return enum_for :delete_if unless block_given?

    `
      for (var i = 0, length = self.length; i < length; i++) {
        if (#{yield `self[i]`}) {
          self.splice(i, 1);

          i--; length--;
        }
      }
    `

    self
  end

  def drop(number)
    return [] if number > @length

    `self.slice(number)`
  end

  def drop_while
    `
      for (var i = 0, length = self.length; i < length; i++) {
        if (!#{yield `self[i]`}) {
          return self.slice(i);
        }
      }

      return [];
    `
  end

  alias_method :dup, :clone

  def each
    return enum_for :each unless block_given?

    `
      for (var i = 0, len = self.length; i < len; i++) {
        #{yield `self[i]`}
      }
    `

    self
  end

  def each_index
    return enum_for :each_index unless block_given?

    `
      for (var i = 0, len = self.length; i < len; i++) {
        #{yield `i`}
      }
    `

    self
  end

  def empty?
    @length == 0
  end

  alias_method :eql?, :==

  def fetch(index, defaults = undefined)
    original = index

    index += @length if index < 0

    return `self[index]` unless index < 0 || index >= @length

    if defaults == undefined
      raise IndexError, 'Array#fetch'
    elsif block_given?
      yield original
    else
      defaults
    end
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
          return null;
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

        if (#{Object === `item` && `item`.is_a?(Array)}) {
          if (level === undefined) {
            result = result.concat(#{`item`.flatten});
          }
          else if (level == 0) {
            result.push(item);
          }
          else {
            result = result.concat(#{`item`.flatten `level - 1`});
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

  def include?(member)
    `
      for (var i = 0, length = self.length; i < length; i++) {
        if (#{`self[i]` == member}) {
          return true;
        }
      }
    `

    false
  end

  def index(object = undefined)
    return enum_for :index unless block_given? || `object !== undefined`

    `
      for (var i = 0, length = self.length; i < length; i++) {
        if (#{block_given? ? yield(`self[i]`) : `self[i]` == object}) {
          return i;
        }
      }
    `
  end

  def insert(index, *objects)
    index += @length if index < 0

    raise IndexError, 'out of range' if index < 0 || index >= size

    `self.splice.apply(self, [index, 0].concat(objs))`

    self
  end

  def inspect
    "[#{map { |o| o.inspect }.join(', ')}]"
  end

  def join(sep = '')
    `
      var result = [];

      for (var i = 0; i < self.length; i++) {
        result.push(#{`self[i]`.to_s});
      }

      return result.join(sep);
    `
  end

  def keep_if
    return enum_for :keep_if unless block_given?

    `
      for (var i = 0, length = self.length; i < length; i++) {
        if (!#{yield `self[i]`}) {
          self.splice(i, 1);

          i--; length--;
        }
      }
    `

    self
  end

  def last(count = undefined)
    `
      var length = self.length;

      if (count === undefined) {
        return self[length - 1];
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
        return self.pop();
      }
      else {
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
    `

    self
  end

  def rassoc(object)
    `
      var item;

      for (var i = 0; i < self.length; i++) {
        item = self[i];

        if (#{Object === `item` && `item`.is_a?(Array) && !`item[1]`.nil?}) {
          if (#{`item[1]` == obj}) {
            return item;
          }
        }
      }
    `
  end

  def reject
    return enum_for :reject unless block_given?

    `
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        if (!#{yield `self[i]`}) {
          result.push(self[i]);
        }
      }

      return result
    `
  end

  def reject!
    return enum_for :reject! unless block_given?

    `
      var original = self.length;

      for (var i = 0, length = self.length; i < length; i++) {
        if (#{yield `self[i]`}) {
          self.splice(i, 1);

          i--; length--;
        }
      }

      return original == self.length ? null : self;
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

  def reverse_each
    return enum_for :reverse_each unless block_given?

    `
      for (var i = self.length - 1; i >= 0; i--) {
        #{yield `self[i]`};
      }
    `

    self
  end

  def rindex(object = undefined)
    return enum_for :rindex unless block_given? || `object !== undefined`

    `
      for (var i = self.length - 1; i >= 0; i--) {
        if (#{block_given? ? yield(`self[i]`) : `self[i]` == object}) {
          return i;
        }
      }
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

  def select
    return enum_for :select unless block_given?

    `
      var result = [], arg;

      for (var i = 0, length = self.length; i < length; i++) {
        arg = self[i];

        if (#{yield `arg`}) {
          result.push(arg);
        }
      }

      return result;
    `
  end

  def select!
    `
      var original = self.length;

      for (var i = 0, length = self.length; i < length; i++) {
        if (!#{yield `self[i]`}) {
          self.splice(i, 1);

          i--; length--;
        }
      }

      return self.length == origina ? null : self;
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
    index += @length if index < 0

    return if index >= @length || index < 0

    if length
      `self.slice(index, index + length)`
    else
      `self.slice(index, 1)[0]`
    end
  end

  # TODO: does not yet work with ranges
  def slice!(index, length = undefined)
    index += @length if index < 0

    return if index >= @length || index < 0

    if length
      `self.splice(index, index + length)`
    else
      `self.splice(index, 1)[0]`
    end
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

  def take_while
    return enum_for :take_while unless block_given?

    `
      var result = [], item;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];

        if (#{yield `item`}) {
          result.push(item);
        }
        else {
          break;
        }
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

      return self.length == original ? null : self;
    `
  end

  def unshift(*objects)
    `
      for (var i = objsects.length - 1; i >= 0; i--) {
        self.unshift(objects[i]);
      }
    `

    self
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
  def each_with_index
    return enum_for :each_with_index unless block_given?

    `
      for (var i = 0, length = self.length; i < length; i++) {
        #{yield `self[i]`, `i`}
      }
    `

    self
  end

  def grep(pattern)
    `
      var result = [], item;

      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];

        if (#{pattern === `item`}) {
          result.push(item);
        }
      }

      return result;
    `
  end

  def inject(initial = undefined)
    `
      if (initial === undefined) {
        var i = 1, result = self[0];
      }
      else {
        var i = 0, result = initial;
      }

      for (var length = self.length; i < length; i++) {
        result = #{yield `result`, `self[i]`};
      }

      return result;
    `
  end
end
