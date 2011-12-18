class Hash
  include Enumerable

  def self.[](*objs)
    `VM.H.apply(null, objs)`
  end

  def self.allocate
    `VM.H()`
  end

  def self.new
    `VM.H()`
  end

  def ==(other)
    `
      if (self === other) {
        return true;
      }

      if (!other.map) {
        return false;
      }

      var map  = self.map,
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
    `
  end

  def [](key)
    `
      var hash = #{key.hash},
          bucket;

      if (bucket = self.map[hash]) {
        return bucket[1];
      }

      return self.none;
    `
  end

  def []=(key, value)
    `
      var hash       = #{key.hash};
      self.map[hash] = [key, value];

      return value;
    `
  end

  def assoc(object)
    `
      for (var assoc in self.map) {
        var bucket = self.map[assoc];

        if (#{`bucket[0]` == `object`}) {
          return [bucket[0], bucket[1]];
        }
      }

      return nil;
    `
  end

  def clear
    `
      self.map = {};

      return self;
    `
  end

  def clone
    `
      var result = VM.H(),
          map    = self.map,
          map2   = result.map;

      for (var assoc in map) {
        map2[assoc] = [map[assoc][0], map[assoc][1]];
      }

      return result;
    `
  end

  def default
    `self.none`
  end

  def default=(object)
    `self.none = object`
  end

  def default_proc
    `self.proc`
  end

  def default_proc=(proc)
    `self.proc = proc`
  end

  def delete(key)
    `
      var map  = self.map,
          hash = #{key.hash},
          result;

      if (result = map[hash]) {
        result = bucket[1];

        delete map[hash];
      }

      return result;
    `
  end

  def delete_if(&block)
    return enum_for :delete_if unless block_given?

    `
      var map = self.map;

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = $yielder.call($context, null, bucket[0], bucket[1])) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          delete map[assoc];
        }
      }

      return self;
    `
  end

  def each(&block)
    return enum_for :each unless block_given?

    `
      var map = self.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ($yielder.call($context, null, bucket[0], bucket[1]) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  def each_key(&block)
    return enum_for :each_key unless block_given?

    `
      var map = self.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ($yielder.call($context, null, bucket[0]) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  alias_method :each_pair, :each

  def each_value(&block)
    return enum_for :each_value unless block_given?

    `
      var map = self.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ($yielder.call($context, null, bucket[1]) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  def empty?
    `
      for (var assoc in self.map) {
        return false;
      }

      return true;
    `
  end

  alias_method :eql?, :==

  def fetch(key, defaults = undefined, &block)
    `
      var bucket = self.map[#{key.hash}];

      if (block !== nil) {
        var value;

        if ((value = $yielder.call($context, null, key)) === $breaker) {
          return $breaker.$v;
        }

        return value;
      }

      if (defaults !== undefined) {
        return defaults;
      }

      rb_raise(RubyKeyError, 'key not found');
    `
  end

  def flatten(level = undefined)
    `
      var map    = self.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc],
            key    = bucket[0],
            value  = bucket[1];

        result.push(key);

        if (value.$f & T_ARRAY) {
          if (level === undefined || level === 1) {
            result.push(value);
          }
          else {
            result = result.concat(#{value.flatten(level - 1)});
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
    `!!self.map[#{key.hash}]`
  end

  def has_value?(value)
    `
      for (var assoc in self.map) {
        if (#{`self.map[assoc][1]` == value}) {
          return true;
        }
      }

      return false;
    `
  end

  def hash
    `self.$id`
  end

  def inspect
    `
      var inspect = [],
          map     = self.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        inspect.push(#{`bucket[0]`.inspect} + '=>' + #{`bucket[1]`.inspect});
      }
      return '{' + inspect.join(', ') + '}';
    `
  end

  def invert
    `
      var result = VM.H(),
          map    = self.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[#{`bucket[1]`.hash}] = [bucket[0], bucket[1]];
      }

      return result;
    `
  end

  def key(object)
    `
      for (var assoc in self.map) {
        var bucket = self.map[assoc];

        if (#{object == `bucket[1]`}) {
          return bucket[0];
        }
      }

      return nil;
    `
  end

  alias_method :key?, :has_key?

  def keys
    `
      var result = [];

      for (var assoc in self.map) {
        result.push(self.map[assoc][0]);
      }

      return result;
    `
  end

  def length
    `
      var result = 0;

      for (var assoc in self.map) {
        result++;
      }

      return result;
    `
  end

  alias_method :member?, :has_key?

  def merge(other)
    `
      var result = VM.H(),
          map    = self.map,
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
    `
  end

  def merge!(other)
    `
      var map  = self.map,
          map2 = other.map;

      for (var assoc in map2) {
        var bucket = map2[assoc];

        map[assoc] = [bucket[0], bucket[1]];
      }

      return self;
    `
  end

  def rassoc(object)
    `
      var map = self.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (#{`bucket[1]` == object}) {
          return [bucket[0], bucket[1]];
        }
      }

      return nil;
    `
  end

  def replace(other)
    `
      var map = self.map = {};

      for (var assoc in other.map) {
        var bucket = other.map[assoc];

        map[assoc] = [bucket[0], bucket[1]];
      }

      return self;
    `
  end

  alias_method :size, :length

  def to_a
    `
      var map    = self.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc];

        result.push([bucket[0], bucket[1]]);
      }

      return result;
    `
  end

  def to_hash
    self
  end

  def to_native
    `
      var map    = self.map,
          result = {};

      for (var assoc in map) {
        var key   = map[assoc][0],
            value = map[assoc][1];

        result[key] = #{Opal.object?(`value`) ? `value`.to_native : `value`};
      }

      return result;
    `
  end

  alias_method :to_s, :inspect

  alias_method :update, :merge!

  def values
    `
      var map    = self.map,
          result = [];

      for (var assoc in map) {
        result.push(map[assoc][1]);
      }

      return result;
    `
  end
end
