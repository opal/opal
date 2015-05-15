require 'corelib/enumerable'

class Array
  include Enumerable

  # Mark all javascript arrays as being valid ruby arrays
  `def.$$is_array = true`

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
    Opal.coerce_to? obj, Array, :to_ary
  end

  def &(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to(other, Array, :to_ary).to_a
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

  def |(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to(other, Array, :to_ary).to_a
    end

    %x{
      var result = [],
          seen   = {};

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (!seen[item]) {
          seen[item] = true;
          result.push(item);
        }
      }

      for (var i = 0, length = other.length; i < length; i++) {
        var item = other[i];

        if (!seen[item]) {
          seen[item] = true;
          result.push(item);
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
      other = Opal.coerce_to(other, Array, :to_ary).to_a
    end

    `self.concat(other)`
  end

  def -(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to(other, Array, :to_ary).to_a
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
      other = other.to_ary.to_a
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
    %x{
      var recursed = {};

      function _eqeq(array, other) {
        var i, length, a, b;

        if (!other.$$is_array) {
          if (#{Opal.respond_to? `other`, :to_ary}) {
            return #{`other` == `array`};
          } else {
            return false;
          }
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

  def [](index, length = undefined)
    if Range === index
      %x{
        var size    = self.length,
            exclude = index.exclude,
            from    = #{Opal.coerce_to `index.begin`, Integer, :to_int},
            to      = #{Opal.coerce_to `index.end`, Integer, :to_int};

        if (from < 0) {
          from += size;

          if (from < 0) {
            return nil;
          }
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

        if (!exclude) {
          to += 1;
        }

        return self.slice(from, to);
      }
    else
      index = Opal.coerce_to index, Integer, :to_int

      %x{
        var size = self.length;

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
          length = #{Opal.coerce_to length, Integer, :to_int};

          if (length < 0 || index > size || index < 0) {
            return nil;
          }

          return self.slice(index, index + length);
        }
      }
    end
  end

  def []=(index, value, extra = undefined)
    if Range === index
      if Array === value
        data = value.to_a
      elsif value.respond_to? :to_ary
        data = value.to_ary.to_a
      else
        data = [value]
      end

      %x{
        var size    = self.length,
            exclude = index.exclude,
            from    = #{Opal.coerce_to `index.begin`, Integer, :to_int},
            to      = #{Opal.coerce_to `index.end`, Integer, :to_int};

        if (from < 0) {
          from += size;

          if (from < 0) {
            #{raise RangeError, "#{index.inspect} out of range"};
          }
        }

        if (to < 0) {
          to += size;
        }

        if (!exclude) {
          to += 1;
        }

        if (from > size) {
          for (var i = size; i < from; i++) {
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
      }
    else
      if `extra === undefined`
        length = 1
      else
        length = value
        value  = extra

        if Array === value
          data = value.to_a
        elsif value.respond_to? :to_ary
          data = value.to_ary.to_a
        else
          data = [value]
        end
      end

      %x{
        var size   = self.length,
            index  = #{Opal.coerce_to index, Integer, :to_int},
            length = #{Opal.coerce_to length, Integer, :to_int},
            old;

        if (index < 0) {
          old    = index;
          index += size;

          if (index < 0) {
            #{raise IndexError, "index #{`old`} too small for array; minimum #{`-self.length`}"};
          }
        }

        if (length < 0) {
          #{raise IndexError, "negative length (#{length})"}
        }

        if (index > size) {
          for (var i = size; i < index; i++) {
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
    end
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
    index = Opal.coerce_to index, Integer, :to_int

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

  def cycle(n = nil, &block)
    return if empty? || n == 0

    return enum_for :cycle, n unless block

    if n.nil?
      %x{
        while (true) {
          for (var i = 0, length = self.length; i < length; i++) {
            var value = Opal.yield1(block, self[i]);

            if (value === $breaker) {
              return $breaker.$v;
            }
          }
        }
      }
    else
      n = Opal.coerce_to! n, Integer, :to_int

      %x{
        if (n <= 0) {
          return self;
        }

        while (n > 0) {
          for (var i = 0, length = self.length; i < length; i++) {
            var value = Opal.yield1(block, self[i]);

            if (value === $breaker) {
              return $breaker.$v;
            }
          }

          n--;
        }
      }
    end

    self
  end

  def clear
    `self.splice(0, self.length)`

    self
  end

  def clone
    copy = []
    copy.initialize_clone(self)
    copy
  end

  def dup
    copy = []
    copy.initialize_dup(self)
    copy
  end

  def initialize_copy(other)
    replace other
  end

  def collect(&block)
    return enum_for :collect unless block_given?

    %x{
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        var value = Opal.yield1(block, self[i]);

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
        var value = Opal.yield1(block, self[i]);

        if (value === $breaker) {
          return $breaker.$v;
        }

        self[i] = value;
      }
    }

    self
  end
  
  def combination(n)
    num = Opal.coerce_to! n, Integer, :to_int
    return enum_for :combination, num unless block_given?
    
    %x{
      var i;
      var length;
      var stack;
      var chosen;
      var lev;
      var done;
      var next;

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
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to(other, Array, :to_ary).to_a
    end

    %x{
      for (var i = 0, length = other.length; i < length; i++) {
        self.push(other[i]);
      }
    }

    self
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
      index = #{Opal.coerce_to `index`, Integer, :to_int};

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
        if ((value = block(self[i])) === $breaker) {
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
    %x{
      if (number < 0) {
        #{raise ArgumentError}
      }

      return self.slice(number);
    }
  end

  alias dup clone

  def each(&block)
    return enum_for :each unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        var value = Opal.yield1(block, self[i]);

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
        var value = Opal.yield1(block, i);

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

      index = #{Opal.coerce_to `index`, Integer, :to_int};

      if (index < 0) {
        index += self.length;
      }

      if (index >= 0 && index < self.length) {
        return self[index];
      }

      if (block !== nil) {
        return block(original);
      }

      if (defaults != null) {
        return defaults;
      }

      if (self.length === 0) {
        #{raise IndexError, "index #{`original`} outside of array bounds: 0...0"}
      }
      else {
        #{raise IndexError, "index #{`original`} outside of array bounds: -#{`self.length`}...#{`self.length`}"};
      }
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
      if (count == null) {
        return self.length === 0 ? nil : self[0];
      }

      count = #{Opal.coerce_to `count`, Integer, :to_int};

      if (count < 0) {
        #{raise ArgumentError, 'negative array size'};
      }

      return self.slice(0, count);
    }
  end

  def flatten(level = undefined)
    %x{
      var object_id = #{`self`.object_id};

      function _flatten(array, level) {
        var array = #{`array`.to_a},
            result = [],
            i, length,
            item, ary;

        for (i = 0, length = array.length; i < length; i++) {
          item = array[i];

          if (!#{Opal.respond_to? `item`, :to_ary}) {
            result.push(item);
            continue;
          }

          ary = #{`item`.to_ary};

          if (ary === nil) {
            result.push(item);
            continue;
          }

          if (!ary.$$is_array) {
            #{raise TypeError};
          }

          if (object_id === #{`ary`.object_id}) {
            #{raise ArgumentError};
          }

          switch (level) {
          case undefined:
            result.push.apply(result, _flatten(ary));
            break;
          case 0:
            result.push(ary);
            break;
          default:
            result.push.apply(result, _flatten(ary, level - 1));
          }
        }
        return result;
      }

      if (level !== undefined) {
        level = #{Opal.coerce_to(`level`, Integer, :to_int)};
      }

      return _flatten(self, level);
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
    %x{
      var hash = ['A'],
          item;
      for (var i = 0, length = self.length; i < length; i++) {
        item = self[i];
        if (item.$$is_array && #{`self`.eql?(`item`)}) {
          hash.push('self');
        } else {
          hash.push(item.$hash());
        }
      }
      return hash.join(',');
    }
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

  def index(object=undefined, &block)
    %x{
      if (object != null) {
        for (var i = 0, length = self.length; i < length; i++) {
          if (#{`self[i]` == object}) {
            return i;
          }
        }
      }
      else if (block !== nil) {
        for (var i = 0, length = self.length, value; i < length; i++) {
          if ((value = block(self[i])) === $breaker) {
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
      index = #{Opal.coerce_to `index`, Integer, :to_int};

      if (objects.length > 0) {
        if (index < 0) {
          index += self.length + 1;

          if (index < 0) {
            #{ raise IndexError, "#{index} is out of bounds" };
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
      var result = [],
          id     = #{__id__};

      for (var i = 0, length = self.length; i < length; i++) {
        var item = #{self[`i`]};

        if (#{`item`.__id__} === id) {
          result.push('[...]');
        }
        else {
          result.push(#{`item`.inspect});
        }
      }

      return '[' + result.join(', ') + ']';
    }
  end

  def join(sep = nil)
    return "" if `self.length === 0`

    if `sep === nil`
      sep = $,
    end

    %x{
      var result = [];
      var object_id = #{`self`.object_id};

      for (var i = 0, length = self.length; i < length; i++) {
        var item = self[i];

        if (#{Opal.respond_to? `item`, :to_str}) {
          var tmp = #{`item`.to_str};

          if (tmp !== nil) {
            result.push(#{`tmp`.to_s});

            continue;
          }
        }

        if (#{Opal.respond_to? `item`, :to_ary}) {
          var tmp = #{`item`.to_ary};

          if (object_id === #{`tmp`.object_id}) {
            #{raise ArgumentError};
          }

          if (tmp !== nil) {
            result.push(#{`tmp`.join(sep)});

            continue;
          }
        }

        if (#{Opal.respond_to? `item`, :to_s}) {
          var tmp = #{`item`.to_s};

          if (tmp !== nil) {
            result.push(tmp);

            continue;
          }
        }

        #{raise NoMethodError, "#{Opal.inspect(`item`)} doesn't respond to #to_str, #to_ary or #to_s"};
      }

      if (sep === nil) {
        return result.join('');
      }
      else {
        return result.join(#{Opal.coerce_to!(sep, String, :to_str).to_s});
      }
    }
  end

  def keep_if(&block)
    return enum_for :keep_if unless block_given?

    %x{
      for (var i = 0, length = self.length, value; i < length; i++) {
        if ((value = block(self[i])) === $breaker) {
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
      if (count == null) {
        return self.length === 0 ? nil : self[self.length - 1];
      }

      count = #{Opal.coerce_to `count`, Integer, :to_int};

      if (count < 0) {
        #{raise ArgumentError, 'negative array size'};
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

  alias map collect

  alias map! collect!

  def pop(count = undefined)
    if `count === undefined`
      return if `self.length === 0`
      return `self.pop()`
    end

    count = Opal.coerce_to count, Integer, :to_int

    if `count < 0`
      raise ArgumentError, 'negative array size'
    end

    return [] if `self.length === 0`

    if `count > self.length`
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
        arrays[i] = #{Opal.coerce_to(`args[i - 1]`, Array, :to_ary)};
      }

      for (i = 0; i < n; i++) {
        len = arrays[i].length;
        if (len === 0) {
          return result || self;
        }
        resultlen *= len;
        if (resultlen > 2147483647) {
          #{raise RangeError, "too big to product"}
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
        if ((value = block(self[i])) === $breaker) {
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

    original = length
    delete_if(&block)

    unless length == original
      self
    end
  end

  def replace(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to(other, Array, :to_ary).to_a
    end

    %x{
      self.splice(0, self.length);
      self.push.apply(self, other);
    }

    self
  end

  def reverse
    `self.slice(0).reverse()`
  end

  def reverse!
    `self.reverse()`
  end

  def reverse_each(&block)
    return enum_for :reverse_each unless block_given?

    reverse.each &block
    self
  end

  def rindex(object = undefined, &block)
    %x{
      if (object != null) {
        for (var i = self.length - 1; i >= 0; i--) {
          if (#{`self[i]` == `object`}) {
            return i;
          }
        }
      }
      else if (block !== nil) {
        for (var i = self.length - 1, value; i >= 0; i--) {
          if ((value = block(self[i])) === $breaker) {
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

      for (var i = 0, length = self.length, item, value; i < length; i++) {
        item = self[i];

        if ((value = Opal.yield1(block, item)) === $breaker) {
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
      #{ keep_if &block };
      return self.length === original ? nil : self;
    }
  end

  def shift(count = undefined)
    if `count === undefined`
      return if `self.length === 0`
      return `self.shift()`
    end

    count = Opal.coerce_to count, Integer, :to_int

    if `count < 0`
      raise ArgumentError, 'negative array size'
    end

    return [] if `self.length === 0`

    `self.splice(0, count)`
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

      return self.slice(0, count);
    }
  end

  def take_while(&block)
    %x{
      var result = [];

      for (var i = 0, length = self.length, item, value; i < length; i++) {
        item = self[i];

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

  alias to_s inspect

  def transpose
    return [] if empty?

    result = []
    max    = nil

    each {|row|
      if Array === row
        row = row.to_a
      else
        row = Opal.coerce_to(row, Array, :to_ary).to_a
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

      for (var i = 0, length = self.length, item, hash; i < length; i++) {
        item = self[i];
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
      var original = self.length,
          seen     = {};

      for (var i = 0, length = original, item, hash; i < length; i++) {
        item = self[i];
        hash = item;

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
      for (var i = objects.length - 1; i >= 0; i--) {
        self.unshift(objects[i]);
      }
    }

    self
  end

  def values_at(*args)
    out = [];

    args.each do |elem|
      if elem.kind_of? Range
        finish = Opal.coerce_to elem.last, Integer, :to_int
        start = Opal.coerce_to elem.first, Integer, :to_int
        
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
          if (#{elem.exclude_end?}) {
            finish--;
          }
          if (finish < start) {
            #{next};
          }
        }

        start.upto(finish) { |i| out << at(i) }
      else
        i = Opal.coerce_to elem, Integer, :to_int
        out << at(i)
      end
    end

    out
  end

  def zip(*others, &block)
    %x{
      var result = [], size = self.length, part, o;

      for (var i = 0; i < size; i++) {
        part = [self[i]];

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
