# helpers: yield1, hash, hash_init, hash_get, hash_put, hash_delete

require 'corelib/enumerable'

# ---
# Internal properties:
#
# - $$map         [JS::Object<String => hash-bucket>] the hash table for ordinary keys
# - $$smap        [JS::Object<String => hash-bucket>] the hash table for string keys
# - $$keys        [Array<hash-bucket>] the list of all keys
# - $$proc        [Proc,null,nil] the default proc used for missing keys
# - hash-bucket   [JS::Object] an element of a linked list that holds hash values, keys are `{key:,key_hash:,value:,next:}`
class ::Hash
  include ::Enumerable

  # Mark all hash instances as valid hashes (used to check keyword args, etc)
  `self.$$prototype.$$is_hash = true`

  %x{
    Object.defineProperty(self.$$prototype, 'frozen_err', { value: function() {
      return #{::FrozenError.new("can't modify frozen #{self.class}: #{self}", receiver: self)}
    }});
  }

  def self.[](*argv)
    %x{
      var hash, argc = argv.length, i;

      if (argc === 1) {
        hash = #{::Opal.coerce_to?(argv[0], ::Hash, :to_hash)};
        if (hash !== nil) {
          return #{allocate.merge!(`hash`)};
        }

        argv = #{::Opal.coerce_to?(argv[0], ::Array, :to_ary)};
        if (argv === nil) {
          #{::Kernel.raise ::ArgumentError, 'odd number of arguments for Hash'}
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
            #{::Kernel.raise ::ArgumentError, "invalid number of elements (#{`argv[i].length`} for 1..2)"}
          }
        }

        return hash;
      }

      if (argc % 2 !== 0) {
        #{::Kernel.raise ::ArgumentError, 'odd number of arguments for Hash'}
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
      var hash = new self.$$constructor();

      $hash_init(hash);

      hash.$$none = nil;
      hash.$$proc = nil;

      return hash;
    }
  end

  def self.try_convert(obj)
    ::Opal.coerce_to?(obj, ::Hash, :to_hash)
  end

  def initialize(defaults = undefined, &block)
    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      if (defaults !== undefined && block !== nil) {
        #{::Kernel.raise ::ArgumentError, 'wrong number of arguments (1 for 0)'}
      }
      self.$$none = (defaults === undefined ? nil : defaults);
      self.$$proc = block;

      return self;
    }
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
          other_value = $hash_get(other, key.key);
        }

        if (other_value === undefined || !value['$eql?'](other_value)) {
          return false;
        }
      }

      return true;
    }
  end

  def >=(other)
    other = ::Opal.coerce_to!(other, ::Hash, :to_hash)

    %x{
      if (self.$$keys.length < other.$$keys.length) {
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
    other = ::Opal.coerce_to!(other, ::Hash, :to_hash)

    %x{
      if (self.$$keys.length <= other.$$keys.length) {
        return false
      }
    }

    self >= other
  end

  def <(other)
    other = ::Opal.coerce_to!(other, ::Hash, :to_hash)
    other > self
  end

  def <=(other)
    other = ::Opal.coerce_to!(other, ::Hash, :to_hash)
    other >= self
  end

  def [](key)
    %x{
      var value = $hash_get(self, key);

      if (value !== undefined) {
        return value;
      }

      return self.$default(key);
    }
  end

  def []=(key, value)
    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      $hash_put(self, key, value);
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
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      $hash_init(self);
      return self;
    }
  end

  def clone
    %x{
      var hash = new self.$$class();

      $hash_init(hash);
      Opal.hash_clone(self, hash);

      return hash;
    }
  end

  def compact
    %x{
      var hash = $hash();

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        if (value !== nil) {
          $hash_put(hash, key, value);
        }
      }

      return hash;
    }
  end

  def compact!
    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      var changes_were_made = false;

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        if (value === nil) {
          if ($hash_delete(self, key) !== undefined) {
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
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      var i, ii, key, keys = self.$$keys, identity_hash;

      if (self.$$by_identity) return self;
      if (self.$$keys.length === 0) {
        self.$$by_identity = true
        return self;
      }

      identity_hash = #{ {}.compare_by_identity };
      for(i = 0, ii = keys.length; i < ii; i++) {
        key = keys[i];
        if (!key.$$is_string) key = key.key;
        $hash_put(identity_hash, key, $hash_get(self, key));
      }

      self.$$by_identity = true;
      self.$$map = identity_hash.$$map;
      self.$$smap = identity_hash.$$smap;
      return self;
    }
  end

  def compare_by_identity?
    `self.$$by_identity === true`
  end

  def default(key = undefined)
    %x{
      if (key !== undefined && self.$$proc !== nil && self.$$proc !== undefined) {
        return self.$$proc.$call(self, key);
      }
      if (self.$$none === undefined) {
        return nil;
      }
      return self.$$none;
    }
  end

  def default=(object)
    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      self.$$proc = nil;
      self.$$none = object;

      return object;
    }
  end

  def default_proc
    %x{
      if (self.$$proc !== undefined) {
        return self.$$proc;
      }
      return nil;
    }
  end

  def default_proc=(default_proc)
    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      var proc = default_proc;

      if (proc !== nil) {
        proc = #{::Opal.coerce_to!(`proc`, ::Proc, :to_proc)};

        if (#{`proc`.lambda?} && #{`proc`.arity.abs} !== 2) {
          #{::Kernel.raise ::TypeError, 'default_proc takes two arguments'};
        }
      }

      self.$$none = nil;
      self.$$proc = proc;

      return default_proc;
    }
  end

  def delete(key, &block)
    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }
      var value = $hash_delete(self, key);

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
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

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
          if ($hash_delete(self, key) !== undefined) {
            length--;
            i--;
          }
        }
      }

      return self;
    }
  end

  def dig(key, *keys)
    item = self[key]

    %x{
      if (item === nil || keys.length === 0) {
        return item;
      }
    }

    unless item.respond_to?(:dig)
      ::Kernel.raise ::TypeError, "#{item.class} does not have #dig method"
    end

    item.dig(*keys)
  end

  def each(&block)
    return enum_for(:each) { size } unless block

    %x{
      for (var i = 0, keys = self.$$keys.slice(), length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        $yield1(block, [key, value]);
      }

      return self;
    }
  end

  def each_key(&block)
    return enum_for(:each_key) { size } unless block

    %x{
      for (var i = 0, keys = self.$$keys.slice(), length = keys.length, key; i < length; i++) {
        key = keys[i];

        block(key.$$is_string ? key : key.key);
      }

      return self;
    }
  end

  def each_value(&block)
    return enum_for(:each_value) { size } unless block

    %x{
      for (var i = 0, keys = self.$$keys.slice(), length = keys.length, key; i < length; i++) {
        key = keys[i];

        block(key.$$is_string ? self.$$smap[key] : key.value);
      }

      return self;
    }
  end

  def empty?
    `self.$$keys.length === 0`
  end

  def except(*keys)
    dup.except!(*keys)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  def fetch(key, defaults = undefined, &block)
    %x{
      var value = $hash_get(self, key);

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

    ::Kernel.raise ::KeyError.new("key not found: #{key.inspect}", key: key, receiver: self)
  end

  def fetch_values(*keys, &block)
    keys.map { |key| fetch(key, &block) }
  end

  def flatten(level = 1)
    level = ::Opal.coerce_to!(level, ::Integer, :to_int)

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

  def freeze
    %x{
      if (!self.$$frozen) {
        // calling Object.isFrozen is way slower than testing for a flag
        // set the flag and test for it in the other methods for performance
        self.$$frozen = true;
        Object.freeze(self.$$map);
        Object.freeze(self.$$smap);
        Object.freeze(self.$$keys);
        // some properties (eg. used as cache) are lazily added to instances
        // therefor currently can't freeze the instances
        // Object.freeze(self);
      }
    }
    self
  end

  def frozen?
    `self.$$frozen ? true : false`
  end

  def has_key?(key)
    `$hash_get(self, key) !== undefined`
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
          Opal.hash_ids = undefined;
        }
      }
    }
  end

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
        value = $hash_get(self, key);

        if (value === undefined) {
          result.push(#{default});
          continue;
        }

        result.push(value);
      }

      return result;
    }
  end

  `var inspect_ids`

  def inspect
    %x{
      var top = (inspect_ids === undefined),
          hash_id = self.$object_id(),
          result = [];
    }

    begin
      %x{
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

          key = #{Opal.inspect(`key`)}
          value = #{Opal.inspect(`value`)}

          result.push(key + '=>' + value);
        }

        return '{' + result.join(', ') + '}';
      }
      nil
    ensure
      `if (top) inspect_ids = undefined`
    end
  end

  def invert
    %x{
      var hash = $hash();

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        $hash_put(hash, value, key);
      }

      return hash;
    }
  end

  def keep_if(&block)
    return enum_for(:keep_if) { size } unless block

    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj === false || obj === nil) {
          if ($hash_delete(self, key) !== undefined) {
            length--;
            i--;
          }
        }
      }

      return self;
    }
  end

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

  def merge(*others, &block)
    dup.merge!(*others, &block)
  end

  def merge!(*others, &block)
    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }
      var i, j, other, other_keys, length, key, value, other_value;
      for (i = 0; i < others.length; ++i) {
        other = #{::Opal.coerce_to!(`others[i]`, ::Hash, :to_hash)};
        other_keys = other.$$keys, length = other_keys.length;

        if (block === nil) {
          for (j = 0; j < length; j++) {
            key = other_keys[j];

            if (key.$$is_string) {
              other_value = other.$$smap[key];
            } else {
              other_value = key.value;
              key = key.key;
            }

            $hash_put(self, key, other_value);
          }
        } else {
          for (j = 0; j < length; j++) {
            key = other_keys[j];

            if (key.$$is_string) {
              other_value = other.$$smap[key];
            } else {
              other_value = key.value;
              key = key.key;
            }

            value = $hash_get(self, key);

            if (value === undefined) {
              $hash_put(self, key, other_value);
              continue;
            }

            $hash_put(self, key, block(key, value, other_value));
          }
        }
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
      if (self.$$frozen) { #{raise `self.frozen_err()`} }
      Opal.hash_rehash(self);
      return self;
    }
  end

  def reject(&block)
    return enum_for(:reject) { size } unless block

    %x{
      var hash = $hash();

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value, obj; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        obj = block(key, value);

        if (obj === false || obj === nil) {
          $hash_put(hash, key, value);
        }
      }

      return hash;
    }
  end

  def reject!(&block)
    return enum_for(:reject!) { size } unless block

    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

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

        if (obj !== false && obj !== nil) {
          if ($hash_delete(self, key) !== undefined) {
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
    `if (self.$$frozen) { #{raise `self.frozen_err()`} }`

    other = ::Opal.coerce_to!(other, ::Hash, :to_hash)

    %x{
      $hash_init(self);

      for (var i = 0, other_keys = other.$$keys, length = other_keys.length, key, value, other_value; i < length; i++) {
        key = other_keys[i];

        if (key.$$is_string) {
          other_value = other.$$smap[key];
        } else {
          other_value = key.value;
          key = key.key;
        }

        $hash_put(self, key, other_value);
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
      var hash = $hash();

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
          $hash_put(hash, key, value);
        }
      }

      return hash;
    }
  end

  def select!(&block)
    return enum_for(:select!) { size } unless block

    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

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

        if (obj === false || obj === nil) {
          if ($hash_delete(self, key) !== undefined) {
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
      if (self.$$frozen) { #{raise `self.frozen_err()`} }
      var keys = self.$$keys,
          key;

      if (keys.length > 0) {
        key = keys[0];

        key = key.$$is_string ? key : key.key;

        return [key, $hash_delete(self, key)];
      }

      return self.$default(nil);
    }
  end

  def slice(*keys)
    %x{
      var result = $hash();

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], value = $hash_get(self, key);

        if (value !== undefined) {
          $hash_put(result, key, value);
        }
      }

      return result;
    }
  end

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

  def to_h(&block)
    return map(&block).to_h if block_given?

    %x{
      if (self.$$class === Opal.Hash) {
        return self;
      }

      var hash = new Opal.Hash();

      $hash_init(hash);
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
          #{::Kernel.raise ::ArgumentError, 'no key given'}
        }
      }

      self[key]
    end
  end

  def transform_keys(&block)
    return enum_for(:transform_keys) { size } unless block

    %x{
      var result = $hash();

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        key = $yield1(block, key);

        $hash_put(result, key, value);
      }

      return result;
    }
  end

  def transform_keys!(&block)
    return enum_for(:transform_keys!) { size } unless block

    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      var keys = Opal.slice.call(self.$$keys),
          i, length = keys.length, key, value, new_key;

      for (i = 0; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        new_key = $yield1(block, key);

        $hash_delete(self, key);
        $hash_put(self, new_key, value);
      }

      return self;
    }
  end

  def transform_values(&block)
    return enum_for(:transform_values) { size } unless block

    %x{
      var result = $hash();

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        value = $yield1(block, value);

        $hash_put(result, key, value);
      }

      return result;
    }
  end

  def transform_values!(&block)
    return enum_for(:transform_values!) { size } unless block

    %x{
      if (self.$$frozen) { #{raise `self.frozen_err()`} }

      for (var i = 0, keys = self.$$keys, length = keys.length, key, value; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = self.$$smap[key];
        } else {
          value = key.value;
          key = key.key;
        }

        value = $yield1(block, value);

        $hash_put(self, key, value);
      }

      return self;
    }
  end

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

  alias dup clone
  alias each_pair each
  alias eql? ==
  alias filter select
  alias filter! select!
  alias include? has_key?
  alias indices indexes
  alias key index
  alias key? has_key?
  alias member? has_key?
  alias size length
  alias store []=
  alias to_s inspect
  alias update merge!
  alias value? has_value?
  alias values_at indexes
end
