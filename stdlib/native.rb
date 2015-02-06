module Native
  def self.is_a?(object, klass)
    %x{
      try {
        return #{object} instanceof #{try_convert(klass)};
      }
      catch (e) {
        return false;
      }
    }
  end

  def self.try_convert(value)
    %x{
      if (#{native?(value)}) {
        return #{value};
      }
      else if (#{value.respond_to? :to_n}) {
        return #{value.to_n};
      }
      else {
        return nil;
      }
    }
  end

  def self.convert(value)
    %x{
      if (#{native?(value)}) {
        return #{value};
      }
      else if (#{value.respond_to? :to_n}) {
        return #{value.to_n};
      }
      else {
        #{raise ArgumentError, "#{value.inspect} isn't native"};
      }
    }
  end

  def self.call(obj, key, *args, &block)
    %x{
      var prop = #{obj}[#{key}];

      if (prop instanceof Function) {
        var converted = new Array(args.length);

        for (var i = 0, length = args.length; i < length; i++) {
          var item = args[i],
              conv = #{try_convert(`item`)};

          converted[i] = conv === nil ? item : conv;
        }

        if (block !== nil) {
          converted.push(block);
        }

        return #{Native(`prop.apply(#{obj}, converted)`)};
      }
      else {
        return #{Native(`prop`)};
      }
    }
  end

  module Helpers
    def alias_native(new, old = new, options = {})
      if old.end_with? ?=
        define_method new do |value|
          `#@native[#{old[0 .. -2]}] = #{Native.convert(value)}`

          value
        end
      else
        if as = options[:as]
          define_method new do |*args, &block|
            if value = Native.call(@native, old, *args, &block)
              as.new(value.to_n)
            end
          end
        else
          define_method new do |*args, &block|
            Native.call(@native, old, *args, &block)
          end
        end
      end
    end

    def native_reader(*names)
      names.each {|name|
        define_method name do
          Native(`#@native[name]`)
        end
      }
    end

    def native_writer(*names)
      names.each {|name|
        define_method "#{name}=" do |value|
          Native(`#@native[name] = value`)
        end
      }
    end

    def native_accessor(*names)
      native_reader(*names)
      native_writer(*names)
    end
  end

  def self.included(klass)
    klass.extend Helpers
  end

  def initialize(native)
    unless Kernel.native?(native)
      Kernel.raise ArgumentError, "#{native.inspect} isn't native"
    end

    @native = native
  end

  def to_n
    @native
  end
end

module Kernel
  def native?(value)
    `value == null || !value.$$class`
  end

  def Native(obj)
    if `#{obj} == null`
      nil
    elsif native?(obj)
      Native::Object.new(obj)
    else
      obj
    end
  end

  def Array(object, *args, &block)
    %x{
      if (object == null || object === nil) {
        return [];
      }
      else if (#{native?(object)}) {
        return #{Native::Array.new(object, *args, &block).to_a};
      }
      else if (#{object.respond_to? :to_ary}) {
        return #{object.to_ary};
      }
      else if (#{object.respond_to? :to_a}) {
        return #{object.to_a};
      }
      else {
        return [object];
      }
    }
  end
  
  # allows to pass a proc that runs in context of `this`
  #
  # @example
  #   options = {
  #     persist: false,
  #     render: function { |item, escape|
  #       '<div>' + escape.call(item.name) + '</div>'
  #     }
  #   }
  #
  def function *args, &block
    args.any? && raise(ArgumentError, '`function` does not accept arguments')
    block || raise(ArgumentError, 'block required')
    proc do |*a| # no way to expect a block here as this is always called from JavaScript
      a.map! {|x| Native(`x`)}
      instance = Native(`this`)
      %x{
        return (function() {
          var s = block.$$s;
          block.$$s = null;
          try {
            var r = block.apply(instance, a);
            block.$$s = s;
            return r;
          } catch (e) {
            block.$$s = s;
            throw e;
          }
        })();
      }
    end
  end
end

class Native::Object < BasicObject
  include ::Native

  def ==(other)
    `#@native === #{Native.try_convert(other)}`
  end

  def has_key?(name)
    `Opal.hasOwnProperty.call(#@native, #{name})`
  end

  alias key? has_key?
  alias include? has_key?
  alias member? has_key?

  def each(*args)
    if block_given?
      %x{
        for (var key in #@native) {
          #{yield `key`, `#@native[key]`}
        }
      }

      self
    else
      method_missing(:each, *args)
    end
  end

  def [](key)
    %x{
      var prop = #@native[key];

      if (prop instanceof Function) {
        return prop;
      }
      else {
        return #{::Native.call(@native, key)}
      }
    }
  end

  def []=(key, value)
    native = Native.try_convert(value)

    if `#{native} === nil`
      `#@native[key] = #{value}`
    else
      `#@native[key] = #{native}`
    end
  end

  def merge!(other)
    %x{
      var other = #{Native.convert(other)};

      for (var prop in other) {
        #@native[prop] = other[prop];
      }
    }

    self
  end

  def respond_to?(name, include_all = false)
    Kernel.instance_method(:respond_to?).bind(self).call(name, include_all)
  end

  def respond_to_missing?(name)
    `Opal.hasOwnProperty.call(#@native, #{name})`
  end

  def method_missing(mid, *args, &block)
    %x{
      if (mid.charAt(mid.length - 1) === '=') {
        return #{self[mid.slice(0, mid.length - 1)] = args[0]};
      }
      else {
        return #{::Native.call(@native, mid, *args, &block)};
      }
    }
  end

  def nil?
    false
  end

  def is_a?(klass)
    `Opal.is_a(self, klass)`
  end

  alias kind_of? is_a?

  def instance_of?(klass)
    `self.$$class === klass`
  end

  def class
    `self.$$class`
  end

  def to_a(options = {}, &block)
    Native::Array.new(@native, options, &block).to_a
  end

  def inspect
    "#<Native:#{`String(#@native)`}>"
  end
