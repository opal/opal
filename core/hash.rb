class Hash
  include Enumerable

  %x{
    var hash_class = this;

    $opal.hash = function() {
      var hash    = new hash_class.$allocator(),
          args    = $slice.call(arguments),
          assocs  = {};

      hash.map    = assocs;
      hash.none   = nil;
      hash.proc   = nil;

      if (args.length == 1 && args[0].o$flags & T_ARRAY) {
        args = args[0];

        for (var i = 0, length = args.length, key; i < length; i++) {
          key = args[i][0];

          assocs[key.$hash()] = [key, args[i][1]];
        }
      }
      else if (arguments.length % 2 == 0) {
        for (var i = 0, length = args.length, key; i < length; i++) {
          key = args[i];

          assocs[key.$hash()] = [key, args[++i]];
        }
      }
      else {
        throw RubyArgError.$new('odd number of arguments for Hash');
      }

      return hash;
    };
  }

  def self.[](*objs)
    `$opal.hash.apply(null, objs)`
  end

  def self.new(defaults = undefined, &block)
    %x{
      var hash = $opal.hash();

      if (defaults !== undefined) {
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
      var hash = #{key.hash},
          bucket;

      if (bucket = this.map[hash]) {
        return bucket[1];
      }

      return this.none;
    }
  end

  def []=(key, value)
    %x{
      var hash       = #{key.hash};
      this.map[hash] = [key, value];

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
      var result = $opal.hash(),
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
      var map  = this.map,
          hash = #{key.hash},
          result;

      if (result = map[hash]) {
        result = bucket[1];

        delete map[hash];
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

        if ((value = $yield.call($context, null, bucket[0], bucket[1])) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          delete map[assoc];
        }
      }

      return this;
    }
  end

  def each(&block)
    return enum_for :each unless block_given?

    %x{
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ($yield.call($context, null, bucket[0], bucket[1]) === $breaker) {
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

        if ($yield.call($context, null, bucket[0]) === $breaker) {
          return $breaker.$v;
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

        if ($yield.call($context, null, bucket[1]) === $breaker) {
          return $breaker.$v;
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
      var bucket = this.map[#{key.hash}];

      if (block !== nil) {
        var value;

        if ((value = $yield.call($context, null, key)) === $breaker) {
          return $breaker.$v;
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

        if (value.o$flags & T_ARRAY) {
          if (level === undefined || level === 1) {
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
    `!!this.map[#{key.hash}]`
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
    `this.o$id`
  end

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
      var result = $opal.hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[#{`bucket[1]`.hash}] = [bucket[0], bucket[1]];
      }

      return result;
    }
  end

  def key(object)
    %x{
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if (#{object == `bucket[1]`}) {
          return bucket[0];
        }
      }

      return nil;
    }
  end

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

  def merge(other)
    %x{
      var result = $opal.hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[assoc] = [bucket[0], bucket[1]];
      }

      map = other.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[assoc] = [bucket[0], bucket[1]];
      }

      return result;
    }
  end

  def merge!(other)
    %x{
      var map  = this.map,
          map2 = other.map;

      for (var assoc in map2) {
        var bucket = map2[assoc];

        map[assoc] = [bucket[0], bucket[1]];
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

      return nil;
    }
  end

  def replace(other)
    %x{
      var map = this.map = {};

      for (var assoc in other.map) {
        var bucket = other.map[assoc];

        map[assoc] = [bucket[0], bucket[1]];
      }

      return this;
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

  alias to_s inspect

  alias update merge!

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
