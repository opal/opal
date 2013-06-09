class Hash
  include Enumerable

  %x{
    var __hash = Opal.hash = function() {
      var hash   = new Hash,
          args   = __slice.call(arguments),
          keys   = [],
          assocs = {};

      hash.map   = assocs;
      hash.keys  = keys;

      for (var i = 0, length = args.length, key; i < length; i++) {
        var key = args[i], obj = args[++i];

        if (assocs[key] == null) {
          keys.push(key);
        }

        assocs[key] = obj;
      }

      return hash;
    };
  }

  # hash2 is a faster creator for hashes that just use symbols and
  # strings as keys. The map and keys array can be constructed at
  # compile time, so they are just added here by the constructor
  # function
  %x{
    var __hash2 = Opal.hash2 = function(keys, map) {
      var hash = new Hash;
      hash.keys = keys;
      hash.map = map;
      return hash;
    };
  }

  `var __hasOwn = {}.hasOwnProperty`

  def self.[](*objs)
    `__hash.apply(null, objs)`
  end

  def self.allocate
    `__hash()`
  end

  def self.new(defaults = undefined, &block)
    %x{
      var hash = __hash();

      if (defaults != null) {
        if (defaults.constructor == Object) {
          var map = hash.map, keys = hash.keys;

          for (var key in defaults) {
            keys.push(key);
            map[key] = defaults[key];
          }
        }
        else {
          hash.none = defaults;
        }
      }
      else if (block !== null) {
          hash.proc = block;
      }

      return hash;
    }
  end

  def ==(other)
    %x{
      if (#{self} === other) {
        return true;
      }

      if (!other.map || !other.keys) {
        return false;
      }

      if (#{self}.keys.length !== other.keys.length) {
        return false;
      }

      var map  = #{self}.map,
          map2 = other.map;

      for (var i = 0, length = #{self}.keys.length; i < length; i++) {
        var key = #{self}.keys[i], obj = map[key], obj2 = map2[key];

        if (#{`obj` != `obj2`}) {
          return false;
        }
      }

      return true;
    }
  end

  def [](key)
    %x{
      var bucket = #{self}.map[key];

      if (bucket !== undefined) {
        return bucket;
      }

      var proc = #{@proc};

      if (proc != null) {
        return #{ `proc`.call self, key };
      }

      return #{@none};
    }
  end

  def []=(key, value)
    %x{
      var map = #{self}.map;

      if (!__hasOwn.call(map, key)) {
        #{self}.keys.push(key);
      }

      map[key] = value;

      return value;
    }
  end

  def assoc(object)
    %x{
      var keys = #{self}.keys, key;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];

        if (#{`key` == object}) {
          return [key, #{self}.map[key]];
        }
      }

      return null;
    }
  end

  def clear
    %x{
      #{self}.map = {};
      #{self}.keys = [];
      return #{self};
    }
  end

  def clone
    %x{
      var result = __hash(),
          map    = #{self}.map,
          map2   = result.map,
          keys2  = result.keys;

      for (var i = 0, length = #{self}.keys.length; i < length; i++) {
        keys2.push(#{self}.keys[i]);
        map2[#{self}.keys[i]] = map[#{self}.keys[i]];
      }

      return result;
    }
  end

  def default(val = undefined)
    @none
  end

  def default=(object)
    @none = object
  end

  def default_proc
    @proc
  end

  def default_proc=(proc)
    @proc = proc
  end

  def delete(key)
    %x{
      var map  = #{self}.map, result = map[key];

      if (result !== undefined) {
        delete map[key];
        #{self}.keys.$delete(key);

        return result;
      }

      return null;
    }
  end

  def delete_if(&block)
    %x{
      var map = #{self}.map, keys = #{self}.keys, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== null) {
          keys.splice(i, 1);
          delete map[key];

          length--;
          i--;
        }
      }

      return #{self};
    }
  end

  alias dup clone

  def each(&block)
    %x{
      var map = #{self}.map, keys = #{self}.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (block(key, map[key]) === __breaker) {
          return __breaker.$v;
        }
      }

      return #{self};
    }
  end

  def each_key(&block)
    %x{
      var keys = #{self}.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (block(key) === __breaker) {
          return __breaker.$v;
        }
      }

      return #{self};
    }
  end

  alias each_pair each

  def each_value(&block)
    %x{
      var map = #{self}.map, keys = #{self}.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        if (block(map[keys[i]]) === __breaker) {
          return __breaker.$v;
        }
      }

      return #{self};
    }
  end

  def empty?
    %x{
      return #{self}.keys.length === 0;
    }
  end

  alias eql? ==

  def fetch(key, defaults = undefined, &block)
    %x{
      var value = #{self}.map[key];

      if (value !== undefined) {
        return value;
      }

      if (block != null) {
        var value;

        if ((value = block(key)) === __breaker) {
          return __breaker.$v;
        }

        return value;
      }

      if (defaults !== undefined) {
        return defaults;
      }

      #{ raise KeyError, "key not found" };
    }
  end

  def flatten(level=undefined)
    %x{
      var map = #{self}.map, keys = #{self}.keys, result = [];

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], value = map[key];

        result.push(key);

        if (value._isArray) {
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
    `#{self}.map[key] !== undefined`
  end

  def has_value?(value)
    %x{
      for (var assoc in #{self}.map) {
        if (#{`#{self}.map[assoc]` == value}) {
          return true;
        }
      }

      return false;
    }
  end

  def hash
    `#{self}._id`
  end

  alias include? has_key?

  def index(object)
    %x{
      var map = #{self}.map, keys = #{self}.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (#{object == `map[key]`}) {
          return key;
        }
      }

      return null;
    }
  end

  def indexes(*keys)
    %x{
      var result = [], map = #{self}.map, val;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], val = map[key];

        if (val != null) {
          result.push(val);
        }
        else {
          result.push(#{self}.none);
        }
      }

      return result;
    }
  end

  alias indices indexes

  def inspect
    %x{
      var inspect = [], keys = #{self}.keys, map = #{self}.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];
        inspect.push(#{`key`.inspect} + '=>' + #{`map[key]`.inspect});
      }

      return '{' + inspect.join(', ') + '}';
    }
  end

  def invert
    %x{
      var result = __hash(), keys = #{self}.keys, map = #{self}.map,
          keys2 = result.keys, map2 = result.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        keys2.push(obj);
        map2[obj] = key;
      }

      return result;
    }
  end

  def keep_if(&block)
    %x{
      var map = #{self}.map, keys = #{self}.keys, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === null) {
          keys.splice(i, 1);
          delete map[key];

          length--;
          i--;
        }
      }

      return #{self};
    }
  end

  alias key index

  alias key? has_key?

  def keys
    %x{
      return #{self}.keys.slice(0);
    }
  end

  def length
    %x{
      return #{self}.keys.length;
    }
  end

  alias member? has_key?

  def merge(other, &block)
    %x{
      var keys = #{self}.keys, map = #{self}.map,
          result = __hash(), keys2 = result.keys, map2 = result.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        keys2.push(key);
        map2[key] = map[key];
      }

      var keys = other.keys, map = other.map;

      if (block === null) {
        for (var i = 0, length = keys.length; i < length; i++) {
          var key = keys[i];

          if (map2[key] == null) {
            keys2.push(key);
          }

          map2[key] = map[key];
        }
      }
      else {
        for (var i = 0, length = keys.length; i < length; i++) {
          var key = keys[i];

          if (map2[key] == null) {
            keys2.push(key);
            map2[key] = map[key];
          }
          else {
            map2[key] = block(key, map2[key], map[key]);
          }
        }
      }

      return result;
    }
  end

  def merge!(other, &block)
    %x{
      var keys = #{self}.keys, map = #{self}.map,
          keys2 = other.keys, map2 = other.map;

      if (block === null) {
        for (var i = 0, length = keys2.length; i < length; i++) {
          var key = keys2[i];

          if (map[key] == null) {
            keys.push(key);
          }

          map[key] = map2[key];
        }
      }
      else {
        for (var i = 0, length = keys2.length; i < length; i++) {
          var key = keys2[i];

          if (map[key] == null) {
            keys.push(key);
            map[key] = map2[key];
          }
          else {
            map[key] = block(key, map[key], map2[key]);
          }
        }
      }

      return #{self};
    }
  end

  def rassoc(object)
    %x{
      var keys = #{self}.keys, map = #{self}.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if (#{`obj` == object}) {
          return [key, obj];
        }
      }

      return null;
    }
  end

  def reject(&block)
    %x{
      var keys = #{self}.keys, map = #{self}.map,
          result = __hash(), map2 = result.map, keys2 = result.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key], value;

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === null) {
          keys2.push(key);
          map2[key] = obj;
        }
      }

      return result;
    }
  end

  def replace(other)
    %x{
      var map = #{self}.map = {}, keys = #{self}.keys = [];

      for (var i = 0, length = other.keys.length; i < length; i++) {
        var key = other.keys[i];
        keys.push(key);
        map[key] = other.map[key];
      }

      return #{self};
    }
  end

  def select(&block)
    %x{
      var keys = #{self}.keys, map = #{self}.map,
          result = __hash(), map2 = result.map, keys2 = result.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key], value;

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== null) {
          keys2.push(key);
          map2[key] = obj;
        }
      }

      return result;
    }
  end

  def select!(&block)
    %x{
      var map = #{self}.map, keys = #{self}.keys, value, result = null;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === null) {
          keys.splice(i, 1);
          delete map[key];

          length--;
          i--;
          result = #{self}
        }
      }

      return result;
    }
  end

  def shift
    %x{
      var keys = #{self}.keys, map = #{self}.map;

      if (keys.length) {
        var key = keys[0], obj = map[key];

        delete map[key];
        keys.splice(0, 1);

        return [key, obj];
      }

      return null;
    }
  end

  alias size length

  def to_a
    %x{
      var keys = #{self}.keys, map = #{self}.map, result = [];

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];
        result.push([key, map[key]]);
      }

      return result;
    }
  end

  def to_hash
    self
  end

  def to_json
    %x{
      var inspect = [], keys = #{self}.keys, map = #{self}.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];
        inspect.push(#{`key`.to_json} + ': ' + #{`map[key]`.to_json});
      }

      return '{' + inspect.join(', ') + '}';
    }
  end

  def to_n
    %x{
      var result = {}, keys = #{self}.keys, map = #{self}.map, bucket, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if (obj.$to_n) {
          result[key] = #{`obj`.to_n};
        }
        else {
          result[key] = obj;
        }
      }

      return result;
    }
  end

  alias to_s inspect

  alias update merge!

  def value?(value)
    %x{
      var map = #{self}.map;

      for (var assoc in map) {
        var v = map[assoc];
        if (#{`v` == value}) {
          return true;
        }
      }

      return false;
    }
  end

  alias values_at indexes

  def values
    %x{
      var map    = #{self}.map,
          result = [];

      for (var key in map) {
        result.push(map[key]);
      }

      return result;
    }
  end
end
