class Hash
  include Enumerable

  %x{
    var hash_class = this;

    __hash = Opal.hash = function() {
      var hash   = new hash_class._alloc(),
          args   = __slice.call(arguments),
          assocs = {};

      hash.map   = assocs;
      hash.none  = nil;
      hash.proc  = nil;

      for (var i = 0, length = args.length, key; i < length; i++) {
        key = args[i];
        assocs[key] = args[++i];
      }

      return hash;
    };
  }

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
      if (this === other) {
        return true;
      }

      if (!other.map) {
        return false;
      }

      var map  = this.map,
          map2 = other.map;

      for (var assoc in map) {
        if (map2[assoc] == null) {
          return false;
        }

        if (#{ `map[assoc]` != `map2[assoc]` }) {
          return false;
        }
      }

      return true;
    }
  end

  def [](key)
    %x{
      var val;

      if ((val = this.map[key]) != null) {
        return val;
      }

      return this.none;
    }
  end

  def []=(key, value)
    %x{
      this.map[key] = value;

      return value;
    }
  end

  def assoc(object)
    %x{
      for (var key in this.map) {
        var val = this.map[key];

        if (#{ `val` == `object` }) {
          return [key, val];
        }
      }

      return nil;
    }
  end

  def clear
    %x{
      this.map = {};
      return this;
    }
  end

  def clone
    %x{
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        map2[assoc] = map[assoc];
      }

      return result;
    }
  end

  def default
    `this.none`
  end

  def default=(object)
    `this.none = object`
  end

  def default_proc
    `this.proc`
  end

  def default_proc=(proc)
    `this.proc = proc`
  end

  def delete(key)
    %x{
      var map  = this.map, result;

      if (result = map[key]) {
        result = bucket[1];

        delete map[key];
      }

      return result;
    }
  end

  def delete_if(&block)
    return enum_for :delete_if unless block_given?

    %x{
      var map = this.map;

      for (var key in map) {
        var value;

        if ((value = block.call(__context, key, map[key])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          delete map[key];
        }
      }

      return this;
    }
  end

  alias dup clone

  def each(&block)
    return enum_for :each unless block_given?

    %x{
      var map = this.map;

      for (var key in map) {
        if (block.call(__context, key, map[key]) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    }
  end

  def each_key(&block)
    return enum_for :each_key unless block_given?

    %x{
      var map = this.map;

      for (var key in map) {
        if (block.call(__context, key) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    }
  end

  alias each_pair each

  def each_value(&block)
    return enum_for :each_value unless block_given?

    %x{
      var map = this.map;

      for (var key in map) {
        if (block.call(__context, map[key]) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    }
  end

  def empty?
    %x{
      for (var assoc in this.map) {
        return false;
      }

      return true;
    }
  end

  alias eql? ==

  def fetch(key, defaults = undefined, &block)
    %x{
      var val = this.map[key];

      if (val != null) {
        return val;
      }

      if (block !== nil) {
        var value;

        if ((value = block.call(__context, key)) === __breaker) {
          return __breaker.$v;
        }

        return value;
      }

      if (defaults != null) {
        return defaults;
      }

      throw RubyKeyError.$new('key not found');
    }
  end

  def flatten(level = undefined)
    %x{
      var map    = this.map,
          result = [];

      for (var key in map) {
        var value  = map[key];

        result.push(key);

        if (value._isArray) {
          if (level == null || level === 1) {
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
    }
  end

  def has_key?(key)
    `this.map[key] != null`
  end

  def has_value?(value)
    %x{
      var map = this.map;

      for (var key in map) {
        if (#{ `map[key]` == value }) {
          return true;
        }
      }

      return false;
    }
  end

  def hash
    `this._id`
  end

  alias include? has_key?

  def index(object)
    %x{
      var map = this.map;

      for (var key in map) {
        if (#{ object == `map[key]` }) {
          return map[key];
        }
      }

      return nil;
    }
  end

  def indexes(*keys)
    %x{
      var result = [], map = this.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (map[key] != null) {
          result.push(map[key]);
        }
        else {
          result.push(this.none);
        }
      }

      return result;
    }
  end

  alias indices indexes

  def inspect
    %x{
      var inspect = [],
          map     = this.map;

      for (var key in map) {
        inspect.push(#{`key`.inspect} + '=>' + #{`map[key]`.inspect});
      }
      return '{' + inspect.join(', ') + '}';
    }
  end

  def invert
    %x{
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var key in map) {
        map2[map[key]] = key;
      }

      return result;
    }
  end

  def keep_if(&block)
    return enum_for :keep_if unless block_given?

    %x{
      var map = this.map, value;

      for (var key in map) {
        if ((value = block.call(__context, key, map[key])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          delete map[key];
        }
      }

      return this;
    }
  end

  alias key index

  alias key? has_key?

  def keys
    %x{
      var result = [];

      for (var key in this.map) {
        result.push(key);
      }

      return result;
    }
  end

  def length
    %x{
      var result = 0;

      for (var key in this.map) {
        result++;
      }

      return result;
    }
  end

  alias member? has_key?

  def merge(other, &block)
    %x{
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var key in map) {
        map2[key] = map[key];
      }

      map = other.map;

      if (block === nil) {
        for (var key in map) {
          map2[key] = map[key];
        }
      }
      else {
        for (var key in map) {
          if (map2[key] != null) {
            val = block.call(__context, key, map2[key], map[key]);
          }

          map2[key] = val;
        }
      }

      return result;
    }
  end

  def merge!(other, &block)
    %x{
      var map  = this.map,
          map2 = other.map;

      if (block === nil) {
        for (var key in map2) {
          map[key] = map2[key];
        }
      }
      else {
        for (var key in map2) {
          if (map[key] != null) {
            val = block.call(__context, key, map[key], map2[key]);
          }

          map[key] = val;
        }
      }

      return this;
    }
  end

  def rassoc(object)
    %x{
      var map = this.map;

      for (var key in map) {
        if (#{`map[key]` == object}) {
          return [key, map];
        }
      }

      return nil;
    }
  end

  def reject(&block)
    return enum_for :reject unless block_given?

    %x{
      var map = this.map, result = __hash(), map2 = result.map;

      for (var key in map) {
        var value;

        if ((value = block.call(__context, key, map[key])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          map2[key] = map[key];
        }
      }

      return result;
    }
  end

  def replace(other)
    %x{
      var map = this.map = {};

      for (var key in other.map) {
        map[key] = other.map[key];
      }

      return this;
    }
  end

  def select(&block)
    return enum_for :select unless block_given?

    %x{
      var map = this.map, result = __hash(), map2 = result.map;

      for (var key in map) {
        var value;

        if ((value = block.call(__context, key, map[key])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          map2[key] = map[key];
        }
      }

      return result;
    }
  end

  def select!(&block)
    return enum_for :select! unless block_given?

    %x{
      var map = this.map, result = nil;

      for (var assoc in map) {
        var value;

        if ((value = block.call(__context, key, map[key])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          delete map[key];
          result = this;
        }
      }

      return result;
    }
  end

  def shift
    %x{
      var map = this.map;

      for (var key in map) {
        var val = map[key];
        delete map[key];
        return [key, val]
      }

      return nil;
    }
  end

  alias size length

  def to_a
    %x{
      var map    = this.map,
          result = [];

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
      var parts = [], map = this.map;

      for (var key in map) {
        parts.push(#{ `key`.to_json } + ': ' + #{ `map[key]`.to_json });
      }

      return '{' + parts.join(', ') + '}';
    }
  end

  alias to_s inspect

  alias update merge!

  def value?(value)
    %x{
      var map = this.map;

      for (var key in map) {
        var v = map[key];
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
      var map    = this.map,
          result = [];

      for (var key in map) {
        result.push(map[key]);
      }

      return result;
    }
  end
end