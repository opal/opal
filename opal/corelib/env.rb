# backtick_javascript: true
# helpers: platform

ENV = Object.new

class << ENV
  def [](name)
    `$platform.env_get(name) || nil`
  end

  def []=(name, value)
    `$platform.env_set(name, value)`
  end

  def key?(name)
    `$platform.env_has(name)`
  end

  def empty?
    `$platform.env_keys().length === 0`
  end

  def keys
    `$platform.env_keys()`
  end

  def delete(name)
    %x{
      let value = $platform.env_get(name) || nil;
      delete $platform.env_del(name);
      return value;
    }
  end

  def fetch(key, default_value = nil, &block)
    return self[key] if key?(key)
    return yield key if block_given?
    return default_value unless `default_value == nil || default_value == null`
    raise KeyError, 'key not found'
  end

  def to_s
    'ENV'
  end

  def to_h
    keys.to_h { |k| [k, self[k]] }
  end

  def merge(keys)
    to_h.merge(keys)
  end

  alias has_key? key?
  alias include? key?
  alias inspect to_s
  alias member? key?
  alias to_hash to_h
end
