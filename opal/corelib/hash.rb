require 'corelib/enumerable'

# ---
# Internal properties:
#
# - $$map         [JS::Object<String => hash-bucket>] the hash table for ordinary keys
# - $$smap        [JS::Object<String => hash-bucket>] the hash table for string keys
# - $$keys        [Array<hash-bucket>] the list of all keys
# - $$proc        [Proc,null,nil] the default proc used for missing keys
# - hash-bucket   [JS::Object] an element of a linked list that holds hash values, keys are `{key:,key_hash:,value:,next:}`
class Hash
  include Enumerable

  # Mark all hash instances as valid hashes (used to check keyword args, etc)
  `self[Opal.s.$$prototype][Opal.s.$$is_hash] = true`

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
          if (!argv[i][Opal.s.$$is_array]) continue;
          switch(argv[i].length) {
          case 1:
            hash[Opal.s.$store](argv[i][0], nil);
            break;
          case 2:
            hash[Opal.s.$store](argv[i][0], argv[i][1]);
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
        hash[Opal.s.$store](argv[i], argv[i + 1]);
      }

      return hash;
    }
  end

  def self.allocate
    %x{
      var hash = new self[Opal.s.$$constructor]();

      Opal.hash_init(hash);

      hash[Opal.s.$$none] = nil;
      hash[Opal.s.$$proc] = nil;

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
      self[Opal.s.$$none] = (defaults === undefined ? nil : defaults);
      self[Opal.s.$$proc] = block;

      return self;
    }
  end

  def ==(other)
    %x{
      if (self === other) {
        return true;
      }

      if (!other[Opal.s.$$is_hash]) {
        return false;
      }

      if (self[Opal.s.$$keys].length !== other[Opal.s.$$keys].length) {
        return false;
      }

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, other_value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
          other_value = other[Opal.s.$$smap][key];
        } else {
          value = key.value;
          other_value = Opal.hash_get(other, key.key);
        }

        if (other_value === undefined || !value[Opal.s['$eql?']](other_value)) {
          return false;
        }
      }

      return true;
    }
  end

  def >=(other)
    other = Opal.coerce_to!(other, Hash, :to_hash)

    %x{
      if (self[Opal.s.$$keys].length < other[Opal.s.$$keys].length) {
        return false
      }
    }

    result = true

    other.each do |other_key, other_val|
      val = fetch(other_key, `null`)

      %x{
        if (val == null || val !== other_val) {
          result = false;
          return;
        }
      }
    end

    result
  end

  def >(other)
    other = Opal.coerce_to!(other, Hash, :to_hash)

    %x{
      if (self[Opal.s.$$keys].length <= other[Opal.s.$$keys].length) {
        return false
      }
    }

    self >= other
  end

  def <(other)
    other = Opal.coerce_to!(other, Hash, :to_hash)
    other > self
  end

  def <=(other)
    other = Opal.coerce_to!(other, Hash, :to_hash)
    other >= self
  end

  def [](key)
    %x{
      var value = Opal.hash_get(self, key);

      if (value !== undefined) {
        return value;
      }

      return self[Opal.s.$default](key);
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
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          if (#{`key` == object}) {
            return [key, self[Opal.s.$$smap][key]];
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
      var hash = new self[Opal.s.$$class]();

      Opal.hash_init(hash);
      Opal.hash_clone(self, hash);

      return hash;
    }
  end

  def compact
    %x{
      var hash = Opal.hash();

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        if (value !== nil) {
          Opal.hash_put(hash, key, value);
        }
      }

      return hash;
    }
  end

  def compact!
    %x{
      var changes_were_made = false;

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        if (value === nil) {
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

  def compare_by_identity
    %x{
      var i, ii, key, keys = self[Opal.s.$$keys], identity_hash;

      if (self[Opal.s.$$by_identity]) return self;
      if (self[Opal.s.$$keys].length === 0) {
        self[Opal.s.$$by_identity] = true
        return self;
      }

      identity_hash = #{ {}.compare_by_identity };
      for(i = 0, ii = keys.length; i < ii; i++) {
        key = keys[i];
        if (!key[Opal.s.$$is_string]) key = key.key;
        Opal.hash_put(identity_hash, key, Opal.hash_get(self, key));
      }

      self[Opal.s.$$by_identity] = true;
      self[Opal.s.$$map] = identity_hash[Opal.s.$$map];
      self[Opal.s.$$smap] = identity_hash[Opal.s.$$smap];
      return self;
    }
  end

  def compare_by_identity?
    `self[Opal.s.$$by_identity] === true`
  end

  def default(key = undefined)
    %x{
      if (key !== undefined && self[Opal.s.$$proc] !== nil && self[Opal.s.$$proc] !== undefined) {
        return self[Opal.s.$$proc][Opal.s.$call](self, key);
      }
      if (self[Opal.s.$$none] === undefined) {
        return nil;
      }
      return self[Opal.s.$$none];
    }
  end

  def default=(object)
    %x{
      self[Opal.s.$$proc] = nil;
      self[Opal.s.$$none] = object;

      return object;
    }
  end

  def default_proc
    %x{
      if (self[Opal.s.$$proc] !== undefined) {
        return self[Opal.s.$$proc];
      }
      return nil;
    }
  end

  def default_proc=(default_proc)
    %x{
      var proc = default_proc;

      if (proc !== nil) {
        proc = #{Opal.coerce_to!(`proc`, Proc, :to_proc)};

        if (#{`proc`.lambda?} && #{`proc`.arity.abs} !== 2) {
          #{raise TypeError, 'default_proc takes two arguments'};
        }
      }

      self[Opal.s.$$none] = nil;
      self[Opal.s.$$proc] = proc;

      return default_proc;
    }
  end

  def delete(key, &block)
    %x{
      var value = Opal.hash_delete(self, key);

      if (value !== undefined) {
        return value;
      }

      if (block !== nil) {
        return #{yield key};
      }

      return nil;
    }
  end

  def delete_if(&block)
    return enum_for(:delete_if) { size } unless block

    %x{
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
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

  def dig(key, *keys)
    item = self[key]

    %x{
      if (item === nil || keys.length === 0) {
        return item;
      }
    }

    unless item.respond_to?(:dig)
      raise TypeError, "#{item.class} does not have #dig method"
    end

    item.dig(*keys)
  end

  def each(&block)
    return enum_for(:each) { size } unless block

    %x{
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        Opal.yield1(block, [key, value]);
      }

      return self;
    }
  end

  def each_key(&block)
    return enum_for(:each_key) { size } unless block

    %x{
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key; i < length; i++) {
        key = keys[i];

        block(key[Opal.s.$$is_string] ? key : key.key);
      }

      return self;
    }
  end

  alias each_pair each

  def each_value(&block)
    return enum_for(:each_value) { size } unless block

    %x{
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key; i < length; i++) {
        key = keys[i];

        block(key[Opal.s.$$is_string] ? self[Opal.s.$$smap][key] : key.value);
      }

      return self;
    }
  end

  def empty?
    `self[Opal.s.$$keys].length === 0`
  end

  alias eql? ==

  def fetch(key, defaults = undefined, &block)
    %x{
      var value = Opal.hash_get(self, key);

      if (value !== undefined) {
        return value;
      }

      if (block !== nil) {
        return block(key);
      }

      if (defaults !== undefined) {
        return defaults;
      }
    }

    raise KeyError.new("key not found: #{key.inspect}", key: key, receiver: self)
  end

  def fetch_values(*keys, &block)
    keys.map { |key| fetch(key, &block) }
  end

  def flatten(level = 1)
    level = Opal.coerce_to!(level, Integer, :to_int)

    %x{
      var result = [];

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        result.push(key);

        if (value[Opal.s.$$is_array]) {
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
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (#{`(key[Opal.s.$$is_string] ? self[Opal.s.$$smap][key] : key.value)` == value}) {
          return true;
        }
      }

      return false;
    }
  end

  def hash
    %x{
      var top = (Opal.hash_ids === undefined),
          hash_id = self[Opal.s.$object_id](),
          result = ['Hash'],
          key, item;

      try {
        if (top) {
          Opal.hash_ids = Object.create(null);
        }

        if (Opal[hash_id]) {
          return 'self';
        }

        for (key in Opal.hash_ids) {
          item = Opal.hash_ids[key];
          if (#{eql?(`item`)}) {
            return 'self';
          }
        }

        Opal.hash_ids[hash_id] = self;

        for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length; i < length; i++) {
          key = keys[i];

          if (key[Opal.s.$$is_string]) {
            result.push([key, self[Opal.s.$$smap][key][Opal.s.$hash]()]);
          } else {
            result.push([key.key_hash, key.value[Opal.s.$hash]()]);
          }
        }

        return result.sort().join();

      } finally {
        if (top) {
          Opal.hash_ids = undefined;
        }
      }
    }
  end

  alias include? has_key?

  def index(object)
    %x{
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
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

  `var inspect_ids`

  def inspect
    %x{
      var top = (inspect_ids === undefined),
          hash_id = self[Opal.s.$object_id](),
          result = [];

      try {
        if (top) {
          inspect_ids = {};
        }

        if (inspect_ids.hasOwnProperty(hash_id)) {
          return '{...}';
        }

        inspect_ids[hash_id] = true;

        for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
          key = keys[i];

          if (key[Opal.s.$$is_string]) {
            value = self[Opal.s.$$smap][key];
          } else {
            value = key.value;
            key = key.key;
          }

          result.push(key[Opal.s.$inspect]() + '=>' + value[Opal.s.$inspect]());
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

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
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
    return enum_for(:keep_if) { size } unless block

    %x{
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

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

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          result.push(key);
        } else {
          result.push(key.key);
        }
      }

      return result;
    }
  end

  def length
    `self[Opal.s.$$keys].length`
  end

  alias member? has_key?

  def merge(*others, &block)
    dup.merge!(*others, &block)
  end

  def merge!(*others, &block)
    %x{
      var i, j, other, other_keys, length, key, value, other_value;
      for (i = 0; i < others.length; ++i) {
        other = #{Opal.coerce_to!(`others[i]`, Hash, :to_hash)};
        other_keys = other[Opal.s.$$keys], length = other_keys.length;

        if (block === nil) {
          for (j = 0; j < length; j++) {
            key = other_keys[j];

            if (key[Opal.s.$$is_string]) {
              other_value = other[Opal.s.$$smap][key];
            } else {
              other_value = key.value;
              key = key.key;
            }

            Opal.hash_put(self, key, other_value);
          }
        } else {
          for (j = 0; j < length; j++) {
            key = other_keys[j];

            if (key[Opal.s.$$is_string]) {
              other_value = other[Opal.s.$$smap][key];
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
        }
      }

      return self;
    }
  end

  def rassoc(object)
    %x{
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
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
    return enum_for(:reject) { size } unless block

    %x{
      var hash = Opal.hash();

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj === false || obj === nil) {
          Opal.hash_put(hash, key, value);
        }
      }

      return hash;
    }
  end

  def reject!(&block)
    return enum_for(:reject!) { size } unless block

    %x{
      var changes_were_made = false;

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

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

      for (var i = 0, other_keys = other[Opal.s.$$keys], length = other_keys.length, key, value, other_value; i < length; i++) {
        key = other_keys[i];

        if (key[Opal.s.$$is_string]) {
          other_value = other[Opal.s.$$smap][key];
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
    return enum_for(:select) { size } unless block

    %x{
      var hash = Opal.hash();

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj !== false && obj !== nil) {
          Opal.hash_put(hash, key, value);
        }
      }

      return hash;
    }
  end

  def select!(&block)
    return enum_for(:select!) { size } unless block

    %x{
      var result = nil;

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

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

  alias filter select
  alias filter! select!

  def shift
    %x{
      var keys = self[Opal.s.$$keys],
          key;

      if (keys.length > 0) {
        key = keys[0];

        key = key[Opal.s.$$is_string] ? key : key.key;

        return [key, Opal.hash_delete(self, key)];
      }

      return self[Opal.s.$default](nil);
    }
  end

  alias size length

  def slice(*keys)
    %x{
      var result = Opal.hash();

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], value = Opal.hash_get(self, key);

        if (value !== undefined) {
          Opal.hash_put(result, key, value);
        }
      }

      return result;
    }
  end

  alias store []=

  def to_a
    %x{
      var result = [];

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        result.push([key, value]);
      }

      return result;
    }
  end

  def to_h(&block)
    return map(&block).to_h if block_given?

    %x{
      if (self[Opal.s.$$class] === Opal.Hash) {
        return self;
      }

      var hash = new Opal.Hash();

      Opal.hash_init(hash);
      Opal.hash_clone(self, hash);

      return hash;
    }
  end

  def to_hash
    self
  end

  def to_proc
    proc do |key = undefined|
      %x{
        if (key == null) {
          #{raise ArgumentError, 'no key given'}
        }
      }

      self[key]
    end
  end

  alias to_s inspect

  def transform_keys(&block)
    return enum_for(:transform_keys) { size } unless block

    %x{
      var result = Opal.hash();

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        key = Opal.yield1(block, key);

        Opal.hash_put(result, key, value);
      }

      return result;
    }
  end

  def transform_keys!(&block)
    return enum_for(:transform_keys!) { size } unless block

    %x{
      var keys = Opal.slice.call(self[Opal.s.$$keys]),
          i, length = keys.length, key, value, new_key;

      for (i = 0; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        new_key = Opal.yield1(block, key);

        Opal.hash_delete(self, key);
        Opal.hash_put(self, new_key, value);
      }

      return self;
    }
  end

  def transform_values(&block)
    return enum_for(:transform_values) { size } unless block

    %x{
      var result = Opal.hash();

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        value = Opal.yield1(block, value);

        Opal.hash_put(result, key, value);
      }

      return result;
    }
  end

  def transform_values!(&block)
    return enum_for(:transform_values!) { size } unless block

    %x{
      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          value = self[Opal.s.$$smap][key];
        } else {
          value = key.value;
          key = key.key;
        }

        value = Opal.yield1(block, value);

        Opal.hash_put(self, key, value);
      }

      return self;
    }
  end

  alias update merge!

  alias value? has_value?

  alias values_at indexes

  def values
    %x{
      var result = [];

      for (var i = 0, keys = self[Opal.s.$$keys], length = keys.length, key; i < length; i++) {
        key = keys[i];

        if (key[Opal.s.$$is_string]) {
          result.push(self[Opal.s.$$smap][key]);
        } else {
          result.push(key.value);
        }
      }

      return result;
    }
  end
end
