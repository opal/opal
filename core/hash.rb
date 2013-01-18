class Hash
  include Enumerable

  %x{
    __hash = Opal.hash = function() {
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

    // hash2 is a faster creator for hashes that just use symbols and
    // strings as keys. The map and keys array can be constructed at
    // compile time, so they are just added here by the constructor
    // function
    __hash2 = Opal.hash2 = function(map) {
      var hash = new Hash;
      hash.map = map;
      return hash;
    }
  }

  def self.[](*objs)
    `__hash.apply(null, objs)`
  end

  def self.allocate
    `__hash()`
  end

  def self.from_native(obj)
    %x{
      var hash = __hash(), map = hash.map;

      for (var key in obj) {
        map[key] = obj[key];
      }

      return hash;
    }
  end

  def self.new(defaults = undefined, &block)
    %x{
      var hash = __hash();

      if (defaults != null) {
        hash.none = defaults;
      }
      else if (block !== nil) {
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

      if (other.map == null) {
        return false;
      }

      var map  = #{self}.map,
          map2 = other.map;

      for (var key in map) {
        var obj = map[key], obj2 = map2[key];

        if (#{`obj` != `obj2`}) {
          return false;
        }
      }

      return true;
    }
  end

  def [](key)
    %x{
      var obj = #{self}.map[key];

      if (obj != null) {
        return obj;
      }

      var proc = #{@proc};

      if (proc !== nil) {
        return #{ `proc`.call self, key };
      }

      return #{@none};
    }
  end

  def []=(key, value)
    %x{
      #{self}.map[key] = value;
      return value;
    }
  end

  def assoc(object)
    %x{
      var map = #{self}.map;

      for (var key in map) {
        if (#{`key` == object}) {
          return [key, map[key]];
        }
      }

      return nil;
    }
  end

  def clear
    %x{
      #{self}.map = {};
      return #{self};
    }
  end

  def clone
    %x{
      var result = __hash(),
          map    = #{self}.map,
          map2   = result.map;

      for (var key in map) {
        map2[key] = map[key];
      }

      return result;
    }
  end

  def default
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
      var map = #{self}.map, result = map[key];

      if (result != null) {
        delete map[key];
        return result;
      }

      return nil;
    }
  end

  def delete_if(&block)
    %x{
      var map = #{self}.map, value;

      for (var key in map) {
        if ((value = block(key, map[key])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          delete map[key]
        }
      }

      return #{self};
    }
  end

  alias dup clone

  def each(&block)
    %x{
      var map = #{self}.map;

      for (var key in map) {
        if (block(key, map[key]) === __breaker) {
          return __breaker.$v;
        }
      }

      return #{self};
    }
  end

  def each_key(&block)
    %x{
      var map = #{self}.map;

      for (var key in map) {
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
      var map = #{self}.map;

      for (var key in map) {
        if (block(map[key]) === __breaker) {
          return __breaker.$v;
        }
      }

      return #{self};
    }
  end

  def empty?
    %x{
      for (var key in #{self}.map) {
        return false;
      }

      return true;
    }
  end

  alias eql? ==

  def fetch(key, defaults = undefined, &block)
    %x{
      var value = #{self}.map[key];

      if (value != null) {
        return value;
      }

      if (block !== nil) {
        var value;

        if ((value = block(key)) === __breaker) {
          return __breaker.$v;
        }

        return value;
      }

      if (defaults != null) {
        return defaults;
      }

      #{ raise "key not found" };
    }
  end

  def flatten(level=undefined)
    %x{
      var map = #{self}.map, result = [];

      for (var key in map) {
        var value = map[key];

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
    `#{self}.map[key] != null`
  end

  def has_value?(value)
    %x{
      var map = #{self}.map;

      for (var key in map) {
        if (#{`map[key]` == value}) {
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
      var map = #{self}.map;

      for (var key in map) {
        if (#{object == `map[key]`}) {
          return key;
        }
      }

      return nil;
    }
  end

  def indexes(*keys)
    %x{
      var result = [], map = #{self}.map, val;

      for (var i = 0, length = keys.length; i < length; i++) {
        val = map[keys[i]];

        if (val != null) {
          result.push(val);
        }
        else {
          result.push(#{@none});
        }
      }

      return result;
    }
  end

  alias indices indexes

  def inspect
    %x{
      var inspect = [], map = #{self}.map;

      for (var key in map) {
        inspect.push(#{`key`.inspect} + '=>' + #{`map[key]`.inspect});
      }

      return '{' + inspect.join(', ') + '}';
    }
  end

  def invert
    %x{
      var result = __hash(), map = #{self}.map, map2 = result.map;

      for (var key in map) {
        var obj = map[key];
        map2[obj] = key;
      }

      return result;
    }
  end

  def keep_if(&block)
    %x{
      var map = #{self}.map, value;

      for (var key in map) {
        var obj = map[key];

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          delete map[key];
        }
      }

      return #{self};
    }
  end

  alias key index

  alias key? has_key?

  def keys
    %x{
      var result = [], map = #{self}.map;

      for (var key in map) {
        result.push(key);
      }

      return result;
    }
  end

  def length
    %x{
      var length = 0, map = #{self}.map;

      for (var key in map) {
        length++;
      }

      return length;
    }
  end

  alias member? has_key?

  def merge(other, &block)
    %x{
      var map = #{self}.map, result = __hash(), map2 = result.map;

      for (var key in map) {
        map2[key] = map[key];
      }

      map = other.map;

      if (block === nil) {
        for (key in map) {
          map2[key] = map[key];
        }
      }
      else {
        for (key in map) {
          if (map2[key] == null) {
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
      var map = #{self}.map, map2 = other.map;

      if (block === nil) {
        for (var key in map2) {
          map[key] = map2[key];
        }
      }
      else {
        for (key in map2) {
          if (map[key] == null) {
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
      var map = #{self}.map;

      for (var key in map) {
        var obj = map[key];

        if (#{`obj` == object}) {
          return [key, obj];
        }
      }

      return nil;
    }
  end

  def reject(&block)
    %x{
      var map = #{self}.map, result = __hash(), map2 = result.map;

      for (var key in map) {
        var obj = map[key], value;

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          map2[key] = obj;
        }
      }

      return result;
    }
  end

  def replace(other)
    %x{
      var map = #{self}.map = {}, map2 = other.map;

      for (var key in map2) {
        map[key] = map2[key];
      }

      return #{self};
    }
  end

  def select(&block)
    %x{
      var map = #{self}.map, result = __hash(), map2 = result.map;

      for (var key in map) {
        var obj = map[key], value;

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          map2[key] = obj;
        }
      }

      return result;
    }
  end

  def select!(&block)
    %x{
      var map = #{self}.map, value, result = nil;

      for (var key in map) {
        var obj = map[key];

        if ((value = block(key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          delete map[key];

          result = #{self}
        }
      }

      return result;
    }
  end

  def shift
    %x{
      var map = #{self}.map;

      for (var key in map) {
        var obj = map[key];
        delete map[key];
        return [key, obj];
      }

      return nil;
    }
  end

  alias size length

  def to_a
    %x{
      var map = #{self}.map, result = [];

      for (var key in map) {
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
      var inspect = [], map = #{self}.map;

      for (var key in map) {
        inspect.push(#{`key`.to_json} + ': ' + #{`map[key]`.to_json});
      }

      return '{' + inspect.join(', ') + '}';
    }
  end

  def to_native
    %x{
      var result = {}, map = #{self}.map;

      for (var key in map) {
        var obj = map[key];

        if (obj.$to_native) {
          result[key] = #{`obj`.to_native};
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