end

class Native::Array
  include Native
  include Enumerable

  def initialize(native, options = {}, &block)
    super(native)

    @get    = options[:get] || options[:access]
    @named  = options[:named]
    @set    = options[:set] || options[:access]
    @length = options[:length] || :length
    @block  = block

    if `#{length} == null`
      raise ArgumentError, "no length found on the array-like object"
    end
  end

  def each(&block)
    return enum_for :each unless block

    %x{
      for (var i = 0, length = #{length}; i < length; i++) {
        var value = Opal.yield1(block, #{self[`i`]});

        if (value === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def [](index)
    result = case index
      when String, Symbol
        @named ? `#@native[#@named](#{index})` : `#@native[#{index}]`

      when Integer
        @get ? `#@native[#@get](#{index})` : `#@native[#{index}]`
    end

    if result
      if @block
        @block.call(result)
      else
        Native(result)
      end
    end
  end

  def []=(index, value)
    if @set
      `#@native[#@set](#{index}, #{Native.convert(value)})`
    else
      `#@native[#{index}] = #{Native.convert(value)}`
    end
  end

  def last(count = nil)
    if count
      index  = length - 1
      result = []

      while index >= 0
        result << self[index]
        index  -= 1
      end

      result
    else
      self[length - 1]
    end
  end

  def length
    `#@native[#@length]`
  end

  alias to_ary to_a

  def inspect
    to_a.inspect
  end
end

class Numeric
  def to_n
    `self.valueOf()`
  end
end

class Proc
  def to_n
    self
  end
end

class String
  def to_n
    `self.valueOf()`
  end
end

class Regexp
  def to_n
    `self.valueOf()`
  end
end

class MatchData
  def to_n
    @matches
  end
end

class Struct
  def initialize(*args)
    if args.length == 1 && native?(args[0])
      object = args[0]

      members.each {|name|
        instance_variable_set "@#{name}", Native(`#{object}[#{name}]`)
      }
    else
      members.each_with_index {|name, index|
        instance_variable_set "@#{name}", args[index]
      }
    end
  end

  def to_n
    result = `{}`

    each_pair {|name, value|
      `#{result}[#{name}] = #{value.to_n}`
    }

    result
  end
end

class Array
  def to_n
    %x{
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        var obj = self[i];

        if (#{`obj`.respond_to? :to_n}) {
          result.push(#{`obj`.to_n});
        }
        else {
          result.push(obj);
        }
      }

      return result;
    }
  end
end

class Boolean
  def to_n
    `self.valueOf()`
  end
end

class Time
  def to_n
    self
  end
end

class NilClass
  def to_n
    `null`
  end
end

class Hash
  def initialize(defaults = undefined, &block)
    %x{
      if (defaults != null) {
        if (defaults.constructor === Object) {
          var _map = self.map,
              smap = self.smap,
              keys = self.keys,
              map, khash, value;

          for (var key in defaults) {
            value = defaults[key];

            if (key.$$is_string) {
              map = smap;
              khash = key;
            } else {
              map = _map;
              khash = key.$hash();
            }

            if (value && value.constructor === Object) {
              map[khash] = #{Hash.new(`value`)};
            }
            else {
              map[khash] = #{Native(`value`)};
            }

            keys.push(key);
          }
        }
        else {
          self.none = defaults;
        }
      }
      else if (block !== nil) {
        self.proc = block;
      }

      return self;
    }
  end

  def to_n
    %x{
      var result = {},
          keys   = self.keys,
          _map   = self.map,
          smap   = self.smap,
          map, khash, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        key   = keys[i];

        if (key.$$is_string) {
          map = smap;
          khash = key;
        } else {
          map = _map;
          khash = key.$hash();
        }

        value = map[khash];

        if (#{`value`.respond_to? :to_n}) {
          result[key] = #{`value`.to_n};
        }
        else {
          result[key] = value;
        }
      }

      return result;
    }
  end
end

class Module
  def native_module
    `Opal.global[#{self.name}] = #{self}`
  end
end

class Class
  def native_alias(new_jsid, existing_mid)
    %x{
      var aliased = #{self}.$$proto['$' + #{existing_mid}];
      if (!aliased) {
        #{raise NameError, "undefined method `#{existing_mid}' for class `#{inspect}'"};
      }
      #{self}.$$proto[#{new_jsid}] = aliased;
    }
  end

  def native_class
    native_module
    `self.new = self.$new;`
  end
end

# native global
$$ = $global = Native(`Opal.global`)
