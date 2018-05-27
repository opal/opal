# Provides a complete set of tools to wrap native JavaScript
# into nice Ruby objects.
#
# @example
#
#   $$.document.querySelector('p').classList.add('blue')
#   # => adds "blue" class to <p>
#
#   $$.location.href = 'https://google.com'
#   # => changes page location
#
#   do_later = $$[:setTimeout] # Accessing the "setTimeout" property
#   do_later.call(->{ puts :hello}, 500)
#
# `$$` and `$global` wrap `Opal.global`, which the Opal JS runtime
# sets to the global `this` object.
#
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

  def self.try_convert(value, default = nil)
    %x{
      if (#{native?(value)}) {
        return #{value};
      }
      else if (#{value.respond_to? :to_n}) {
        return #{value.to_n};
      }
      else {
        return #{default};
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

        for (var i = 0, l = args.length; i < l; i++) {
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

  def self.proc(&block)
    raise LocalJumpError, 'no block given' unless block

    ::Kernel.proc { |*args|
      args.map! { |arg| Native(arg) }
      instance = Native(`this`)

      %x{
        // if global is current scope, run the block in the scope it was defined
        if (this === Opal.global) {
          return block.apply(self, #{args});
        }

        var self_ = block.$$s;
        block.$$s = null;

        try {
          return block.apply(#{instance}, #{args});
        }
        finally {
          block.$$s = self_;
        }
      }
    }
  end

  module Helpers
    # Exposes a native JavaScript method to Ruby
    #
    #
    # @param new [String]
    #       The name of the newly created method.
    #
    # @param old [String]
    #       The name of the native JavaScript method to be exposed.
    #       If the name ends with "=" (e.g. `foo=`) it will be interpreted as
    #       a property setter. (default: the value of "new")
    #
    # @param as [Class]
    #       If provided the values returned by the original method will be
    #       returned as instances of the passed class. The class passed to "as"
    #       is expected to accept a native JavaScript value.
    #
    # @example
    #
    #   class Element
    #     include Native::Helpers
    #
    #     alias_native :add_class, :addClass
    #     alias_native :show
    #     alias_native :hide
    #
    #     def initialize(selector)
    #       @native = `$(#{selector})`
    #     end
    #   end
    #
    #   titles = Element.new('h1')
    #   titles.add_class :foo
    #   titles.hide
    #   titles.show
    #
    def alias_native(new, old = new, as: nil)
      if old.end_with? '='
        define_method new do |value|
          `#{@native}[#{old[0..-2]}] = #{Native.convert(value)}`

          value
        end
      elsif as
        define_method new do |*args, &block|
          value = Native.call(@native, old, *args, &block)
          if value
            as.new(value.to_n)
          end
        end
      else
        define_method new do |*args, &block|
          Native.call(@native, old, *args, &block)
        end
      end
    end

    def native_reader(*names)
      names.each do |name|
        define_method name do
          Native(`#{@native}[name]`)
        end
      end
    end

    def native_writer(*names)
      names.each do |name|
        define_method "#{name}=" do |value|
          Native(`#{@native}[name] = value`)
        end
      end
    end

    def native_accessor(*names)
      native_reader(*names)
      native_writer(*names)
    end
  end

  module Wrapper
    def initialize(native)
      unless ::Kernel.native?(native)
        ::Kernel.raise ArgumentError, "#{native.inspect} isn't native"
      end

      @native = native
    end

    # Returns the internal native JavaScript value
    def to_n
      @native
    end

    def self.included(klass)
      klass.extend Helpers
    end
  end

  def self.included(base)
    warn 'Including ::Native is deprecated. Please include Native::Wrapper instead.'
    base.include Wrapper
    base.extend Helpers
  end
end

module Kernel
  def native?(value)
    `value == null || !value.$$class`
  end

  # Wraps a native JavaScript with `Native::Object.new`
  #
  # @return [Native::Object] The wrapped object if it is native
  # @return [nil] for `null` and `undefined`
  # @return [obj] The object itself if it's not native
  def Native(obj)
    if `#{obj} == null`
      nil
    elsif native?(obj)
      Native::Object.new(obj)
    elsif obj.is_a?(Array)
      obj.map do |o|
        Native(o)
      end
    elsif obj.is_a?(Proc)
      proc do |*args, &block|
        Native(obj.call(*args, &block))
      end
    else
      obj
    end
  end

  alias _Array Array

  # Wraps array-like JavaScript objects in Native::Array
  def Array(object, *args, &block)
    if native?(object)
      return Native::Array.new(object, *args, &block).to_a
    end
    _Array(object)
  end
end

class Native::Object < BasicObject
  include ::Native::Wrapper

  def ==(other)
    `#{@native} === #{::Native.try_convert(other)}`
  end

  def has_key?(name)
    `Opal.hasOwnProperty.call(#{@native}, #{name})`
  end

  alias key? has_key?
  alias include? has_key?
  alias member? has_key?

  def each(*args)
    if block_given?
      %x{
        for (var key in #{@native}) {
          #{yield `key`, `#{@native}[key]`}
        }
      }

      self
    else
      method_missing(:each, *args)
    end
  end

  def [](key)
    %x{
      var prop = #{@native}[key];

      if (prop instanceof Function) {
        return prop;
      }
      else {
        return #{::Native.call(@native, key)}
      }
    }
  end

  def []=(key, value)
    native = ::Native.try_convert(value)

    if `#{native} === nil`
      `#{@native}[key] = #{value}`
    else
      `#{@native}[key] = #{native}`
    end
  end

  def merge!(other)
    %x{
      other = #{::Native.convert(other)};

      for (var prop in other) {
        #{@native}[prop] = other[prop];
      }
    }

    self
  end

  def respond_to?(name, include_all = false)
    ::Kernel.instance_method(:respond_to?).bind(self).call(name, include_all)
  end

  def respond_to_missing?(name, include_all = false)
    `Opal.hasOwnProperty.call(#{@native}, #{name})`
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
    ::Native::Array.new(@native, options, &block).to_a
  end

  def inspect
    "#<Native:#{`String(#{@native})`}>"
  end
end

class Native::Array
  include Native::Wrapper
  include Enumerable

  def initialize(native, options = {}, &block)
    super(native)

    @get    = options[:get] || options[:access]
    @named  = options[:named]
    @set    = options[:set] || options[:access]
    @length = options[:length] || :length
    @block  = block

    if `#{length} == null`
      raise ArgumentError, 'no length found on the array-like object'
    end
  end

  def each(&block)
    return enum_for :each unless block

    %x{
      for (var i = 0, length = #{length}; i < length; i++) {
        Opal.yield1(block, #{self[`i`]});
      }
    }

    self
  end

  def [](index)
    result = case index
             when String, Symbol
               @named ? `#{@native}[#{@named}](#{index})` : `#{@native}[#{index}]`
             when Integer
               @get ? `#{@native}[#{@get}](#{index})` : `#{@native}[#{index}]`
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
      `#{@native}[#{@set}](#{index}, #{Native.convert(value)})`
    else
      `#{@native}[#{index}] = #{Native.convert(value)}`
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
    `#{@native}[#{@length}]`
  end

  alias to_ary to_a

  def inspect
    to_a.inspect
  end
end

class Numeric
  # @return the internal JavaScript value (with `valueOf`).
  def to_n
    `self.valueOf()`
  end
end

class Proc
  # @return itself (an instance of `Function`)
  def to_n
    self
  end
end

class String
  # @return the internal JavaScript value (with `valueOf`).
  def to_n
    `self.valueOf()`
  end
end

class Regexp
  # @return the internal JavaScript value (with `valueOf`).
  def to_n
    `self.valueOf()`
  end
end

class MatchData
  # @return the array of matches
  def to_n
    @matches
  end
end

class Struct
  # @return a JavaScript object with the members as keys and their
  # values as values.
  def to_n
    result = `{}`

    each_pair do |name, value|
      `#{result}[#{name}] = #{Native.try_convert(value, value)}`
    end

    result
  end
end

class Array
  # Retuns a copy of itself trying to call #to_n on each member.
  def to_n
    %x{
      var result = [];

      for (var i = 0, length = self.length; i < length; i++) {
        var obj = self[i];

        result.push(#{Native.try_convert(`obj`, `obj`)});
      }

      return result;
    }
  end
end

class Boolean
  # @return the internal JavaScript value (with `valueOf`).
  def to_n
    `self.valueOf()`
  end
end

class Time
  # @return itself (an instance of `Date`).
  def to_n
    self
  end
end

class NilClass
  # @return the corresponding JavaScript value (`null`).
  def to_n
    `null`
  end
end

class Hash
  alias _initialize initialize

  def initialize(defaults = undefined, &block)
    %x{
      if (defaults != null &&
           (defaults.constructor === undefined ||
             defaults.constructor === Object)) {
        var smap = self.$$smap,
            keys = self.$$keys,
            key, value;

        for (key in defaults) {
          value = defaults[key];

          if (value &&
               (value.constructor === undefined ||
                 value.constructor === Object)) {
            smap[key] = #{Hash.new(`value`)};
          } else if (value && value.$$is_array) {
            value = value.map(function(item) {
              if (item &&
                   (item.constructor === undefined ||
                     item.constructor === Object)) {
                return #{Hash.new(`item`)};
              }

              return #{Native(`item`)};
            });
            smap[key] = value
          } else {
            smap[key] = #{Native(`value`)};
          }

          keys.push(key);
        }

        return self;
      }

      return #{_initialize(defaults, &block)};
    }
  end

  # @return a JavaScript object with the same keys but calling #to_n on
  # all values.
  def to_n
    %x{
      var result = {},
          keys = self.$$keys,
          smap = self.$$smap,
          key, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];

        if (key.$$is_string) {
          value = smap[key];
        } else {
          key = key.key;
          value = key.value;
        }

        result[key] = #{Native.try_convert(`value`, `value`)};
      }

      return result;
    }
  end
end

class Module
  # Exposes the current module as a property of
  # the global object (e.g. `window`).
  def native_module
    `Opal.global[#{name}] = #{self}`
  end
end

class Class
  def native_alias(new_jsid, existing_mid)
    %x{
      var aliased = #{self}.prototype['$' + #{existing_mid}];
      if (!aliased) {
        #{raise NameError.new("undefined method `#{existing_mid}' for class `#{inspect}'", exiting_mid)};
      }
      #{self}.prototype[#{new_jsid}] = aliased;
    }
  end

  def native_class
    native_module
    `self["new"] = self.$new`
  end
end

# Exposes the global value (would be `window` inside a browser)
$$ = $global = Native(`Opal.global`)
