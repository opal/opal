# use_strict: true
# frozen_string_literal: true

ENV = Object.new

class << ENV
  def [](name)
    `process.env[#{name}] || nil`
  end

  def []=(name, value)
    `process.env[#{name.to_s}] = #{value.to_s}`
  end

  def key?(name)
    `process.env.hasOwnProperty(#{name})`
  end

  # alias
  alias has_key? key?
  alias include? key?
  alias member? key?

  def empty?
    `Object.keys(process.env).length === 0`
  end

  def keys
    `Object.keys(process.env)`
  end

  def delete(name)
    %x{
      var value = process.env[#{name}] || nil;
      delete process.env[#{name}];
      return value;
    }
  end

  def fetch(key, default_value = undefined, &block)
    return self[key] if key?(key)
    return yield key if block_given?
    return default_value unless `typeof(#{default_value}) === 'undefined'`
    raise KeyError, 'key not found'
  end

  def to_s
    'ENV'
  end
end
