# helpers: yield1, hash, hash_clone, hash_delete, hash_each, hash_get, hash_put, deny_frozen_access, freeze
# backtick_javascript: true

require 'corelib/enumerable'

# ---
# Internal properties:
#
# - $$keys     [Map<key-array>] optional Map of key arrays, used when objects are used as keys
# - $$proc        [Proc,null,nil] the default proc used for missing keys
# - key-array   [JS::Map] an element of a array that holds objects used as keys, `{ key_hash => [objects...] }`
class ::Hash < `Map`
  include ::Enumerable

  # Mark all hash instances as valid hashes (used to check keyword args, etc)
  `self.$$prototype.$$is_hash = true`

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
      $deny_frozen_access(self);

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

      if (self.size !== other.size) {
        return false;
      }

      return $hash_each(self, true, function(key, value) {
        var other_value = $hash_get(other, key);
        if (other_value === undefined || !value['$eql?'](other_value)) {
          return [true, false];
        }
        return [false, true];
      });
    }
  end

  def >=(other)
    other = ::Opal.coerce_to!(other, ::Hash, :to_hash)

    %x{
      if (self.size < other.size) {
        return false;
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
      if (self.size <= other.size) {
        return false;
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
      $deny_frozen_access(self);

      $hash_put(self, key, value);
      return value;
    }
  end

  def assoc(object)
    %x{
      return $hash_each(self, nil, function(key, value) {
        if (#{`key` == object}) {
          return [true, [key, value]];
        }
        return [false, nil];
      });
    }
  end

  def clear
    %x{
      $deny_frozen_access(self);

      self.clear();
      if (self.$$keys)
        self.$$keys.clear();

      return self;
    }
  end

  def clone
    %x{
      var hash = self.$class().$new();
      return $hash_clone(self, hash);
    }
  end

  def compact
    %x{
      var hash = $hash();

      return $hash_each(self, hash, function(key, value) {
        if (value !== nil) {
          $hash_put(hash, key, value);
        }
        return [false, hash];
      });
    }
  end

  def compact!
    %x{
      $deny_frozen_access(self);

      var result = nil;

      return $hash_each(self, result, function(key, value) {
        if (value === nil) {
          $hash_delete(self, key);
          result = self;
        }
        return [false, result];
      });
    }
  end

  def compare_by_identity
    %x{
      $deny_frozen_access(self);

      if (!self.$$by_identity) {
        self.$$by_identity = true;

        if (self.size !== 0)
          Opal.hash_rehash(self);
      }

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
      $deny_frozen_access(self);

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
      $deny_frozen_access(self);

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
      $deny_frozen_access(self);
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
      $deny_frozen_access(self);

      return $hash_each(self, self, function(key, value) {
        var obj = block(key, value);

        if (obj !== false && obj !== nil) {
          $hash_delete(self, key);
        }
        return [false, self];
      });
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
      return $hash_each(self, self, function(key, value) {
        $yield1(block, [key, value]);
        return [false, self];
      });
    }
  end

  def each_key(&block)
    return enum_for(:each_key) { size } unless block

    %x{
      return $hash_each(self, self, function(key, value) {
        block(key);
        return [false, self];
      });
    }
  end

  def each_value(&block)
    return enum_for(:each_value) { size } unless block

    %x{
      return $hash_each(self, self, function(key, value) {
        block(value);
        return [false, self];
      });
    }
  end

  def empty?
    `self.size === 0`
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

      return $hash_each(self, result, function(key, value) {
        result.push(key);

        if (value.$$is_array) {
          if (level === 1) {
            result.push(value);
            return [false, result];
          }

          result = result.concat(#{`value`.flatten(`level - 2`)});
          return [false, result];
        }

        result.push(value);
        return [false, result];
      });
    }
  end

  def freeze
    return self if frozen?

    `$freeze(self)`
  end

  def has_key?(key)
    `$hash_get(self, key) !== undefined`
  end

  def has_value?(value)
    %x{
      return $hash_each(self, false, function(key, val) {
        if (#{`val` == value}) {
          return [true, true];
        }
        return [false, false];
      });
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

        $hash_each(self, false, function(key, value) {
          result.push([key, value.$hash()]);
          return [false, false];
        });

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
      return $hash_each(self, nil, function(key, value) {
        if (#{`value` == object}) {
          return [true, key];
        }
        return [false, nil];
      });
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

        $hash_each(self, false, function(key, value) {
          value = #{Opal.inspect(`value`)}
          key = #{Opal.inspect(`key`)}

          result.push(key + '=>' + value);
          return [false, false];
        })

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

      return $hash_each(self, hash, function(key, value) {
        $hash_put(hash, value, key);
        return [false, hash];
      });
    }
  end

  def keep_if(&block)
    return enum_for(:keep_if) { size } unless block

    %x{
      $deny_frozen_access(self);

      return $hash_each(self, self, function(key, value) {
        var obj = block(key, value);

        if (obj === false || obj === nil) {
          $hash_delete(self, key);
        }
        return [false, self];
      });
    }
  end

  def keys
    `Array.from(self.keys())`
  end

  def length
    `self.size`
  end

  def merge(*others, &block)
    dup.merge!(*others, &block)
  end

  def merge!(*others, &block)
    %x{
      $deny_frozen_access(self);

      var i, j, other;
      for (i = 0; i < others.length; ++i) {
        other = #{::Opal.coerce_to!(`others[i]`, ::Hash, :to_hash)};

        if (block === nil) {
          $hash_each(other, false, function(key, value) {
            $hash_put(self, key, value);
            return [false, false];
          });
        } else {
          $hash_each(other, false, function(key, value) {
            var val = $hash_get(self, key);

            if (val === undefined) {
              $hash_put(self, key, value);
              return [false, false];
            }

            $hash_put(self, key, block(key, val, value));
            return [false, false];
          });
        }
      }

      return self;
    }
  end

  def rassoc(object)
    %x{
      return $hash_each(self, nil, function(key, value) {
        if (#{`value` == object}) {
          return [true, [key, value]];
        }
        return [false, nil];
      });
    }
  end

  def rehash
    %x{
      $deny_frozen_access(self);
      Opal.hash_rehash(self);
      return self;
    }
  end

  def reject(&block)
    return enum_for(:reject) { size } unless block

    %x{
      var hash = $hash();

      return $hash_each(self, hash, function(key, value) {
        var obj = block(key, value);

        if (obj === false || obj === nil) {
          $hash_put(hash, key, value);
        }
        return [false, hash]
      });
    }
  end

  def reject!(&block)
    return enum_for(:reject!) { size } unless block

    %x{
      $deny_frozen_access(self);

      var result = nil;

      return $hash_each(self, result, function(key, value) {
        var obj = block(key, value);

        if (obj !== false && obj !== nil) {
          $hash_delete(self, key);
          result = self;
        }
        return [false, result];
      });
    }
  end

  def replace(other)
    `$deny_frozen_access(self);`

    other = ::Opal.coerce_to!(other, ::Hash, :to_hash)

    %x{
      self.$clear();

      $hash_each(other, false, function(key, value) {
        $hash_put(self, key, value);
        return [false, false];
      });
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

      return $hash_each(self, hash, function(key, value) {
        var obj = block(key, value);

        if (obj !== false && obj !== nil) {
          $hash_put(hash, key, value);
        }
        return [false, hash];
      });
    }
  end

  def select!(&block)
    return enum_for(:select!) { size } unless block

    %x{
      $deny_frozen_access(self);

      var result = nil;

      return $hash_each(self, result, function(key, value) {
        var obj = block(key, value);

        if (obj === false || obj === nil) {
          $hash_delete(self, key);
          result = self;
        }
        return [false, result];
      });
    }
  end

  def shift
    %x{
      $deny_frozen_access(self);

      return $hash_each(self, nil, function(key, value) {
        return [true, [key, $hash_delete(self, key)]];
      });
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

      return $hash_each(self, result, function(key, value) {
        result.push([key, value]);
        return [false, result];
      });
    }
  end

  def to_h(&block)
    return map(&block).to_h if block_given?

    %x{
      if (self.$$class === Opal.Hash) {
        return self;
      }

      var hash = new Map();

      $hash_clone(self, hash);

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

      return $hash_each(self, result, function(key, value) {
        key = block(key);
        $hash_put(result, key, value);
        return [false, result];
      });
    }
  end

  def transform_keys!(&block)
    return enum_for(:transform_keys!) { size } unless block

    %x{
      $deny_frozen_access(self);

      return $hash_each(self, self, function(key, value) {
        var new_key = block(key);
        $hash_delete(self, key);
        $hash_put(self, new_key, value);
        return [false, self];
      });
    }
  end

  def transform_values(&block)
    return enum_for(:transform_values) { size } unless block

    %x{
      var result = $hash();

      return $hash_each(self, result, function(key, value) {
        $hash_put(result, key, block(value));
        return [false, result];
      });
    }
  end

  def transform_values!(&block)
    return enum_for(:transform_values!) { size } unless block

    %x{
      $deny_frozen_access(self);

      return $hash_each(self, self, function(key, value) {
        $hash_put(self, key, block(value));
        return [false, self];
      });
    }
  end

  def values
    `Array.from(self.values())`
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
