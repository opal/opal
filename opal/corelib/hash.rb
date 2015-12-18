require 'corelib/enumerable'

class Hash
  include Enumerable

  # Mark all hash instances as valid hashes (used to check keyword args, etc)
  `def.$$is_hash = true`

  def self.[](*argv)
    %x{
      var hash, argc = argv.length, i;

      if (argc === 1) {
        hash = #{Opal.coerce_to?(argv[0], Hash, :to_hash)};
        if (hash !== nil) {
          return #{allocate.merge!(`hash`)};
        }

        argv = #{Opal.coerce_to?(argv[0], Array, :to_ary)};
        if (argv === nil) {
          #{raise ArgumentError, 'odd number of arguments for Hash'}
        }

        argc = argv.length;
        hash = #{allocate};

        for (i = 0; i < argc; i++) {
          if (!argv[i].$$is_array) continue;
          switch(argv[i].length) {
          case 1:
            hash.$store(argv[i][0], nil);
            break;
          case 2:
            hash.$store(argv[i][0], argv[i][1]);
            break;
          default:
            #{raise ArgumentError, "invalid number of elements (#{`argv[i].length`} for 1..2)"}
          }
        }

        return hash;
      }

      if (argc % 2 !== 0) {
        #{raise ArgumentError, 'odd number of arguments for Hash'}
      }

      hash = #{allocate};

      for (i = 0; i < argc; i += 2) {
        hash.$store(argv[i], argv[i + 1]);
      }

      return hash;
    }
  end

  def self.allocate
    %x{
      var hash = new self.$$alloc();

      Opal.hash_init(hash);

      hash.none = nil;
      hash.proc = nil;

      return hash;
    }
  end

  def self.try_convert(obj)
    Opal.coerce_to?(obj, Hash, :to_hash)
  end

  def initialize(defaults = undefined, &block)
    %x{
      if (defaults !== undefined && block !== nil) {
        #{raise ArgumentError, 'wrong number of arguments (1 for 0)'}
      }
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

      if (!other.$$is_hash) {
        return false;
      }

      if (self.$$keys.length !== other.$$keys.length) {
        return false;
      }

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, other_value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
          other_value = other.$$smap[key];
        } else {
          value = key.value;
          other_value = Opal.hash_get(other, key.key);
        }

        if (other_value === undefined || !value['$eql?'](other_value)) {
          return false;
        }
      }

      return true;
    }
  end

  def [](key)
    %x{
      var value = Opal.hash_get(self, key);

      if (value !== undefined) {
        return value;
      }

      return self.$default(key);
    }
  end

  def []=(key, value)
    %x{
      Opal.hash_put(self, key, value);
      return value;
    }
  end

  def assoc(object)
    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          if (#{`key` == object}) {
            return [key, self.$$smap[key]];
          }
        } else {
          if (#{`key.key` == object}) {
            return [key.key, key.value];
          }
        }
      }

      return nil;
    }
  end

  def clear
    %x{
      Opal.hash_init(self);
      return self;
    }
  end

  def clone
    %x{
      var hash = new self.$$class.$$alloc();

      Opal.hash_init(hash);
      Opal.hash_clone(self, hash);

      return hash;
    }
  end

  def default(key = undefined)
    %x{
      if (key !== undefined && #@proc !== nil) {
        return #@proc.$call(self, key);
      }
      return #@none;
    }
  end

  def default=(object)
    %x{
      self.proc = nil;
      self.none = object;

      return object;
    }
  end

  def default_proc
    @proc
  end

  def default_proc=(proc)
    %x{
      if (proc !== nil) {
        proc = #{Opal.coerce_to!(proc, Proc, :to_proc)};

        if (#{proc.lambda?} && #{proc.arity.abs} !== 2) {
          #{raise TypeError, 'default_proc takes two arguments'};
        }
      }

      self.none = nil;
      self.proc = proc;

      return proc;
    }
  end

  def delete(key, &block)
    %x{
      var value = Opal.hash_delete(self, key);

      if (value !== undefined) {
        return value;
      }

      if (block !== nil) {
        return #{block.call(key)};
      }

      return nil;
    }
  end

  def delete_if(&block)
    return enum_for(:delete_if){self.size} unless block

    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj !== false && obj !== nil) {
          if (Opal.hash_delete(self, key) !== undefined) {
            length--;
            i--;
          }
        }
      }

      return self;
    }
  end

  alias dup clone

  def each(&block)
    return enum_for(:each){self.size} unless block

    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = Opal.yield1(block, [key, value]);

        if (obj === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    }
  end

  def each_key(&block)
    return enum_for(:each_key){self.size} unless block

    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (block(key.$$is_string ? key : key.key) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    }
  end

  alias each_pair each

  def each_value(&block)
    return enum_for(:each_value){self.size} unless block

    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (block(key.$$is_string ? self.$$smap[key] : key.value) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    }
  end

  def empty?
    `self.$$keys.length === 0`
  end

  alias eql? ==

  def fetch(key, defaults = undefined, &block)
    %x{
      var value = Opal.hash_get(self, key);

      if (value !== undefined) {
        return value;
      }

      if (block !== nil) {
        value = block(key);

        if (value === $breaker) {
          return $breaker.$v;
        }

        return value;
      }

      if (defaults !== undefined) {
        return defaults;
      }
    }

    raise KeyError, "key not found: #{key.inspect}"
  end

  def flatten(level = 1)
    level = Opal.coerce_to!(level, Integer, :to_int)

    %x{
      var result = [];

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        result.push(key);

        if (value.$$is_array) {
          if (level === 1) {
            result.push(value);
            continue;
          }

          result = result.concat(#{`value`.flatten(`level - 2`)});
          continue;
        }

        result.push(value);
      }

      return result;
    }
  end

  def has_key?(key)
    `Opal.hash_get(self, key) !== undefined`
  end

  def has_value?(value)
    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (#{`(key.$$is_string ? self.$$smap[key] : key.value)` == value}) {
          return true;
        }
      }

      return false;
    }
  end

  def hash
    %x{
      var top = (Opal.hash_ids === undefined),
          hash_id = self.$object_id(),
          result = ['Hash'],
          key, item;

      try {
        if (top) {
          Opal.hash_ids = {};
        }

        if (Opal.hash_ids.hasOwnProperty(hash_id)) {
          return 'self';
        }

        for (key in Opal.hash_ids) {
          if (Opal.hash_ids.hasOwnProperty(key)) {
            item = Opal.hash_ids[key];
            if (#{eql?(`item`)}) {
              return 'self';
            }
          }
        }

        Opal.hash_ids[hash_id] = self;

        for (var i = 0, keys = self.$$keys, length = keys.length; i < length; i++) {
          key = keys[i];

          if (key.$$is_string) {
            result.push([key, self.$$smap[key].$hash()]);
          } else {
            result.push([key.key_hash, key.value.$hash()]);
          }
        }

        return result.sort().join();

      } finally {
        if (top) {
          delete Opal.hash_ids;
        }
      }
    }
  end

  alias include? has_key?

  def index(object)
    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        if (#{`value` == object}) {
          return key;
        }
      }

      return nil;
    }
  end

  def indexes(*args)
    %x{
      var result = [];

      for (var i = 0, length = args.length, key, value; i < length; i++) {
        key = args[i];
        value = Opal.hash_get(self, key);

        if (value === undefined) {
          result.push(#{default});
          continue;
        }

        result.push(value);
      }

      return result;
    }
  end

  alias indices indexes

  `var inspect_ids;`

  def inspect
    %x{
      var top = (inspect_ids === undefined),
          hash_id = self.$object_id(),
          result = [];

      try {
        if (top) {
          inspect_ids = {};
        }

        if (inspect_ids.hasOwnProperty(hash_id)) {
          return '{...}';
        }

        inspect_ids[hash_id] = true;

        for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
          key = keys[i];

          if (key.$$is_string) {
            value = self.$$smap[key];
          } else {
            value = key.value;
            key = key.key;
          }

          result.push(key.$inspect() + '=>' + value.$inspect());
        }

        return '{' + result.join(', ') + '}';

      } finally {
        if (top) {
          inspect_ids = undefined;
        }
      }
    }
  end

  def invert
    %x{
      var hash = Opal.hash();

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        Opal.hash_put(hash, value, key);
      }

      return hash;
    }
  end

  def keep_if(&block)
    return enum_for(:keep_if){self.size} unless block

    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj === $breaker) {
          return $breaker.$v;
        }

        if (obj === false || obj === nil) {
          if (Opal.hash_delete(self, key) !== undefined) {
            length--;
            i--;
          }
        }
      }

      return self;
    }
  end

  alias key index

  alias key? has_key?

  def keys
    %x{
      var result = [];

      for (var i = 0, keys = self.$$keys, length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          result.push(key);
        } else {
          result.push(key.key);
        }
      }

      return result;
    }
  end

  def length
    `self.$$keys.length`
  end

  alias member? has_key?

  def merge(other, &block)
    dup.merge!(other, &block)
  end

  def merge!(other, &block)
    %x{
      if (!#{Hash === other}) {
        other = #{Opal.coerce_to!(other, Hash, :to_hash)};
      }

      var i, other_keys = other.$$keys, length = other_keys.length, key, value, other_value;

      if (block === nil) {
        for (i = 0; i < length; i++) {
          key = other_keys[i];

          if (key.$$is_string) {
            other_value = other.$$smap[key];
          } else {
            other_value = key.value;
            key = key.key;
          }

          Opal.hash_put(self, key, other_value);
        }

        return self;
      }

      for (i = 0; i < length; i++) {
        key = other_keys[i];

        if (key.$$is_string) {
          other_value = other.$$smap[key];
        } else {
          other_value = key.value;
          key = key.key;
        }

        value = Opal.hash_get(self, key);

        if (value === undefined) {
          Opal.hash_put(self, key, other_value);
          continue;
        }

        Opal.hash_put(self, key, block(key, value, other_value));
      }

      return self;
    }
  end

  def rassoc(object)
    %x{
      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        if (#{`value` == object}) {
          return [key, value];
        }
      }

      return nil;
    }
  end

  def rehash
    %x{
      Opal.hash_rehash(self);
      return self;
    }
  end

  def reject(&block)
    return enum_for(:reject){self.size} unless block

    %x{
      var hash = Opal.hash();

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj === $breaker) {
          return $breaker.$v;
        }

        if (obj === false || obj === nil) {
          Opal.hash_put(hash, key, value);
        }
      }

      return hash;
    }
  end

  def reject!(&block)
    return enum_for(:reject!){self.size} unless block

    %x{
      var changes_were_made = false;

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj === $breaker) {
          return $breaker.$v;
        }

        if (obj !== false && obj !== nil) {
          if (Opal.hash_delete(self, key) !== undefined) {
            changes_were_made = true;
            length--;
            i--;
          }
        }
      }

      return changes_were_made ? self : nil;
    }
  end

  def replace(other)
    other = Opal.coerce_to!(other, Hash, :to_hash)

    %x{
      Opal.hash_init(self);

      for (var i = 0, other_keys = other.$$keys, length = other_keys.length, key, value, other_value; i < length; i++) {
        key = other_keys[i];

        if (key.$$is_string) {
          other_value = other.$$smap[key];
        } else {
          other_value = key.value;
          key = key.key;
        }

        Opal.hash_put(self, key, other_value);
      }
    }

    if other.default_proc
      self.default_proc = other.default_proc
    else
      self.default = other.default
    end

    self
  end

  def select(&block)
    return enum_for(:select){self.size} unless block

    %x{
      var hash = Opal.hash();

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj === $breaker) {
          return $breaker.$v;
        }

        if (obj !== false && obj !== nil) {
          Opal.hash_put(hash, key, value);
        }
      }

      return hash;
    }
  end

  def select!(&block)
    return enum_for(:select!){self.size} unless block

    %x{
      var result = nil;

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj === $breaker) {
          return $breaker.$v;
        }

        if (obj === false || obj === nil) {
          if (Opal.hash_delete(self, key) !== undefined) {
            length--;
            i--;
          }
          result = self;
        }
      }

      return result;
    }
  end

  def shift
    %x{
      var keys = self.$$keys,
          key;

      if (keys.length > 0) {
        key = keys[0];

        key = key.$$is_string ? key : key.key;

        return [key, Opal.hash_delete(self, key)];
      }

      return self.$default(nil);
    }
  end

  alias size length

  alias_method :store, :[]=

  def to_a
    %x{
      var result = [];

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        result.push([key, value]);
      }

      return result;
    }
  end

  def to_h
    %x{
      if (self.$$class === Opal.Hash) {
        return self;
      }

      var hash = new Opal.Hash.$$alloc();

      Opal.hash_init(hash);
      Opal.hash_clone(self, hash);

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
      var result = [];

      for (var i = 0, keys = self.$$keys, length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          result.push(self.$$smap[key]);
        } else {
          result.push(key.value);
        }
      }

      return result;
    }
  end
end
