# backtick_javascript: true
# helpers: platform

# ::ENV is a instance of this anonymous class, note the .new at the bottom
::ENV = Class.new do
  def [](name)
    # Returns the value for the environment variable name if it exists:
    name = ::Opal.coerce_to!(name, ::String, :to_str)
    val = `$platform.env_get(name)`
    if val
      val = ::Opal.str(val, ::Encoding.default_internal) if ::Encoding.default_internal
      val.freeze
    else
      nil
    end
  end

  def []=(name, value)
    # Creates, updates, or deletes the named environment variable, returning the value.
    if value
      name = ::Opal.coerce_to!(name, ::String, :to_str)
      raise(::Errno::EINVAL, 'invalid key') if name.empty? || name.include?('=')
      value = ::Opal.coerce_to!(value, ::String, :to_str)
      `$platform.env_set(name, value)`
    else
      name = ::Opal.coerce_to?(name, ::String, :to_str)
      return if name.empty? || name.include?('=')
      delete(name)
    end
  end

  def assoc(name)
    # Returns a 2-element Array containing the name and value of the environment variable for name if it exists
    name = ::Opal.coerce_to!(name, ::String, :to_str)
    key?(name) ? [name, self[name]] : nil
  end

  def clear
    # Removes every environment variable; returns ENV.
    each_key { |k| delete(k) }
  end

  def clone
    # Raises TypeError, because ENV is a wrapper for the process-wide environment variables and a clone is useless.
    raise ::TypeError, 'Cannot clone ENV, use ENV.to_h to get a copy of ENV as a hash'
  end

  def delete(name)
    # Deletes the environment variable with name if it exists and returns its value
    name = ::Opal.coerce_to!(name, ::String, :to_str)
    val = self[name]
    `$platform.env_del(name)`
    return val if val
    yield(name) if block_given?
  end

  def delete_if
    # Yields each environment variable name and its value as a 2-element Array,
    # deleting each environment variable for which the block returns a truthy value,
    # and returning ENV
    return enum_for(:delete_if) { length } unless block_given?
    each { |k, v| delete(k) if yield(k, v) }
    self
  end

  def dup
    # Raises TypeError, because ENV is a wrapper for the process-wide environment variables and a dup is useless.
    raise ::TypeError, 'Cannot dup ENV, use ENV.to_h to get a copy of ENV as a hash'
  end

  def each
    # Yields each environment variable name and its value as a 2-element Array
    return enum_for(:each) { length } unless block_given?
    keys.each { |k| yield k, self[k] }
    self
  end

  def each_key
    # Yields each environment variable name
    return enum_for(:each_key) { length } unless block_given?
    keys.each { |k| yield k }
    self
  end

  alias each_pair each

  def each_value
    # Yields each environment variable value
    return enum_for(:each_value) { length } unless block_given?
    keys.each { |k| yield self[k] }
    self
  end

  def empty?
    `$platform.env_keys()`.empty?
  end

  def except(*env_keys)
    # Returns a hash except the given keys from ENV and their values
    h = to_hash
    env_keys.each { |k| h.delete(k) }
    h
  end

  def fetch(name, default_value = nil)
    # If name is the name of an environment variable, returns its value
    name = ::Opal.coerce_to!(name, ::String, :to_str)
    warn("block supersedes default value argument") if default_value && block_given?
    return self[name] if key?(name)
    return yield name if block_given?
    return default_value unless `default_value == nil || default_value == null`
    raise(::KeyError.new("key not found: #{name.inspect}", receiver: self, key: name))
  end

  def filter
    # Yields each environment variable name and its value as a 2-element Array,
    # returning a Hash of the names and values for which the block returns a truthy value
    return enum_for(:filter) { length } unless block_given?
    h = {}
    each { |k, v| h[k] = v if yield(k, v) }
    h
  end

  def filter!
    # Yields each environment variable name and its value as a 2-element Array,
    # deleting each entry for which the block returns false or nil,
    # and returning ENV if any deletions made
    return enum_for(:filter!) { length } unless block_given?
    @deleted_any = false
    each do |k, v|
      unless yield(k, v)
        delete(k)
        @deleted_any = true
      end
    end
    @deleted_any ? self : nil
  end

  def freeze
    # Raises an exception
    raise ::TypeError, 'cannot freeze ENV'
  end

  def has_key?(name)
    # Returns true if there is an environment variable with the given name
    name = ::Opal.coerce_to!(name, ::String, :to_str)
    `$platform.env_has(name)`
  end

  def has_value?(value)
    # Returns true if value is the value for some environment variable name, false otherwise
    value = ::Opal.coerce_to?(value, ::String, :to_str)
    return nil unless value
    each_value { |v| return true if v == value }
    return false
  end

  alias include? has_key?

  def inspect
    # Returns the contents of the environment as a String
    to_hash.inspect
  end

  def invert
    # Returns a Hash whose keys are the ENV values, and whose values are the corresponding ENV names
    to_hash.invert
  end

  def keep_if(&block)
    # Yields each environment variable name and its value as a 2-element Array,
    # deleting each environment variable for which the block returns false or nil,
    # and returning ENV
    return enum_for(:keep_if) { length } unless block_given?
    each { |k, v| delete(k) unless yield(k, v) }
    self
  end

  def key(value)
    # Returns the name of the first environment variable with value, if it exists
    value = ::Opal.coerce_to!(value, ::String, :to_str)
    each { |k, v| return k if v == value }
    nil
  end

  alias key? has_key?

  def keys
    # Returns a new array containing all keys in self
    ks = `$platform.env_keys()`
    return ks unless ::Encoding.default_internal
    ks.map { |k| ::Opal.str(k,::Encoding.default_internal) }
  end

  def length
    # Returns the count of environment variables
    `$platform.env_keys()`.size
  end

  alias member? has_key?

  # def merge(keys)
  #   to_h.merge(keys)
  # end

  def merge!(*hashes, &block)
    # Adds to ENV each key/value pair in the given hash; returns ENV
    hashes.each do |h|
      if h.is_a?(::Hash)
        h.each do |k, v|
          old_v = self[k]
          self[k] = v
          if block_given? && old_v
            self[k] = yield(k, old_v, v)
          else
            self[k] = v
          end
        end
      else
        merge!(h, &block)
      end
    end
    self
  end

  def rassoc(value)
    # Returns a 2-element Array containing the name and value
    # of the first found environment variable that has value value, if one exists
    value = ::Opal.coerce_to?(value, ::String, :to_str)
    return nil unless value
    k = key(value)
    k ? [k, value] : nil
  end

  def rehash
    # Provided for compatibility with Hash. Does not modify ENV; returns nil
    nil
  end

  def reject
    # Yields each environment variable name and its value as a 2-element Array.
    # Returns a Hash whose items are determined by the block.
    # When the block returns a truthy value, the name/value pair is added to the return Hash;
    # otherwise the pair is ignored
    return enum_for(:reject) { length } unless block_given?
    h = {}
    each { |k, v| h[k] = v unless yield(k, v) }
    h
  end

  def reject!
    # Similar to ENV.delete_if, but returns nil if no changes were made.
    # Yields each environment variable name and its value as a 2-element Array,
    # deleting each environment variable for which the block returns a truthy value,
    # and returning ENV (if any deletions) or nil (if not)
    return enum_for(:reject!) { length } unless block_given?
    @deleted_any = false
    each do |k, v|
      if yield(k, v)
        delete(k)
        @deleted_any = true
      end
    end
    @deleted_any ? self : nil
  end

  def replace(hash)
    # Replaces the entire content of the environment variables with the name/value
    # pairs in the given hash; returns ENV
    hash = ::Opal.coerce_to!(hash, ::Hash, :to_hash)
    orig = to_hash
    clear
    begin
      hash.each { |k,v| self[k] = v }
    rescue => e
      replace orig
      raise e
    end
    self
  end

  alias select filter

  alias select! filter!

  def shift
    # Removes the first environment variable from ENV and returns a
    # 2-element Array containing its name and value
    return nil if empty?
    k = keys.first
    res = [k, self[k]]
    delete(k)
    res
  end

  alias size length

  def slice(*names)
    # Returns a Hash of the given ENV names and their corresponding values
    h = {}
    names.each do |name|
      v = self[name]
      h[name] = v if v
    end
    h
  end

  alias store []=

  def to_a
    # Returns the contents of ENV as an Array of 2-element Arrays, each of which is a name/value pair
    each.to_a
  end

  def to_h
    # With no block, returns a Hash containing all name/value pairs from ENV.
    # With a block, returns a Hash whose items are determined by the block
    return to_hash unless block_given?
    h = {}
    each do |k, v|
      v = yield(k, v)
      v = v.to_ary if v.respond_to?(:to_ary)
      raise ::TypeError, "wrong element type #{v.class.name}" unless v.is_a?(::Array)
      raise ::ArgumentError, 'element has wrong array length' unless v.size == 2
      h[v[0]] = v[1]
    end
    h
  end

  def to_hash
    # Returns a Hash containing all name/value pairs from ENV.
    h = {}
    each { |k, v| h[k] = v }
    h
  end

  def to_s
    'ENV'
  end

  alias update merge!

  alias value? has_value?

  def values
    # Returns all environment variable values in an Array
    ary = []
    each_value { |v| ary << v }
    return ary unless ::Encoding.default_internal
    ary.map { |v| ::Opal.str(v,::Encoding.default_internal) }
  end

  def values_at(*names)
    # Returns an Array containing the environment variable values associated with the given names
    # Returns nil in the Array for each name that is not an ENV name
    # Returns an empty Array if no names given.
    # Raises an exception if any name is invalid
    ary = []
    names.each { |name| ary << self[name] }
    ary
  end
end.new
