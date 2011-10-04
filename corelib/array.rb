class Array
  # include Enumerable

  # Returns a new array populated with the given objects.
  #
  # @example
  #
  #     Array['a', 'b', 'c']    # => ['a', 'b', 'c']
  #
  # @param [Object] objs
  # @return [Array]
  def self.[](*objs)
    `var ary = #{allocate};
    ary.splice.apply(ary, [0, 0].concat(objs));
    return ary;`
  end

  def self.allocate
    `var ary = new self.$a();
    return ary;`
  end

  def self.from_native(obj)
    `if (!obj) return [];
    if (#{Object(obj).respond_to? :to_a}) return #{obj.to_a};

    var length = obj.length || 0, result = new Array(length);
    while (length--) result[length] = obj[length];
    return result;`
  end

  def initialize(len = 0, fill = nil)
    `for (var i = 0; i < len; i++) {
      self[i] = fill;
    }

    self.length = len;

    return self;`
  end

  # Returns a formatted, printable version of the array. {#inspect} is called
  # on each of the elements and appended to the string.
  #
  # @return [String] string representation of the receiver
  def inspect
    `var description = [];

    for (var i = 0, length = self.length; i < length; i++) {
      description.push(#{`self[i]`.inspect});
    }

    return '[' + description.join(', ') + ']';`
  end

  # Returns a simple string version of the array. {#to_s} is applied to each
  # of the child elements with no seperator.
  def to_s
    `var description = [];

    for (var i = 0, length = self.length; i < length; i++) {
      description.push(#{`self[i]`.to_s});
    }

    return description.join('');`
  end

  # Append - pushes the given object onto the end of this array. This 
  # expression returns the array itself, so several appends may be chained
  # together.
  #
  # @example
  #
  #     [1, 2] << "c" << "d" << [3, 4]
  #     # => [1, 2, "c", "d", [3, 4]]
  #
  # @param [Object] obj the object to append
  # @return [Array] returns the receiver
  def <<(obj)
    `self.push(obj);`
    self
  end

  # Returns the number of elements in `self`. May be zero.
  #
  # @example
  #
  #     [1, 2, 3, 4, 5].length
  #     # => 5
  #
  # @return [Numeric] length
  def length
    `return self.length;`
  end

  alias_method :size, :length

  # Yields the block once for each element in `self`, passing that element as
  # a parameter.
  #
  # If no block is given, an enumerator is returned instead.
  #
  # @example
  #
  #     a = ['a', 'b', 'c']
  #     a.each { |x| puts x }
  #     # => 'a'
  #     # => 'b'
  #     # => 'c'
  #
  # **TODO** needs to return enumerator for no block.
  #
  # @return [Array] returns the receiver
  def each
    raise "Array#each no block given" unless block_given?

    `for (var i = 0, len = self.length; i < len; i++) {`
      yield `self[i]`
    `}`
    self
  end

  # Similar to {#each}, but also passes in the current element index to the
  # block.
  def each_with_index
    raise "Array#each_with_index no block given" unless block_given?

    `for (var i = 0, len = self.length; i < len; i++) {`
      yield `self[i]`, `i`
    `}`
    self
  end

  # Same as {#each}, but passes the index of the element instead of the 
  # element itself.
  #
  # If no block given, an enumerator is returned instead.
  #
  # **TODO** enumerator functionality not yet implemented.
  #
  # @example
  #
  #     a = [1, 2, 3]
  #     a.each_index { |x| puts x }
  #     # => 0
  #     # => 1
  #     # => 2
  #
  # @return [Array] returns receiver
  def each_index
    raise "Array#each_index no block given" unless block_given?

    `for (var i = 0, len = self.length; i < len; i++) {`
      yield `i`
    `}`
    self
  end

  # Append - pushes the given object(s) onto the end of this array. This
  # expression returns the array itself, so several appends may be chained
  # together.
  #
  # @example
  #
  #     a = ['a', 'b', 'c']
  #     a.push 'd', 'e', 'f'
  #     # => ['a', 'b', 'c', 'd', 'e', 'f'
  #
  # @param [Object] obj the object(s) to push onto the array
  # @return [Array] returns the receiver
  def push(*objs)
    `for (var i = 0, ii = objs.length; i < ii; i++) {
      self.push(objs[i]);
    }
    return self;`
  end

  # Returns the index of the first object in `self` such that it is `==` to
  # `obj`. If a block is given instead of an argument, returns first object for
  # which the block is true. Returns `nil` if no match is found. See also
  # {#rindex}.
  #
  # @example
  #
  #     a = ['a', 'b', 'c']
  #     a.index('a')              # => 0
  #     a.index('z')              # => nil
  #     a.index { |x| x == 'b' }  # => 1
  #
  # @param [Object] obj the object to look for
  # @return [Numeric, nil] result
  def index(obj)
    `for (var i = 0, len = self.length; i < len; i++) {
      if (#{`self[i]` == obj}.$r) {
        return i;
      }
    }

    return nil;`
  end

  # Concatenation - returns a new array built by concatenating the two arrays
  # together to produce a third array.
  #
  # @example
  #
  #     [1, 2, 3] + [4, 5]
  #     # => [1, 2, 3, 4, 5]
  #
  # @param [Array] other the array to concat with
  # @return [Array] returns new concatenated array
  def +(other)
    `return self.slice(0).concat(other.slice());`
  end

  # Difference. Creates a new array that is a copy of the original array,
  # removing any items that also appear in `other`.
  #
  # @example
  #
  #   [1, 2, 3, 3, 4, 4, 5] - [1, 2, 4]
  #   # => [3, 3, 5]
  #
  # @param [Array] other array to use for difference
  # @return [Array] new array
  def -(other)
    raise "Array#- not yet implemented"
  end

  # Equality. Two arrays are equal if they contain the same number of elements
  # and if each element is equal to (according to {BasicObject#==} the
  # corresponding element in the second array.
  #
  # @example
  #
  #     ['a', 'c'] == ['a', 'c', 7]       # => false
  #     ['a', 'c', '7'] == ['a', 'c', 7]  # => true
  #     ['a', 'c', 7] == ['a', 'd', 'f']  # => false
  #
  # @param [Array] other array to compare self with
  # @return [Boolean] if the arrays are equal
  def ==(other)
    `if (self.$h() == other.$h()) return true;
    if (self.length != other.length) return false;

    for (var i = 0; i < self.length; i++) {
      if (!#{`self[i]` == `other[i]`}) {
        return false;
      }
    }

    return true;`
  end

  # Searches through an array whose elements are also arrays, comparing `obj`
  # with their first element of each contained array using {BasicObject#==}.
  # Returns the first contained array that matches (that is, the first
  # associated array) or `nil` if no match is found. See also {#rassoc}.
  #
  # @example
  #
  #     s1 = ['colors', 'red', 'blue', 'green']
  #     s2 = ['letters', 'a', 'b', 'c']
  #     s3 = 'foo'
  #     a = [s1, s2, s3]
  #
  #     a.assoc 'letters'               # => ['letters', 'a', 'b', 'c']
  #     a.assoc 'foo'                   # => nil
  def assoc(obj)
    `var arg;

    for (var i = 0; i < self.length; i++) {
      arg = self[i];

      if (arg.length && #{`arg[0]` == obj}.$r) {
        return arg;
      }
    }

    return nil;`
  end

  # Returns the element at `index`. A negative index counts from the end of the
  # receiver. Returns `nil` if the given index is out of range. See also {#[]}.
  #
  # @example
  #
  #     a = ['a', 'b', 'c', 'd', 'e']
  #     a.at 0          # => 'a'
  #     a.at -1         # => 'e'
  #     a.at 324        # => nil
  #
  # @param [Numeric] index the index to get
  # @return [Object, nil] returns nil or the result
  def at(idx)
    `var size = self.length;

    if (idx < 0) idx += size;

    if (idx < 0 || idx >= size) return nil;
    return self[idx];`
  end

  # Removes all elements from the receiver.
  #
  # @example
  #
  #     a = ['a', 'b', 'c', 'd', 'e']
  #     a.clear   # => []
  #
  # @return [Array] returns the receiver
  def clear
    `self.splice(0);
    return self;`
  end

  # Yields the block, passing in successive elements from the receiver, 
  # returning an array containing those elements for which the block returns a
  # true value.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.select { |x| x > 4 }
  #     # => [5, 6]
  #
  # @return [Array] returns a new array of selected elements
  def select
    `var result = [], arg;

    for (var i = 0, ii = self.length; i < ii; i++) {
      arg = self[i];

      if (#{yield `arg`}.$r) {
        result.push(arg);
      }
    }

    return result;`
  end

  # Yields the block once for each element of the receiver. Creates a new array
  # containing the values returned by the block. See also `Enumerable#collect`.
  #
  # @example
  #
  #     a = ['a', 'b', 'c', 'd']
  #     a.collect { |x| x + '!' }     # => ['a!', 'b!', 'c!', 'd!']
  #     a                             # => ['a', 'b', 'c', 'd']
  #
  # @return [Array] new array
  def collect
    raise "Array#collect no block given" unless block_given?

    `var result = [];

    for (var i = 0, ii = self.length; i < ii; i++) {
      result.push(#{ yield `self[i]` });
    }

    return result;`
  end

  alias_method :map, :collect

  # Yields the block once for each element of `self`, replacing the element with
  # the value returned by the block. See also `Enumerable#collect`.
  #
  # @example
  #
  #     a = ['a', 'b', 'c', 'd']
  #     a.collect { |x| x + '!' }
  #     # => ['a!', 'b!', 'c!', 'd!']
  #     a
  #     # => ['a!', 'b!', 'c!', 'd!']
  #
  # @return [Array] returns the receiver
  def collect!
    `for (var i = 0, ii = self.length; i < ii; i++) {
      self[i] = #{yield `self[i]`};
    }

    return self;`
  end

  # Duplicate.
  def dup
    `return self.slice(0);`
  end

  # Returns a copy of the receiver with all nil elements removed
  #
  # @example
  #
  #     ['a', nil, 'b', nil, 'c', nil].compact
  #     # => ['a', 'b', 'c']
  #
  # @return [Array] new Array
  def compact
    `var result = [], length = self.length;

    for (var i = 0; i < length; i++) {
      if (self[i] != nil) {
        result.push(self[i]);
      }
    }

    return result;`
  end

  # Removes nil elements from the receiver. Returns nil if no changes were made,
  # otherwise returns self.
  #
  # @example
  #
  #     ['a', nil, 'b', nil, 'c'].compact!
  #     # => ['a', 'b', 'c']
  #
  #     ['a', 'b', 'c'].compact!
  #     # => nil
  #
  # @return [Array, nil] returns either the receiver or nil
  def compact!
    `var length = self.length;

    for (var i = 0; i < length; i++) {
      if (self[i] == nil) {
        self.splice(i, 1);
        i--;
      }
    }

    return length == self.length ? nil : self;`
  end

  # Appends the elements of `other` to `self`.
  #
  # @example
  #
  #     ['a', 'b'].concat ['c', 'd']
  #     # => ['a', 'b', 'c', 'd']
  #
  # @param [Array] other array to concat
  # @return [Array] returns the receiver
  def concat(other)
    `var length = other.length;

    for (var i = 0; i < length; i++) {
      self.push(other[i]);
    }

    return self;`
  end

  # Returns the number of elements. If an argument is given, counts the number
  # of elements which equals to `obj`. If a block is given, counts the number of
  # elements yielding a true value.
  #
  # @example
  #
  #     ary = [1, 2, 4, 2]
  #     ary.count     # => 4
  #     ary.count(2)  # =>2
  #
  # @param [Object] obj object to check
  # @return [Numeric] count or count of obj
  def count(obj = undefined)
    `if (obj != undefined) {
      var total = 0;

      for (var i = 0; i < self.length; i++) {
        if (#{`self[i]` == obj}.$r) {
          total++;
        }
      }

      return total;
    } else {
      return self.length;
    }`
  end

  # Deletes items from `self` that are equal to `obj`. If any items are found,
  # returns `obj`. If the item is not found, returns `nil`. If the optional code
  # block is given, returns the result of block if the item is not found.
  #
  # @example
  #
  #     a = ['a', 'b', 'b', 'b', 'c']
  #
  #     a.delete 'b'
  #     # => 'b'
  #     a
  #     # => ['a', 'c']
  #
  #     a.delete 'z'
  #     # => nil
  #
  # @param [Object] obj object to delete
  # @return [Object, nil] returns obj or nil
  def delete(obj)
    `var length = self.length;

    for (var i = 0; i < self.length; i++) {
      if (#{`self[i]` == obj}.$r) {
        self.splice(i, 1);
        i--;
      }
    }

    return length == self.length ? nil : obj;`
  end

  # Deletes the element at the specified index, returning that element, or nil
  # if the index is out of range. 
  #
  # @example
  #
  #     a = ['ant', 'bat', 'cat', 'dog']
  #     a.delete_at 2
  #     # => 'cat'
  #     a
  #     # => ['ant', 'bat', 'dog']
  #     a.delete_at 99
  #     # => nil
  #
  # @param [Numeric] idx the index to delete
  # @return [Object, nil] returns the deleted object or nil
  def delete_at(idx)
    `if (idx < 0) idx += self.length;
    if (idx < 0 || idx >= self.length) return nil;
    var res = self[idx];
    self.splice(idx, 1);
    return self;`
  end

  # Deletes every element of `self` for which `block` evaluates to true.
  #
  # @example
  #
  #     a = [1, 2, 3]
  #     a.delete_if { |x| x >= 2 }
  #     # => [1]
  #
  # @return [Array] returns amended receiver
  def delete_if
    `for (var i = 0, ii = self.length; i < ii; i++) {
      if (#{yield `self[i]`}.$r) {
        self.splice(i, 1);
        i--;
        ii = self.length;
      }
    }
    return self;`
  end


  # Drop first `n` elements from receiver, and returns remaining elements in
  # array.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.drop 3
  #     # => [4, 5, 6]
  #
  # @param [Number] n number of elements to drop
  # @return [Array] returns new array
  def drop(n)
    `if (n > self.length) return [];
    return self.slice(n);`
  end

  # Drop elements up to, but not including, the first element for which the
  # block returns nil or false, and returns an array containing the remaining
  # elements.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.drop_while { |i| i < 3 }
  #     # => [3, 4, 5, 6]
  #
  # @return [Array] returns a new array
  def drop_while
    `for (var i = 0; i < self.length; i++) {
      if (!#{yield `self[i]`}.$r) {
        return self.slice(i);
      }
    }

    return [];`
  end

  # Returns `true` if the receiver contains no elements, `false` otherwise.
  #
  # @example
  #
  #     [].empty?
  #     # => true
  #
  # @return [false, true] empty or not
  def empty?
    `return self.length == 0;`
  end

  # Tries to return the element as position `index`. If the index lies outside
  # the array, the first form throws an IndexError exception, the second form
  # returns `default`, and the third form returns the value of invoking the
  # block, passing in the index. Negative values of `index` count from the end
  # of the array.
  #
  # @example First form
  #
  #     a = [11, 22, 33, 44]
  #     a.fetch 1
  #     # => 22
  #     a.fetch -1
  #     # => 44
  #
  # @example Second form
  #
  #     a.fetch 4, 'cat'
  #     # => 'cat'
  #
  # @example Third form
  #
  #     a.fetch 4 { |i| i * i }
  #     # => 16
  #
  # @param [Numeric] idx
  # @param [Object] defaults
  # @return [Object] returns result
  def fetch(idx, defaults = undefined)
    `var original = idx;

    if (idx < 0) idx += self.length;
    if (idx < 0 || idx >= self.length) {
      if (defaults == undefined)
        raise(eIndexError, "Array#fetch");
      else if (__block__)
        return #{yield `original`};
      else
        return defaults;
    }

    return self[idx];`
  end

  # Returns the first element, or the first `n` elements, of the array. If the
  # array is empty, the first form returns `nil`, and the second form returns an
  # empty array.
  #
  # @example
  #
  #     a = ['q', 'r', 's', 't']
  #     a.first
  #     # => q
  #     a.first 2
  #     # => ['q', 'r']
  #
  # @param [Numeric] count number of elements
  # @return [Object, Array] object or array of objects
  def first(count = undefined)
    `if (count == undefined) {
      if (self.length == 0) return nil;
      return self[0];
    }
    return self.slice(0, count);`
  end

  # Returns a new array that is a one-dimensional flattening of this array
  # (recursively). That is, for evey element that is an array, extract its
  # elements into the new array. If the optional `level` argument determines the
  # level of recursion to flatten.
  #
  # @example
  #
  #     s = [1, 2, 3]
  #     # => [a, 2, 3]
  #     t = [4, 5, 6, [7, 8]]
  #     # => [4, 5, 6, [7, 8]]
  #     a = [s, t, 9, 10]
  #     # => [[1, 2, 3], [4, 5, 6, [7, 8]], 9, 10]
  #     a.flatten
  #     # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  #     a = [1, 2, [3, [4, 5]]]
  #     a.flatten 1
  #     # => [1, 2, 3, [4, 5]]
  #
  # @param [Numeric] level the level to flatten
  # @return [Array] returns new array
  def flatten(level = undefined)
    `var result = [], item;

    for (var i = 0; i < self.length; i++) {
      item = self[i];

      if (item.o$f & T_ARRAY) {
        if (level == undefined)
          result = result.concat(#{`item`.flatten});
        else if (level == 0)
          result.push(item);
        else
          result = result.concat(#{`item`.flatten `level - 1`});
      } else {
        result.push(item);
      }
    }

    return result;`
  end

  # Flattens the receiver in place. Returns `nil` if no modifications were made.
  # If the optional level argument determines the level of recursion to flatten.
  #
  # @example
  #
  #     a = [1, 2, [3, [4, 5]]]
  #     a.flatten!
  #     # => [1, 2, 3, 4, 5]
  #     a.flatten!
  #     # => nil
  #     a
  #     # => [1, 2, 3, 4, 5]
  #
  # @param [Number] level to flatten to
  # @return [Array] returns the receiver
  def flatten!(level = undefined)
    `var length = self.length;
    var result = #{self.flatten level};
    self.splice(0);

    for (var i = 0; i < result.length; i++) {
      self.push(result[i]);
    }

    if (self.length == length)
      return nil;

    return self;`
  end

  def grep(pattern)
    `var result = [], arg;

    for (var i = 0, ii = self.length; i < ii; i++) {
      arg = self[i];

      if (pattern.exec(arg)) {
        result.push(arg);
      }
    }

    return result;`
  end

  # Returns true if the given object is present in `self`, false otherwise.
  #
  # @example
  #
  #     a = ['a', 'b', 'c']
  #     a.include? 'b'
  #     # => true
  #     a.include? 'z'
  #     # => false
  def include?(member)
    `for (var i = 0; i < self.length; i++) {
      if (#{`self[i]` == member}) {
        return #{true};
      }
    }

    return #{false};`
  end

  def inject(initial = undefined)
    `if (initial === undefined) initial = self[0];
    var result;

    for (var i = 0, ii = self.length; i < ii; i++) {
      initial = #{ yield `initial`, `self[i]` };
    }

    return initial;`
  end

  # Replaces the contents of `self` with the contents of `other`, truncating or
  # expanding if necessary.
  #
  # @example
  #
  #     a = ['a', 'b', 'c', 'd', 'e']
  #     a.replace ['x', 'y', 'z']
  #     # => ['x', 'y', 'z']
  #     a
  #     # => ['x', 'y', 'z']
  #
  # @param [Array] other array to replace contents with
  # @return [Array] returns the receiver
  def replace(other)
    `self.splice(0);

    for (var i = 0; i < other.length; i++) {
      self.push(other[i]);
    }

    return self;`
  end

  # Inserts the given values before the element with the given index (which may
  # be negative).
  #
  # @example
  #
  #     a = ['a', 'b', 'c', 'd']
  #     a.insert 2, 99
  #     # => ['a', 'b', 99, 'c', 'd']
  #     a.insert -2, 1, 2, 3
  #     # => ['a', 'b', 99, 'c', 1, 2, 3, 'd']
  #
  # @param [Numeric] idx the index for insertion
  # @param [Object] objs objects to insert
  # @return [Array] returns the receiver
  def insert(idx, *objs)
    `var size = self.length;

    if (idx < 0) idx += size;

    if (idx < 0 || idx >= size)
      raise(eIndexError, "out of range");

    self.splice.apply(self, [idx, 0].concat(objs));
    return self;`
  end

  # Returns a string created by converting each element of the array to a string
  # seperated by `sep`.
  #
  # @example
  #
  #     ['a', 'b', 'c'].join
  #     # => 'abc'
  #     ['a', 'b', 'c'].join '-'
  #     # => 'a-b-c'
  #
  # @param [String] sep the separator
  # @return [String] joined string
  def join(sep = '')
    `var result = [];

    for (var i = 0; i < self.length; i++) {
      result.push(#{`self[i]`.to_s});
    }

    return result.join(sep);`
  end

  # Deletes every element of `self` for which the block evaluates to false.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.keep_if { |x| x < 4 }
  #     # => [1, 2, 3]
  #
  # @return [Array] returns the receiver
  def keep_if
    `for (var i = 0; i < self.length; i++) {
      if (!#{yield `self[i]`}.$r) {
        self.splice(i, 1);
        i--;
      }
    }

    return self;`
  end

  # Return the last element(s) of `self`. If the array is empty, the first form
  # returns `nil`.
  #
  # @example
  #
  #     a = ['w', 'x', 'y', 'z']
  #     a.last
  #     # => 'z'
  #     a.last 2
  #     # => ['y', 'z']
  #
  # @param [Number] count the number of items to get
  # @return [Object, Array] result
  def last(count = undefined)
    `var size = self.length;

    if (count == undefined) {
      if (size == 0) return nil;
      return self[size - 1];
    } else {
      if (count > size) count = size;
      return self.slice(size - count, size);
    }`
  end

  # Removes the last element from `self` and returns it, or `nil` if the array
  # is empty. If a count is given, returns an array of the last `count`
  # elements (or less).
  #
  # @example
  #
  #     a = ['a', 'b', 'c', 'd']
  #     a.pop
  #     # => 'd'
  #     a.pop 2
  #     # => 'b', 'c'
  #     a
  #     # => ['a']
  #
  # @param [Numeric] count number to pop
  # @return [Array] returns popped items
  def pop(count = undefined)
    `var size = self.length;

    if (count == undefined) {
      if (size) return self.pop();
      return nil;
    } else {
      return self.splice(size - count, size);
    }`
  end

  # Searches through the array whose elements are also arrays. Compares `obj`
  # with the second element of each contained array using `==`. Returns the
  # first contained array that matches.
  #
  # @example
  #
  #     a = [[1, 'one'], [2, 'two'], [3, 'three'], ['ii', 'two']]
  #     a.rassoc 'two'
  #     # => [2, 'two']
  #     a.rassoc 'four'
  #     # => nil
  #
  # @param [Object] obj object to search for
  # @return [Object, nil] result or nil
  def rassoc(obj)
    `var test;

    for (var i = 0; i < self.length; i++) {
      test = self[i];
      if (test.o$f & T_ARRAY && test[1] != undefined) {
        if (#{`test[1]` == obj}.$r) return test;
      }
    }

    return nil;`
  end

  # Returns a new array containing the items in `self` for which the block is
  # not true. See also `#delete_if`.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.reject { |x| x > 3 }
  #     # => [1, 2, 3]
  #     a
  #     # => [1, 2, 3, 4, 5, 6]
  #
  # @return [Array] returns the receiver
  def reject
    `var result = [];

    for (var i = 0; i < self.length; i++) {
      if (!#{yield `self[i]`}.$r) {
        result.push(self[i]);
      }
    }

    return result;`
  end

  # Equivalent to `#delete_if!`, deleting elements from self for which the block
  # evaluates to true, but returns nil if no changes were made.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.reject! { |x| x > 3 }
  #     # => [1, 2, 3]
  #     a.reject! { |x| x > 3 }
  #     # => nil
  #     a
  #     # => [1, 2, 3]
  #
  # @return [Array] returns receiver
  def reject!
    `var length = self.length;

    for (var i = 0; i < self.length; i++) {
      if (#{yield `self[i]`}.$r) {
        self.splice(i, 1);
        i--;
      }
    }

    return self.length == length ? nil : self;`
  end

  # Returns a new array containing the receiver's elements in reverse order.
  #
  # @example
  #
  #     ['a', 'b', 'c'].reverse
  #     # => ['c', 'b', 'a']
  #     [1].reverse
  #     # => [1]
  #
  # @return [Array] return new array
  def reverse
    `var result = [];

    for (var i = self.length - 1; i >= 0; i--) {
      result.push(self[i]);
    }

    return result;`
  end

  # Reverses the receiver in place.
  #
  # @example
  #
  #     a = ['a', 'b', 'c']
  #     a.reverse!
  #     # => ['c', 'b', 'a']
  #     a
  #     # => ['c', 'b', 'a']
  #
  # @return [Array] returns the receiver
  def reverse!
    `var length = self.length / 2, tmp;

    for (var i = 0; i < length; i++) {
      tmp = self[i];
      self[i] = self[self.length - (i + 1)];
      self[self.length - (i + 1)] = tmp;
    }

    return self;`
  end

  # Same as {#each}, but traverses the receiver in reverse order
  #
  # @example
  #
  #     a = ['a', 'b', 'c']
  #     a.reverse_each { |x| puts x }
  #     # => 'c'
  #     # => 'b'
  #     # => 'a'
  #
  # @return [Array] returns the receiver
  def reverse_each
    `var ary = self, len = ary.length;

    for (var i = len - 1; i >= 0; i--) {
      #{yield `ary[i]`};
    }

    return self;`
  end

  # Returns the index of the last object in self that is == to object. If a 
  # block is given instead of an argument, returns the first object for which
  # block is true, starting from the last object. Returns `nil` if no match is
  # found.
  #
  # @example
  #
  #     a = ['a', 'b', 'b', 'b', 'c']
  #     a.rindex 'b'
  #     # => 3
  #     a.rindex 'z'
  #     # => nil
  #     a.rindex { |x| x == 'b' }
  #     # => 3
  #
  # @return [Object, nil] returns result or nil
  def rindex(obj = undefined)
    `if (obj != undefined) {
      for (var i = self.length - 1; i >=0; i--) {
        if (#{`self[i]` == obj}.$r) {
          return i;
        }
      }
    } else if (true || __block__) {
      raise(eException, "Array#rindex needs to do block action");
    }

    return nil;`
  end

  # Invokes the block passing in successive elements from `self`, deleting the
  # elements for which the block returns a false value. It returns `self` if
  # changes were made, otherwise it returns `nil`.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.select! { |x| x > 4 }
  #     # => [5, 6]
  #     a.select! { |x| x > 4 }
  #     # => nil
  #     a
  #     # => [5, 6]
  #
  # @return [Array] returns receiver
  def select!
    `var length = self.length;

    for (var i = 0; i < self.length; i++) {
      if (!#{yield `self[i]`}.$r) {
        self.splice(i, 1);
        i--;
      }
    }

    return self.length == length ? nil : self;`
  end

  # Returns the first element of `self` and removes it (shifting all other
  # elements down by one). Returns `nil` if the array is empty.
  #
  # If a number `n` is given, returns an array of the first n elements (or 
  # less), just like `#slice` does.
  #
  # @example
  #
  #     a = ['a', 'b', 'c']
  #     a.shift
  #     # => 'a'
  #     a
  #     # => ['b', 'c']
  #     a = ['a', 'b', 'c']
  #     a.shift 2
  #     # => ['a', 'b']
  #     a
  #     # => ['c']
  #
  # @param [Numeric] count elements to shift
  # @return [Array] result
  def shift(count = undefined)
    `if (count != undefined)
      return self.splice(0, count);

    if (self.length)
      return self.shift();

    return nil;`
  end

  # Deletes the element(s) given by an `index` (optionally with a length) or
  # by a range. Returns the deleted object(s), or `nil` if the index is out of
  # range.
  #
  # @example
  #
  #     a = ['a', 'b', 'c']
  #     a.slice! 1
  #     # => 'b'
  #     a
  #     # => ['a', 'c']
  #     a.slice! -1
  #     # => 'c'
  #     a
  #     # => ['a']
  #     a.slice! 100
  #     # => nil
  #
  # **TODO** does not yet work with ranges
  #
  # @param [Range, Number] index to begin with
  # @param [Number] length last index
  # @return [Array, nil] result
  def slice!(index, length = nil)
    `var size = self.length;

    if (index < 0) index += size;

    if (index >= size || index < 0) return nil;

    if (length != nil) {
      if (length <= 0 || length > self.length) return nil;
      return self.splice(index, index + length);
    } else {
      return self.splice(index, 1)[0];
    }`
  end

  # Returns first `count` elements from ary.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.take 3
  #     # => [1, 2, 3]
  #
  # @return [Array] array of elements
  def take(count)
    `return self.slice(0, count);`
  end


  # Passes elements to the block until the block returns a false value, then
  # stops iterating and returns an array of all prior elements.
  #
  # @example
  #
  #     a = [1, 2, 3, 4, 5, 6]
  #     a.take_while { |i| i < 3 }
  #     # => [1, 2]
  #
  # @return [Array] new array with elements
  def take_while
    `var result = [], arg;

    for (var i = 0, ii = self.length; i < ii; i++) {
      arg = self[i];
      if (#{yield `arg`}.$r) {
        result.push(self[i]);
      } else {
        break;
      }
    }

    return result;`
  end

  # Returns the receiver.
  #
  # @example
  #
  #     a = [1, 2, 3]
  #     a.to_a
  #     # => [1, 2, 3]
  #
  # @return [Array] returns the receiver
  def to_a
    self
  end

  # Returns a new array by removing duplicate values in `self`.
  #
  # @example
  #
  #     a = ['a', 'a', 'b', 'b', 'c']
  #     a.uniq
  #     # => ['a', 'b', 'c']
  #     a
  #     # => ['a', 'a', 'b', 'b', 'c']
  #
  # @return [Array]
  def uniq
    `var result = [], seen = [];

    for (var i = 0; i < self.length; i++) {
      var test = self[i], hash = test.$h();
      if (seen.indexOf(hash) == -1) {
        seen.push(hash);
        result.push(test);
      }
    }

    return result;`
  end

  # Removes duplicate elements from `self`. Returns `nil` if no changes are
  # made (that is, no duplicates are found).
  #
  # @example
  #
  #     a = ['a', 'a', 'b', 'b', 'c']
  #     a.uniq!
  #     # => ['a', 'b', 'c']
  #     a.uniq!
  #     # => nil
  #
  # @return [Array] returns receiver
  def uniq!
    `var seen = [], length = self.length;

    for (var i = 0; i < self.length; i++) {
      var test = self[i], hash = test.$h();
      if (seen.indexOf(hash) == -1) {
        seen.push(hash);
      } else {
        self.splice(i, 1);
        i--;
      }
    }

    return self.length == length ? nil : self;`
  end

  # Prepends objects to the front of `self`, moving other elements upwards.
  #
  # @example
  #
  #     a = ['b', 'c', 'd']
  #     a.unshift 'a'
  #     # => ['a', 'b', 'c', 'd']
  #     a.unshift 1, 2
  #     # => [1, 2, 'a', 'b', 'c', 'd']
  #
  # @param [Object] objs objects to add
  # @return [Array] returns the receiver
  def unshift(*objs)
    `for (var i = objs.length - 1; i >= 0; i--) {
      self.unshift(objs[i]);
    }

    return self;`
  end

  # Set intersection - Returns a new array containing elements common to the
  # two arrays, with no duplicates.
  #
  # @example
  #
  #     [1, 1, 3, 5] & [1, 2, 3]
  #     # => [1, 3]
  #
  # @param [Array] other second array to intersect
  # @return [Array] new intersected array
  def &(other)
    `var result = [], seen = [];

    for (var i = 0; i < self.length; i++) {
      var test = self[i], hash = test.$h();

      if (seen.indexOf(hash) == -1) {
        for (var j = 0; j < other.length; j++) {
          var test_b = other[j], hash_b = test_b.$h();

          if ((hash == hash_b) && seen.indexOf(hash) == -1) {
            seen.push(hash);
            result.push(test);
          }
        }
      }
    }

    return result;`
  end

  # Repitition - When given a string argument, acts the same as {#join}.
  # Otherwise, returns a new array build by concatenating the `num` copies of
  # self.
  #
  # @example With Number
  #
  #     [1, 2, 3] * 3
  #     # => [1, 2, 3, 1, 2, 3, 1, 2, 3]
  #
  # @example With String
  #
  #     [1, 2, 3] * ','
  #     # => '1,2,3'
  #
  # @param [String, Number] num string or number used to join or concat
  # @return [String, Array] depending on argument
  def *(arg)
    `if (arg.o$f & T_STRING) {
      return #{self.join `arg`};
    } else {
      var result = [];
      for (var i = 0; i < parseInt(arg); i++) {
        result = result.concat(self);
      }

      return result;
    }`
  end

  # Element Reference - Returns the element at `index`, or returns a subarray
  # at index and counting for length elements, or returns a subarray if index
  # is a range. Negative indecies count backward from the end of the array (-1
  # is the last element). Returns `nil` if the index (or starting index) are
  # out of range.
  #
  # @example
  #
  #     a = ['a', 'b', 'c', 'd', 'e']
  #     a[2] + a[0] + a[1]              # => 'cab'
  #     a[6]                            # => nil
  #     a[1, 2]                         # => ['b', 'c']
  #     a[1..3]                         # => ['b', 'c', 'd']
  #     a[4..7]                         # => ['e']
  #     a[6..10]                        # => nil
  #     a[-3, 3]                        # => ['c', 'd', 'e']
  #     a[5]                            # => nil
  #     a[5, 1]                         # => []
  #     a[5..10]                        # => []
  #
  # **TODO** does not yet work with ranges
  #
  # @param [Range, Numeric] index to begin
  # @param [Numeric] length last index
  # @return [Array, Object, nil] result
  def [](index, length = undefined)
    `var ary = self, size = ary.length;

    if (index < 0) index += size;

    if (index >= size || index < 0) return nil;

    if (length != undefined) {
      if (length <= 0) return [];
      return ary.slice(index, index + length);
    } else {
      return ary[index];
    }`
  end

  # Element reference setting.
  #
  # **TODO** need to expand functionlaity.
  def []=(index, value)
    `if (index < 0) index += self.length;
    return self[index] = value;`
  end
end

