# A `Hash` is a collection of key-value pairs. It is similar to an array except
# that indexing is done via arbitrary keys of any object type, not an integer
# index. Hahses enumerate their values in the order that the corresponding keys
# were inserted.
#
# Hashes have a default value that is returned when accessing keys that do not
# exist in the hash. By default, that valus is `nil`.
#
# Implementation details
# ----------------------
#
# An Opal hash is actually toll-free bridged to a custom javascript
# prototype called RHash. This is all handled internally and is actually
# just an implementation detail, and is only done for the convenience of
# construction through literals and methods such as {Hash.new}.
#
# Although its syntax is similar to that of an object literal in
# javascript, it is very important to know that they are completely
# different, and a javascript/json object cannot be used in place of a
# ruby hash. All ruby objects require, at minimum, a `.$m` property
# which is their method table. When trying to send a message to a non
# ruby object, like a javascript object, errors will start occuring when
# this method table is not found.
#
# Hash and the JSON gem contain methods for converting native objects into
# `Hash` instances, so those should be used if you need to use objects from
# an external javascript library.
#
# Ruby compatibility
# ------------------
#
# `Hash` implements the majority of methods from the ruby standard
# library, and those that are not implemented are being added
# constantly.
#
# The `Enumerable` module is not yet implemented in opal, so most of the
# relevant methods used by `Hash` are implemented directly into this class.
# When `Enumerable` gets implemented, the relevant methods will be moved
# back into that module.
class Hash
  # Creates a new hash populated with the given objects.
  #
  # @return [Hash]
  def self.[] (*args)
    `$rb.H.apply(null, args)`
  end

  def self.allocate
    `$rb.H()`
  end

  def self.new (obj=nil, &block)
    hash = allocate

    if block_given?
      `hash.df = block`
    else
      `hash.d = obj`
    end
  end

  # Returns a new array populated with the values from `self`.
  #
  # @example
  #
  #     { :a => 1, :b => 2 }.values
  #     # => [1, 2]
  #
  # @return [Array]
  def values
    `
      var result = [];

      for (var i = 0, length = self.k.length; i < length; i++) {
        result.push(self.a[self.k[i].$h()]);
      }

      return result;
    `
  end

  # Searches through the hash comparing `obj` with the key ysing ==. Returns the
  # key-value pair (two element array) or nil if no match is found.
  #
  # @example
  #
  #     h = { 'a' => [1, 2, 3], 'b' => [4, 5, 6] }
  #     h.assoc 'a'
  #     # => ['a', [1, 2, 3]]
  #     h.assoc 'c'
  #     # => nil
  #
  # @param [Object] obj key to search for
  # @return [Array<Object, Object>, nil] result or nil
  def assoc (obj)
    `
      var key, keys = self.k, length = keys.length;

      for (var i = 0; i < length; i++) {
        key = keys[i];
        if (#{`key` == obj}.$r) {
          return [key, self.a[key.$h()]];
        }
      }
    `
  end

  # Equality - Two hashes are equal if they each contain the same number of keys
  # and if each key-value paid is equal, according to {BasicObject#==}, to the
  # corresponding elements in the other hash.
  #
  # @example
  #
  #     h1 = { 'a' => 1, 'c' => 2 }
  #     h2 = { 7 => 35, 'c' => 2, 'a' => 1 }
  #     h3 = { 'a' => 1, 'c' => 2, 7 => 35 }
  #     h4 = { 'a' => 1, 'd' => 2, 'f' => 35 }
  #
  #     h1 == h2    # => false
  #     h2 == h3    # => true
  #     h3 == h4    # => false
  #
  # @param [Hash] other the hash to compare with
  # @return [true, false]
  def == (other)
    `
      if (self === other) {
        return true;
      }
      else if (!other.k || !other.a) {
        return false;
      }
      else if (self.k.length != other.k.length) {
        return false;
      }

      for (var i = 0, length = self.k.length; i < length; i++) {
        var key = self.k[i], assoc1 = key.$h();

        if (!other.a.hasOwnProperty(assoc1)) {
          return false;
        }

        var assoc2 = other.a[assoc1];

        if (!#{`self.a[assoc1]` == `assoc2`}.$r) {
          return false;
        }
      }
    `

    true
  end

  alias_method :eql?, :==

  # Element reference - retrieves the `value` object corresponding to the `key`
  # object. If not found, returns the default value.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h['a']
  #     # => 100
  #     h['c']
  #     # => nil
  #
  # @param [Object] key the key to look for
  # @return [Object] result or default value
  def [] (key)
    `
      var assoc = key.$h();

      if (self.a.hasOwnProperty(assoc)) {
        return self.a[assoc];
      }

      return self.df ? self.df(self, key) : self.d;
    `
  end

  # Element assignment - Associates the value given by 'value' with the key
  # given by 'key'. `key` should not have its value changed while it is used as
  # a key.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h['a'] = 9
  #     h['c'] = 4
  #     h
  #     # => { 'a' => 9, 'b' => 200, 'c' => 4 }
  #
  # @param [Object] key the key for hash
  # @param [Object] value the value for the key
  # @return [Object] returns the set value
  def []=(key, value)
    `
      var assoc = key.$h();

      if (!self.a.hasOwnProperty(assoc)) {
        self.k.push(key);
      }

      return self.a[assoc] = value;
    `
  end

  # Remove all key-value pairs from `self`.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.clear
  #     # => {}
  #
  # @return [Hash]
  def clear
    `
      self.k = [];
      self.a = {};
    `

    self
  end

  # Returns the default value for the hash.
  def default
    `self.d`
  end

  # Sets the default value - the value returned when a key does not exist.
  #
  # @param [Object] obj the new default
  # @return [Object] returns the new default
  def default= (object)
    `self.d = object`
  end

  def default_proc
    `self.df`
  end

  def default_proc= (d=nil, &block)
    `self.df = d || block`
  end

  # Deletes and returns a key-value pair from self whose key is equal to `key`.
  # If the key is not found, returns the default value. If the optional code
  # block is given and the key is not found, pass in the key and return the
  # result of the block.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.delete 'a'
  #     # => 100
  #     h.delete 'z'
  #     # => nil
  #
  # @param [Object] key the key to delete
  # #return [Object] returns value or default value
  def delete (key)
    `
      var assoc = key.$h();

      if (self.a.hasOwnProperty(assoc)) {
        var ret = self.a[assoc];
        delete self.a[assoc];
        self.k.splice(self.$keys.indexOf(key), 1);

        return ret;
      }
    `

    if block_given?
      yield key
    else
      default
    end
  end

  # Deletes every key-value pair from `self` for which the block evaluates to
  # `true`.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200, 'c' => 300 }
  #     h.delete_if { |k, v| key >= 'b' }
  #     # => { 'a' => 100 }
  #
  # @return [Hash] returns the receiver
  def delete_if
    return enum_for :delete_if unless block_given?

    `
      var key, value;

      for (var i = 0; i < self.k.length; i++) {
        key   = self.k[i];
        value = self.a[key.$h()];

        if (#{yield `key`, `value`}.$r) {
          delete self.a[key.$h()];
          self.k.splice(i, 1);

          i--;
        }
      }
    `

    self
  end

  # Yields the block once for each key in `self`, passing the key-value pair
  # as parameters.
  #
  # @example
  #
  #     { 'a' => 100, 'b' => 200 }.each { |k, v| puts "#{k} is #{v}" }
  #     # => "a is 100"
  #     # => "b is 200"
  #
  # @return [Hash] returns the receiver
  def each
    return enum_for :each unless block_given?

    `
      var keys = self.k, values = self.a, length = keys.length, key;

      for (var i = 0; i < length; i++) {
        key = keys[i];

        #{yield `key`, `values[key.$h()]`};
      }
    `

    self
  end

  alias_method :each_pair, :each

  # Yields the block once for each key in `self`, passing the key as a param.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200, 'c' => 300 }
  #     h.each_key { |key| puts key }
  #     # => 'a'
  #     # => 'b'
  #     # => 'c'
  #
  # @return [Hash] returns receiver
  def each_key
    return enum_for :each_key unless block_given?

    `
      for (var i = 0, length = self.k.length; i < length; i++) {
        #{yield `self.k[i]`};
      }
    `

    self
  end

  # Yields the block once for each key in self, passing the associated value
  # as a param.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.each_value { |a| puts a }
  #     # => 100
  #     # => 200
  #
  # @return [Hash] returns the receiver
  def each_value
    return enum_for :each_value unless block_given?

    `
      for (var i = 0, length = self.k.length; i < length; i++) {
        #{yield `self.a[self.k[i].$h()]`};
      }
    `

    self
  end

  # Returns `true` if `self` contains no key-value pairs, `false` otherwise.
  #
  # @example
  #
  #     {}.empty?
  #     # => true
  #
  # @return [true, false]
  def empty?
    `self.k.length == 0`
  end

  # Returns a value from the hash for the given key. If the key can't be found,
  # there are several options; with no other argument, it will raise a
  # KeyError exception; if default is given, then that will be returned, if the
  # optional code block if specified, then that will be run and its value
  # returned.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.fetch 'a'         # => 100
  #     h.fetch 'z', 'wow'  # => 'wow'
  #     h.fetch 'z'         # => KeyError
  #
  # @param [Object] key the key to lookup
  # @param [Object] defaults the default value to return
  # @return [Object] value from hash
  def fetch (key, d = `undefined`)
    `
      var value = self.a[key.$h()];

      if (value != undefined) {
        return value;
      }
      else if (#{block_given?}) {
        #{yield key};
      }
      else if (d === undefined) {
        #{raise KeyError, 'key not found'};
      }
      else {
        return d;
      }
    `
  end

  # Returns a new array that is a one dimensional flattening of this hash. That
  # is, for every key or value that is an array, extraxt its elements into the
  # new array. Unlike {Array#flatten}, this method does not flatten
  # recursively by default. The optional `level` argument determines the level
  # of recursion to flatten.
  #
  # @example
  #
  #     a = { 1 => 'one', 2 => [2, 'two'], 3 => 'three' }
  #     a.flatten
  #     # => [1, 'one', 2, [2, 'two'], 3, 'three']
  #     a.flatten(2)
  #     # => [1, 'one', 2, 2, 'two', 3, 'three']
  #
  # @param [Numeric] level the level to flatten until
  # @return [Array] flattened hash
  def flatten (level = 1)
    `
      var result = [], key, value;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key   = self.k[i];
        value = self.a[key.$h()];

        result.push(key);

        if (value instanceof Array) {
          if (level == 1) {
            result.push(value);
          }
          else {
            result = result.concat(#{`value`.flatten(level - 1)});
          }
        }
        else {
          result.push(value);
        }
      }

      return result;
    `
  end

  # Returns `true` if the given `key` is present in `self`.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.has_key? 'a'
  #     # => true
  #     h.has_key? 'c'
  #     # => false
  #
  # @param [Object] key the key to check
  # @return [true, false]
  def has_key? (key)
    `
      if (self.a.hasOwnProperty(key.$h())) {
        return true;
      }
    `

    false
  end

  alias_method :include?, :has_key?
  alias_method :key?,     :has_key?
  alias_method :member?,  :has_key?

  # Returns `true` if the given `value` is present for some key in `self`.
  #
  # @example
  #
  #     h = { 'a' => 100 }
  #     h.has_value? 100
  #     # => true
  #     h.has_value? 2020
  #     # => false
  #
  # @param [Object] value the value to check for
  # @return [true, false]
  def has_value? (value)
    `
      var key, value;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key = self.k[i];
        val = self.a[key.$h()];

        if (#{`value` == `val`}.$r) {
          return true;
        }
      }
    `

    false
  end

  alias_method :value?, :has_value?

  # Replaces the contents of `self` with the contents of `other`.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.replace({ 'c' => 200, 'd' => 300 })
  #     # => { 'c' => 200, 'd' => 300 }
  #
  # @param [Hash] other hash to replace with
  # @return [Hash] returns receiver
  def replace (other)
    `
      self.k = []; self.a = {};

      for (var i = 0, length = other.k.length; i < length; i++) {
        var key = other.k[i];
        var val = other.a[key.$h()];

        self.k.push(key);
        self.a[key.$h()] = val;
      }
    `

    self
  end

  # Returns a new hash created by using `self`'s vales as keys, and keys as
  # values.
  #
  # @example
  #
  #     h = { 'n' => 100, 'm' => 100, 'y' => 300 }
  #     h.invert
  #     # => { 100 => 'm', 300 => 'y' }
  #
  # @return [Hash] inverted hash
  def invert
    `
      var hash = #{Hash.allocate}, key, val;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key = self.k[i];
        val = self.a[key.$h()];

        hash.k.push(val);
        hash.a[val.$h()] = key;
      }

      return hash;
    `
  end

  def keep_if
    return enum_for :keep_if unless block_given?

    delete_if {|key, value|
      !yield key, value
    }
  end

  # Returns the key for the given value. If not found, returns `nil`.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.key 200
  #     # => 'b'
  #     h.key 300
  #     # => nil
  #
  # @param [Object] value the value to check for
  # @return [Object] key or nil
  def key (value)
    `
      var key, val;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key = self.k[i];
        val = self.a[key.$h()];

        if (#{`value` == `val`}.$r) {
          return key;
        }
      }
    `
  end

  # Returns a new array populated with the keys from this hash. See also
  # {#values}.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.keys
  #     # => ['a', 'b']
  #
  # @return [Array]
  def keys
    `self.k.slice(0)`
  end

  # Returns the number of key-value pairs in the hash.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     h.length
  #     # => 2
  #
  # @return [Numeric]
  def length
    `self.k.length`
  end

  alias_method :size, :length

  # Returns a new hash containing the contents of `other` and `self`. If no
  # block is specified, the value for the entries with duplicate keys will be 
  # that of `other`. Otherwise the value for each duplicate key is determined
  # by calling the block with the key and its value in self, and its value in
  # other.
  #
  # @example
  #
  #     h1 = { 'a' => 100, 'b' => 200 }
  #     h2 = { 'b' => 300, 'c' => 400 }
  #     h1.merge h2
  #     # => {'a' => 100, 'b' => 300, 'c' => 400 }
  #     h1
  #     # => {'a' => 100, 'b' => 200}
  #
  # @param [Hash] other hash to merge with
  # #return [Hash] returns new hash
  def merge (other)
    `
      var result = $opal.H(), key, val;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key = self.k[i];
        val = self.a[key.$h()];

        result.k.push(key);
        result.a[key.$h()] = val;
      }

      for (var i = 0, length = other.k.length; i < length; i++) {
        key = other.k[i];
        val = other.a[key.$h()];

        if (!result.a.hasOwnProperty(key.$h())) {
          result.k.push(key);
        }

        if (result.a.hasOwnProperty(key.$h()) && #{block_given?}) {
          result.a[key.$h()] = #{yield `key`, `result.a[key.$h()]`, `val`};
        }
        else {
          result.a[key.$h()] = val;
        }
      }

      return result;
    `
  end

  # Merges the contents of `other` into `self`. If no block is given, entries
  # with duplicate keys are overwritten with values from `other`.
  #
  # @example
  #
  #     h1 = { 'a' => 100, 'b' => 200 }
  #     h2 = { 'b' => 300, 'c' => 400 }
  #     h1.merge! h2
  #     # => { 'a' => 100, 'b' => 300, 'c' => 400 }
  #     h1
  #     # => { 'a' => 100, 'b' => 300, 'c' => 400 }
  #
  # @param [Hash] other
  # @return [Hash]
  def merge! (other)
    `
      var key, val;

      for (var i = 0, length = other.k.length; i < length; i++) {
        key = other.k[i];
        val = other.a[key.$h()];

        if (!self.a.hasOwnProperty(key.$h())) {
          self.k.push(key);
        }

        if (self.a.hasOwnProperty(key.$h()) && #{block_given?}) {
          self.a[key.$h()] = #{yield `key`, `self.a[key.$h()]`, `val`};
        }
        else {
          self.a[key.$h()] = val;
        }
      }
    `

    self
  end

  # Searches through the hash comparing `obj` with the value using ==. Returns 
  # the first key-value pair, as an array, that matches.
  #
  # @example
  #
  #     a = { 1 => 'one', 2 => 'two', 3 => 'three' }
  #     a.rassoc 'two'
  #     # => [2, 'two']
  #     a.rassoc 'four'
  #     # => nil
  #
  # @param [Object] obj object to check
  # @return [Array]
  def rassoc (obj)
    `
      var key, val;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key = self.k[i];
        val = self.a[key.$h()];

        if (#{`val` == obj}.$r) {
          return [key, val];
        }
      }
    `
  end

  def reject (&block)
    dup.delete_if &block
  end

  # Removes a key-value pair from the hash and returns it as a two item array.
  # Returns the default value if the hash is empty.
  #
  # @example
  #
  #     h = { 'a' => 1, 'b' => 2 }
  #     h.shift
  #     # => ['a', 1]
  #     h
  #     # => { 'b' => 2 }
  #     {}.shift
  #     # => nil
  #
  # @return [Array, Object]
  def shift
    `
      var key, val;

      if (self.k.length > 0) {
        key = self.k[0];
        val = self.a[key.$h()];

        self.k.shift();
        delete self.a[key.$h()];

        return [key, val];
      }

      return self.d;
    `
  end

  # Convert self into a nested array of `[key, value]` arrays.
  #
  # @example
  #
  #     h = { 'a' => 1, 'b' => 2, 'c' => 3 }
  #     h.to_a
  #     # => [['a', 1], ['b', 2], ['c', 3]]
  #
  # @return [Array]
  def to_a
    `
      var result = [], key, value;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key   = self.k[i];
        value = self.a[key.$h()];

        result.push([key, value]);
      }

      return result;
    `
  end

  # Returns a simple string representation of the hash's keys and values.
  #
  # @return [String]
  def to_s
    `
      var description = [], key, value;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key   = self.k[i];
        value = self.a[key.$h()];

        description.push(#{`key`.inspect} + #{`value`.inspect});
      }

      return description.join('');
    `
  end

  # Returns self.
  #
  # @return [Hash]
  def to_hash
    self
  end

  # Returns the contents of this hash as a string.
  #
  # @example
  #
  #     h = { 'a' => 100, 'b' => 200 }
  #     # => "{ \"a\" => 100, \"b\" => 200 }"
  #
  # @return [String]
  def inspect
    `
      var description = [], key, value;

      for (var i = 0, length = self.k.length; i < length; i++) {
        key   = self.k[i];
        value = self.a[key.$h()];

        description.push(#{`key`.inspect} + '=>' + #{`value`.inspect});
      }

      return '{' + description.join(', ') + '}';
    `
  end
end

