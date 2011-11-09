class Hash
  include Enumerable

  def self.[](*args)
    `$rb.H.apply(null, args)`
  end

  def self.allocate
    `$rb.H()`
  end

  def self.new(default = nil, &block)
    hash = allocate

    if block_given?
      `hash.proc = block;`
    else
      `hash.none = #{default};`
    end

    hash
  end

  def ==(other)
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

      var keys    = self.k,
          values  = self.a,
          values2 = other.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i],
            assoc = key.$h();

        if (!values2.hasOwnProperty(assoc)) {
          return false;
        }

        if (!#{`values[assoc]` == `values2[assoc]`}) {
          return false;
        }
      }
    `

    true
  end

  def [](key)
    `
      var hash = #{key}.o$h(), val;

      if (val = self.map[hash]) {
        return val[1];
      }

      return self.none;
    `
  end

  def []=(key, value)
    `
      var hash = #{key}.o$h(), val;

      self.map[hash] = [key, value];
      return value;
    `
  end

  def assoc(object)
    `
      for (var i = 0, keys = self.k, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (#{`key` == object}) {
          return [key, self.a[key.$h()]];
        }
      }
    `
  end

  def clear
    `
      self.k = [];
      self.a = {};
    `

    self
  end

  def clone
    result = self.class.allocate

    `
      result.k = rb_clone(self.k);
      result.a = rb_clone(self.a);
    `

    result
  end

  def compare_by_identity(*)
    raise NotImplementedError, 'Hash#compare_by_identity not yet implemented'
  end

  def compare_by_identity?(*)
    raise NotImplementedError, 'Hash#compare_by_identity? not yet implemented'
  end

  def default
    `self.d`
  end

  def default=(object)
    `self.d = object`
  end

  def default_proc
    `self.df`
  end

  def default_proc=(default = nil, &block)
    `self.df = #{default} || block`
  end

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

  def delete_if
    return enum_for :delete_if unless block_given?

    `
      var keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i],
            value = values[key.$h()];

        if (#{yield `key`, `value`}) {
          delete values[key.$h()];
          keys.splice(i, 1);

          i--; length--;
        }
      }
    `

    self
  end

  def each
    return enum_for :each unless block_given?

    `
      var keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        #{yield `key`, `values[key.$h()]`};
      }
    `

    self
  end

  def each_key
    return enum_for :each_key unless block_given?

    `
      var keys = self.k;

      for (var i = 0, length = keys.length; i < length; i++) {
        #{yield `keys[i]`};
      }
    `

    self
  end

  alias_method :each_pair, :each

  def each_value
    return enum_for :each_value unless block_given?

    `
      var keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        #{yield `values[keys[i].$h()]`};
      }
    `

    self
  end

  def empty?
    `self.k.length == 0`
  end

  alias_method :eql?, :==

  def fetch(key, default = undefined)
    `
      var value = self.a[key.$h()];

      if (value !== undefined) {
        return value;
      }
      else if (#{block_given?}) {
        #{yield key};
      }
      else if (#{default} === undefined) {
        #{raise KeyError, 'key not found'};
      }
      else {
        return #{default};
      }
    `
  end

  def flatten(level = 1)
    `
      var result = [],
          keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i],
            value = values[key.$h()];

        result.push(key);

        if (#{Object === `item` && `item`.is_a?(Array)}) {
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

  def has_key?(key)
    %x{
      if (self.a.hasOwnProperty(key.$h())) {
        return true;
      }
    }

    false
  end

  def has_value?(what)
    `
      var keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i];
            value = values[key.$h()];

        if (#{`what` == `value`}) {
          return true;
        }
      }
    `

    false
  end

  def hash(*)
    `return self.$id;`
  end

  alias_method :include?, :has_key?

  def initialize_copy(*)
    raise NotImplementedError, 'Hash#initialize_copy not yet implemented'
  end

  def inspect
    `
      var description = [],
          keys        = self.k,
          values      = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i],
            value = values[key.$h()];

        description.push(#{`key`.inspect} + '=>' + #{`value`.inspect});
      }

      return '{' + description.join(', ') + '}';
    `
  end

  def invert
    `
      var result  = #{Hash.allocate},
          keys    = self.k,
          values  = self.a,
          keys2   = result.k,
          values2 = result.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i];
            value = values[key.$h()];

        keys2.push(value);
        values2[value.$h()] = key;
      }

      return result;
    `
  end

  def keep_if
    return enum_for :keep_if unless block_given?

    delete_if {|key, value|
      !yield key, value
    }
  end

  def key(object)
    `
      var keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i];
            value = values[key.$h()];

        if (#{`object` == `value`}) {
          return key;
        }
      }
    `
  end

  alias_method :key?, :has_key?

  def keys
    `
      var keys = [];

      for (var prop in self.map) {
        keys.push(self.map[prop][0]);
      }

      return keys;
    `
  end

  def length
    `self.k.length`
  end

  alias_method :member?,  :has_key?

  def merge(other)
    `
      var result  = #{Hash.allocate},
          keys    = self.k,
          values  = self.a,
          keys2   = result.k,
          values2 = result.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i],
            value = values[#{key.hash}];

        keys2.push(key);
        values2[#{key.hash}] = value;
      }

      keys   = other.k;
      values = other.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i],
            value = values[#{key.hash}];

        if (!values2.hasOwnProperty(#{key.hash})) {
          keys2.push(key);
        }

        if (values2.hasOwnProperty(#{key.hash}) && #{block_given?}) {
          values2[#{key.hash}] = #{yield `key`, `values2[#{key.hash}]`, `value`};
        }
        else {
          values2[#{key.hash}] = value;
        }
      }

      return result;
    `
  end

  def merge!(other)
    `
      var keys    = self.k,
          values  = self.a,
          keys2   = other.k,
          values2 = other.a;

      for (var i = 0, length = keys2.length; i < length; i++) {
        var key   = keys2[i];
            value = values2[key.$h()];

        if (!values.hasOwnProperty(key.$h())) {
          keys.push(key);
        }

        if (values.hasOwnProperty(key.$h()) && #{block_given?}) {
          values[key.$h()] = #{yield `key`, `values[key.$h()]`, `value`};
        }
        else {
          values[key.$h()] = value;
        }
      }
    `

    self
  end

  def rassoc(object)
    `
      var keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i];
            value = values[key.$h()];

        if (#{`value` == object}) {
          return [key, value];
        }
      }
    `
  end

  def rehash(*)
    raise NotImplementedError, 'Hash# not yet implemented'
  end

  def reject(&block)
    clone.delete_if &block
  end

  def reject!(&block)
    result = clone
    result.delete_if &block

    result == self ? nil : self
  end

  def replace (other)
    clear

    `
      var keys    = self.k,
          values  = self.a,
          keys2   = other.k,
          values2 = other.a;

      for (var i = 0, length = keys2.length; i < length; i++) {
        var key   = keys2[i],
            value = values2[key.$h()];

        keys.push(key);
        values[key.$h()] = value;
      }
    `

    self
  end

  def select(*)
    raise NotImplementedError, 'Hash#select not yet implemented'
  end

  def select!(*)
    raise NotImplementedError, 'Hash#select! not yet implemented'
  end

  def shift
    `
      var keys   = self.k,
          values = self.a;

      if (keys.length > 0) {
        var key   = keys[0];
            value = values[key.$h()];

        keys.shift();
        delete values[key.$h()];

        return [key, value];
      }

      return self.d;
    `
  end

  alias_method :size, :length

  def store(*)
    raise NotImplementedError, 'Hash#store not yet implemented'
  end

  def to_a
    `
      var result = [],
          keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key   = keys[i];
            value = values[key.$h()];

        result.push([key, value]);
      }

      return result;
    `
  end

  def to_hash
    self
  end

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

  def update(*)
    raise NotImplementedError, 'Hash#update not yet implemented'
  end

  alias_method :value?, :has_value?

  def values
    `
      var result = [],
          keys   = self.k,
          values = self.a;

      for (var i = 0, length = keys.length; i < length; i++) {
        result.push(values[keys[i].$h()]);
      }

      return result;
    `
  end

  def values_at(*)
    raise NotImplementedError, 'Hash#values_at not yet implemented'
  end
end
