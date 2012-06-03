class Hash
  include Enumerable

  %x{
    var hash_class = this;

    __hash = Opal.hash = function() {
      var hash    = new hash_class._alloc(),
          args    = __slice.call(arguments),
          assocs  = {};

      hash.map    = assocs;
      hash.none   = null;
      hash.proc   = null;

      if (args.length == 1 && args[0]._isArray) {
        args = args[0];

        for (var i = 0, length = args.length, key; i < length; i++) {
          key = args[i][0];

          assocs[key] = [key, args[i][1]];
        }
      }
      else if (arguments.length % 2 == 0) {
        for (var i = 0, length = args.length, key; i < length; i++) {
          key = args[i];

          assocs[key] = [key, args[++i]];
        }
      }
      else {
        throw RubyArgError.$new('odd number of arguments for Hash');
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
      else if (block != null) {
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
        if (!map2[assoc]) {
          return false;
        }

        var obj  = map[assoc][1],
            obj2 = map2[assoc][1];

        if (#{`obj` != `obj2`}) {
          return false;
        }
      }

      return true;
    }
  end

  def [](key)
    %x{
      var bucket;

      if (bucket = this.map[key]) {
        return bucket[1];
      }

      return this.none;
    }
  end

  def []=(key, value)
    %x{
      this.map[key] = [key, value];

      return value;
    }
  end

  def assoc(object)
    %x{
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if (#{`bucket[0]` == `object`}) {
          return [bucket[0], bucket[1]];
        }
      }

      return null;
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
        map2[assoc] = [map[assoc][0], map[assoc][1]];
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

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value != null) {
          delete map[assoc];
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

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[0], bucket[1]) === __breaker) {
          return $breaker.$v;
        }
      }

      return this;
    }
  end

  def each_key(&block)
    return enum_for :each_key unless block_given?

    %x{
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[0]) === __breaker) {
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

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[1]) === __breaker) {
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
      var bucket = this.map[key];

      if (bucket) {
        return bucket[1];
      }

      if (block != null) {
        var value;

        if ((value = block.call(__context, key)) === __breaker) {
          return __breaker.$v;
        }

        return value;
      }

      if (defaults !== undefined) {
        return defaults;
      }

      throw RubyKeyError.$new('key not found');
    }
  end

  def flatten(level = undefined)
    %x{
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc],
            key    = bucket[0],
            value  = bucket[1];

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
    `!!this.map[key]`
  end

  def has_value?(value)
    %x{
      for (var assoc in this.map) {
        if (#{`this.map[assoc][1]` == value}) {
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
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if (#{object == `bucket[1]`}) {
          return bucket[0];
        }
      }

      return null;
    }
  end

  def indexes(*keys)
    %x{
      var result = [], map = this.map, bucket;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (bucket = map[key]) {
          result.push(bucket[1]);
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

      for (var assoc in map) {
        var bucket = map[assoc];

        inspect.push(#{`bucket[0]`.inspect} + '=>' + #{`bucket[1]`.inspect});
      }
      return '{' + inspect.join(', ') + '}';
    }
  end

  def invert
    %x{
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[bucket[1]] = [bucket[1], bucket[0]];
      }

      return result;
    }
  end

  def keep_if(&block)
    return enum_for :keep_if unless block_given?

    %x{
      var map = this.map, value;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return $breaker.$v;
        }

        if (value === false || value == null) {
          delete map[assoc];
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

      for (var assoc in this.map) {
        result.push(this.map[assoc][0]);
      }

      return result;
    }
  end

  def length
    %x{
      var result = 0;

      for (var assoc in this.map) {
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

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[assoc] = [bucket[0], bucket[1]];
      }

      map = other.map;

      if (block == null) {
        for (var assoc in map) {
          var bucket = map[assoc];

          map2[assoc] = [bucket[0], bucket[1]];
        }
      }
      else {
        for (var assoc in map) {
          var bucket = map[assoc], key = bucket[0], val = bucket[1];

          if (map2.hasOwnProperty(assoc)) {
            val = block.call(__context, key, map2[assoc][1], val);
          }

          map2[assoc] = [key, val];
        }
      }

      return result;
    }
  end

  def merge!(other, &block)
    %x{
      var map  = this.map,
          map2 = other.map;

      if (block == null) {
        for (var assoc in map2) {
          var bucket = map2[assoc];

          map[assoc] = [bucket[0], bucket[1]];
        }
      }
      else {
        for (var assoc in map2) {
          var bucket = map2[assoc], key = bucket[0], val = bucket[1];

          if (map.hasOwnProperty(assoc)) {
            val = block.call(__context, key, map[assoc][1], val);
          }

          map[assoc] = [key, val];
        }
      }

      return this;
    }
  end

  def rassoc(object)
    %x{
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (#{`bucket[1]` == object}) {
          return [bucket[0], bucket[1]];
        }
      }

      return null;
    }
  end

  def reject(&block)
    return enum_for :reject unless block_given?

    %x{
      var map = this.map, result = __hash(), map2 = result.map;

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value == null) {
          map2[bucket[0]] = [bucket[0], bucket[1]];
        }
      }

      return result;
    }
  end

  def replace(other)
    %x{
      var map = this.map = {};

      for (var assoc in other.map) {
        var bucket = other.map[assoc];

        map[bucket[0]] = [bucket[0], bucket[1]];
      }

      return this;
    }
  end

  def select(&block)
    return enum_for :select unless block_given?

    %x{
      var map = this.map, result = __hash(), map2 = result.map;

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value != null) {
          map2[bucket[0]] = [bucket[0], bucket[1]];
        }
      }

      return result;
    }
  end

  def select!(&block)
    return enum_for :select! unless block_given?

    %x{
      var map = this.map, result = null;

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value == null) {
          delete map[assoc];
          result = this;
        }
      }

      return result;
    }
  end

  def shift
    %x{
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];
        delete map[assoc];
        return [bucket[0], bucket[1]];
      }

      return null;
    }
  end

  alias size length

  def to_a
    %x{
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc];

        result.push([bucket[0], bucket[1]]);
      }

      return result;
    }
  end

  def to_hash
    self
  end

  def to_json
    %x{
      var parts = [], map = this.map, bucket;

      for (var assoc in map) {
        bucket = map[assoc];
        parts.push(#{ `bucket[0]`.to_json } + ': ' + #{ `bucket[1]`.to_json });
      }

      return '{' + parts.join(', ') + '}';
    }
  end

  alias to_s inspect

  alias update merge!

  def value?(value)
    %x{
      var map = this.map;

      for (var assoc in map) {
        var v = map[assoc][1];
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

      for (var assoc in map) {
        result.push(map[assoc][1]);
      }

      return result;
    }
  end
end
