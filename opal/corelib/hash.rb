require 'corelib/enumerable'

class Hash
  include Enumerable

  def self.[](*objs)
    `Opal.hash.apply(null, objs)`
  end

  def self.allocate
    %x{
      var hash = new self.$$alloc;

      hash.map  = {};
      hash.keys = [];
      hash.none = nil;
      hash.proc = nil;

      return hash;
    }
  end

  def initialize(defaults = undefined, &block)
    %x{
      self.none = (defaults === undefined ? nil : defaults);
      self.proc = block;
    }
    self
  end

  def ==(other)
    %x{
      if (self === other) {
        return true;
      }

      if (!other.map || !other.keys) {
        return false;
      }

      if (self.keys.length !== other.keys.length) {
        return false;
      }

      var map  = self.map,
          map2 = other.map;

      for (var i = 0, length = self.keys.length; i < length; i++) {
        var key = self.keys[i], khash = key.$hash(), obj = map[khash], obj2 = map2[khash];
        if (obj2 === undefined || #{not(`obj` == `obj2`)}) {
          return false;
        }
      }

      return true;
    }
  end

  def [](key)
    %x{
      var map = self.map, hash = key.$hash();

      if (Opal.hasOwnProperty.call(map, hash)) {
        return map[hash];
      }

      var proc = #@proc;

      if (proc !== nil) {
        return #{ `proc`.call self, key };
      }

      return #@none;
    }
  end

  def []=(key, value)
    %x{
      var map = self.map, hash = key.$hash();

      if (!Opal.hasOwnProperty.call(map, hash)) {
        self.keys.push(key);
      }

      map[hash] = value;

      return value;
    }
  end

  def assoc(object)
    %x{
      var keys = self.keys, key, hash;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];

        if (#{`key` == object}) {
          return [key, self.map[key.$hash()]];
        }
      }

      return nil;
    }
  end

  def clear
    %x{
      self.map = {};
      self.keys = [];
      return self;
    }
  end

  def clone
    %x{
      var map  = {},
          keys = [],
          hash, key, value;

      for (var i = 0, length = self.keys.length; i < length; i++) {
        key   = self.keys[i];
        hash  = key.$hash();
        value = self.map[hash];

        keys.push(key);
        map[hash] = value;
      }

      var clone = new self.$$class.$$alloc();

      clone.map  = map;
      clone.keys = keys;
      clone.none = self.none;
      clone.proc = self.proc;

      return clone;
    }
  end

  def default(val = undefined)
    %x{
      if (val !== undefined && self.proc !== nil) {
        return #{@proc.call(self, val)};
      }
      return self.none;
    }
  end

  def default=(object)
    %x{
      self.proc = nil;
      return (self.none = object);
    }
  end

  def default_proc
    @proc
  end

  def default_proc=(proc)
    %x{
      if (proc !== nil) {
        proc = #{Opal.coerce_to!(proc, Proc, :to_proc)};

        if (#{proc.lambda?} && #{proc.arity.abs} != 2) {
          #{raise TypeError, "default_proc takes two arguments"};
        }
      }
      self.none = nil;
      return (self.proc = proc);
    }
  end

  def delete(key, &block)
    %x{
      var map = self.map,
          hash = key.$hash(),
          result = map[hash];

      if (result != null) {
        delete map[hash];
        self.keys.$delete(key);

        return result;
      }

      if (block !== nil) {
        return #{block.call(key)};
      }
      return nil;
    }
  end

  def delete_if(&block)
    return enum_for :delete_if unless block

    %x{
      var map = self.map,
          keys = self.keys,
          key, value, obj, hash;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];
        hash = key.$hash();
        obj = map[hash];

        if ((value = block(key, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          keys.splice(i, 1);
          delete map[hash];

          length--;
          i--;
        }
      }

      return self;
    }
  end

  alias dup clone

  def each(&block)
    return enum_for :each unless block

    %x{
      var map  = self.map,
          keys = self.keys,
          key, value, khash;

      for (var i = 0, length = keys.length; i < length; i++) {
        key   = keys[i];
        khash = key.$hash();
        value = Opal.yield1(block, [key, map[khash]]);

        if (value === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    }
  end

  def each_key(&block)
    return enum_for :each_key unless block

    %x{
      var keys = self.keys, key;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];

        if (block(key) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    }
  end

  alias each_pair each

  def each_value(&block)
    return enum_for :each_value unless block

    %x{
      var map = self.map, keys = self.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        if (block(map[keys[i].$hash()]) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    }
  end

  def empty?
    `self.keys.length === 0`
  end

  alias eql? ==

  def fetch(key, defaults = undefined, &block)
    %x{
      var hash = key.$hash(), value = self.map[hash];

      if (value != null) {
        return value;
      }

      if (block !== nil) {
        var value;

        if ((value = block(key)) === $breaker) {
          return $breaker.$v;
        }

        return value;
      }

      if (defaults != null) {
        return defaults;
      }

      #{ raise KeyError, "key not found" };
    }
  end

  def flatten(level=undefined)
    %x{
      var map = self.map,
          keys = self.keys,
          result = [],
          key, hash, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];
        hash = key.$hash();
        value = map[hash];

        result.push(key);

        if (value.$$is_array) {
          if (level == null || level === 1) {
            result.push(value);
          }
          else {
            result = result.concat(#{`value`.flatten(`level - 1`)});
          }
        }
        else {
          result.push(value);
        }
      }

      return result;
    }
  end

  def has_key?(key)
    %x{
      var map = self.map,
          keys = self.keys,
          khash = key.$hash();

      if (Opal.hasOwnProperty.call(self.map, khash)) {
        for (var i = 0, length = keys.length; i < length; i++) {
          if (!#{not(key.eql?(`keys[i]`))}) {
            return true;
          }
        }
      }
      return false;
    }
  end

  def has_value?(value)
    %x{
      for (var khash in self.map) {
        if (#{`self.map[khash]` == value}) {
          return true;
        }
      }

      return false;
    }
  end

  def hash
    `self.$$id`
  end

  alias include? has_key?

  def index(object)
    %x{
      var map = self.map,
          keys = self.keys,
          key, hash;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];
        hash = key.$hash();

        if (#{`map[hash]` == object}) {
          return key;
        }
      }

      return nil;
    }
  end

  def indexes(*keys)
    %x{
      var result = [],
          map = self.map,
          key, hash, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];
        hash = key.$hash();
        value = map[hash];

        if (value != null) {
          result.push(value);
        }
        else {
          result.push(self.none);
        }
      }

      return result;
    }
  end

  alias indices indexes

  def inspect
    %x{
      var inspect = [], keys = self.keys, map = self.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], val = map[key.$hash()];
        val = (val === self) ? '{...}' : val.$inspect()
        key = (key === self) ? '{...}' : key.$inspect()
        inspect.push(key + '=>' + val);
      }

      return '{' + inspect.join(', ') + '}';
    }
  end

  def invert
    %x{
      var result = Opal.hash(), keys = self.keys, map = self.map,
          keys2 = result.keys, map2 = result.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], khash = key.$hash(), obj = map[khash];

        keys2.push(obj);
        map2[obj.$hash()] = key;
      }

      return result;
    }
  end

  def keep_if(&block)
    return enum_for :keep_if unless block

    %x{
      var map = self.map, keys = self.keys, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key.$hash()];

        if ((value = block(key, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          keys.splice(i, 1);
          delete map[key.$hash()];

          length--;
          i--;
        }
      }

      return self;
    }
  end

  alias key index

  alias key? has_key?

  def keys
    `self.keys.slice(0)`
  end

  def length
    `self.keys.length`
  end

  alias member? has_key?

  def merge(other, &block)
    unless Hash === other
      other = Opal.coerce_to!(other, Hash, :to_hash)
    end

    cloned = clone
    cloned.merge!(other, &block)
    cloned
  end

  def merge!(other, &block)
    %x{
      if (! #{Hash === other}) {
        other = #{Opal.coerce_to!(other, Hash, :to_hash)};
      }

      var keys = self.keys, map = self.map,
          keys2 = other.keys, map2 = other.map;

      if (block === nil) {
        for (var i = 0, length = keys2.length; i < length; i++) {
          var key = keys2[i], khash = key.$hash();

          if (map[khash] == null) {
            keys.push(key);
          }

          map[khash] = map2[khash];
        }
      }
      else {
        for (var i = 0, length = keys2.length; i < length; i++) {
          var key = keys2[i], khash = key.$hash(), value = map[khash], value2 = map2[khash];

          if (value == null) {
            keys.push(key);
            map[khash] = value2;
          }
          else {
            map[khash] = block(key, value, value2);
          }
        }
      }

      return self;
    }
  end

  def rassoc(object)
    %x{
      var keys = self.keys, map = self.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key.$hash()];

        if (#{`obj` == object}) {
          return [key, obj];
        }
      }

      return nil;
    }
  end

  def reject(&block)
    return enum_for :reject unless block

    %x{
      var keys = self.keys, map = self.map,
          result = Opal.hash(), map2 = result.map, keys2 = result.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], khash = key.$hash(), obj = map[khash], value;

        if ((value = block(key, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          keys2.push(key);
          map2[khash] = obj;
        }
      }

      return result;
    }
  end

  def replace(other)
    %x{
      var map = self.map = {}, keys = self.keys = [];

      for (var i = 0, length = other.keys.length; i < length; i++) {
        var key = other.keys[i], khash = key.$hash();
        keys.push(key);
        map[khash] = other.map[khash];
      }

      return self;
    }
  end

  def select(&block)
    return enum_for :select unless block

    %x{
      var keys = self.keys, map = self.map,
          result = Opal.hash(), map2 = result.map, keys2 = result.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], khash = key.$hash(), obj = map[khash], value;

        if ((value = block(key, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          keys2.push(key);
          map2[khash] = obj;
        }
      }

      return result;
    }
  end

  def select!(&block)
    return enum_for :select! unless block

    %x{
      var map = self.map, keys = self.keys, value, result = nil;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], khash = key.$hash(), obj = map[khash];

        if ((value = block(key, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          keys.splice(i, 1);
          delete map[khash];

          length--;
          i--;
          result = self
        }
      }

      return result;
    }
  end

  def shift
    %x{
      var keys = self.keys, map = self.map;

      if (keys.length) {
        var key = keys[0], khash = key.$hash(), obj = map[khash];

        delete map[khash];
        keys.splice(0, 1);

        return [key, obj];
      }

      return nil;
    }
  end

  alias size length

  alias_method :store, :[]=

  def to_a
    %x{
      var keys = self.keys, map = self.map, result = [];

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], khash = key.$hash();
        result.push([key, map[khash]]);
      }

      return result;
    }
  end

  def to_h
    %x{
      var hash   = new Opal.Hash.$$alloc,
          cloned = #{clone};

      hash.map  = cloned.map;
      hash.keys = cloned.keys;
      hash.none = cloned.none;
      hash.proc = cloned.proc;

      return hash;
    }
  end

  def to_hash
    self
  end

  alias to_s inspect

  alias update merge!

  alias value? has_value?

  alias values_at indexes

  def values
    %x{
      var map    = self.map,
          result = [];

      for (var key in map) {
        result.push(map[key.$hash()]);
      }

      return result;
    }
  end
end
