module Kernel
  def native?(value)
    `value == null || !value._klass`
  end

  def Native(obj)
    if `#{obj} == null`
      nil
    elsif native?(obj)
      Native.new(obj)
    else
      obj
    end
  end
end

class Native < BasicObject
  module Base
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
    end

    def self.included(klass)
      klass.instance_eval {
        extend Helpers
      }
    end

    def initialize(native)
      unless Kernel.native?(native)
        Kernel.raise ArgumentError, "the passed value isn't native"
      end

      @native = native
    end

    def to_n
      @native
    end
  end

  class Array
    include Base
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

      index  = 0
      length = self.length

      while index < length
        block.call(self[index])

        index += 1
      end

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
        `#@native[#@set](#{index}, #{value})`
      else
        `#@native[#{index}] = #{value}`
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

  def self.is_a?(object, klass)
    %x{
      try {
        return #{object} instanceof #{Native.try_convert(klass)};
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
    native = try_convert(value)

    if `#{native} === nil`
      raise ArgumentError, "the passed value isn't a native"
    end

    native
  end

  def self.call(obj, key, *args, &block)
    args << block if block

    %x{
      var prop = #{obj}[#{key}];

      if (prop == null) {
        return nil;
      }
      else if (prop instanceof Function) {
        var result = prop.apply(#{obj}, #{args});

        return result == null ? nil : result;
      }
      else if (#{native?(`prop`)}) {
        return #{Native(`prop`)};
      }
      else {
        return prop;
      }
    }
  end

  include Base

  def has_key?(name)
    `#@native.hasOwnProperty(#{name})`
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
end

# native global
$$ = $global = Native(`Opal.global`)
