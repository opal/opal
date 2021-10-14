# use_strict: true
# frozen_string_literal: true

require 'corelib/enumerable'

class Struct
  include Enumerable

  def self.new(const_name, *args, keyword_init: false, &block)
    if const_name
      if const_name.class == String && const_name[0].upcase != const_name[0]
        # Fast track so that we skip needlessly going thru exceptions
        # in most cases.
        args.unshift(const_name)
        const_name = nil
      else
        begin
          const_name = Opal.const_name!(const_name)
        rescue TypeError, NameError
          args.unshift(const_name)
          const_name = nil
        end
      end
    end

    args.map do |arg|
      Opal.coerce_to!(arg, String, :to_str)
    end

    klass = Class.new(self) do
      args.each { |arg| define_struct_attribute(arg) }

      class << self
        def new(*args)
          instance = allocate
          `#{instance}.$$data = {}`
          instance.initialize(*args)
          instance
        end

        alias_method :[], :new
      end
    end

    klass.module_eval(&block) if block
    `klass.$$keyword_init = keyword_init`

    if const_name
      Struct.const_set(const_name, klass)
    end

    klass
  end

  def self.define_struct_attribute(name)
    if self == Struct
      raise ArgumentError, 'you cannot define attributes to the Struct class'
    end

    members << name

    define_method name do
      `self.$$data[name]`
    end

    define_method "#{name}=" do |value|
      `self.$$data[name] = value`
    end
  end

  def self.members
    if self == Struct
      raise ArgumentError, 'the Struct class has no members'
    end

    @members ||= []
  end

  def self.inherited(klass)
    members = @members

    klass.instance_eval do
      @members = members
    end
  end

  def initialize(*args)
    if `#{self.class}.$$keyword_init`
      kwargs = args.last || {}

      if args.length > 1 || `(args.length === 1 && !kwargs.$$is_hash)`
        raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 0)"
      end

      extra = kwargs.keys - self.class.members
      if extra.any?
        raise ArgumentError, "unknown keywords: #{extra.join(', ')}"
      end

      self.class.members.each do |name|
        self[name] = kwargs[name]
      end
    else
      if args.length > self.class.members.length
        raise ArgumentError, 'struct size differs'
      end

      self.class.members.each_with_index do |name, index|
        self[name] = args[index]
      end
    end
  end

  def initialize_copy(from)
    %x{
      self.$$data = {}
      var keys = Object.keys(from.$$data), i, max, name;
      for (i = 0, max = keys.length; i < max; i++) {
        name = keys[i];
        self.$$data[name] = from.$$data[name];
      }
    }
  end

  def members
    self.class.members
  end

  def hash
    Hash.new(`self.$$data`).hash
  end

  def [](name)
    if Integer === name
      raise IndexError, "offset #{name} too small for struct(size:#{self.class.members.size})" if name < -self.class.members.size
      raise IndexError, "offset #{name} too large for struct(size:#{self.class.members.size})" if name >= self.class.members.size

      name = self.class.members[name]
    elsif String === name
      %x{
        if(!self.$$data.hasOwnProperty(name)) {
          #{raise NameError.new("no member '#{name}' in struct", name)}
        }
      }
    else
      raise TypeError, "no implicit conversion of #{name.class} into Integer"
    end

    name = Opal.coerce_to!(name, String, :to_str)
    `self.$$data[name]`
  end

  def []=(name, value)
    if Integer === name
      raise IndexError, "offset #{name} too small for struct(size:#{self.class.members.size})" if name < -self.class.members.size
      raise IndexError, "offset #{name} too large for struct(size:#{self.class.members.size})" if name >= self.class.members.size

      name = self.class.members[name]
    elsif String === name
      raise NameError.new("no member '#{name}' in struct", name) unless self.class.members.include?(name.to_sym)
    else
      raise TypeError, "no implicit conversion of #{name.class} into Integer"
    end

    name = Opal.coerce_to!(name, String, :to_str)
    `self.$$data[name] = value`
  end

  def ==(other)
    return false unless other.instance_of?(self.class)

    %x{
      var recursed1 = {}, recursed2 = {};

      function _eqeq(struct, other) {
        var key, a, b;

        recursed1[#{`struct`.__id__}] = true;
        recursed2[#{`other`.__id__}] = true;

        for (key in struct.$$data) {
          a = struct.$$data[key];
          b = other.$$data[key];

          if (#{Struct === `a`}) {
            if (!recursed1.hasOwnProperty(#{`a`.__id__}) || !recursed2.hasOwnProperty(#{`b`.__id__})) {
              if (!_eqeq(a, b)) {
                return false;
              }
            }
          } else {
            if (!#{`a` == `b`}) {
              return false;
            }
          }
        }

        return true;
      }

      return _eqeq(self, other);
    }
  end

  def eql?(other)
    return false unless other.instance_of?(self.class)

    %x{
      var recursed1 = {}, recursed2 = {};

      function _eqeq(struct, other) {
        var key, a, b;

        recursed1[#{`struct`.__id__}] = true;
        recursed2[#{`other`.__id__}] = true;

        for (key in struct.$$data) {
          a = struct.$$data[key];
          b = other.$$data[key];

          if (#{Struct === `a`}) {
            if (!recursed1.hasOwnProperty(#{`a`.__id__}) || !recursed2.hasOwnProperty(#{`b`.__id__})) {
              if (!_eqeq(a, b)) {
                return false;
              }
            }
          } else {
            if (!#{`a`.eql?(`b`)}) {
              return false;
            }
          }
        }

        return true;
      }

      return _eqeq(self, other);
    }
  end

  def each
    return enum_for(:each) { size } unless block_given?

    self.class.members.each { |name| yield self[name] }
    self
  end

  def each_pair
    return enum_for(:each_pair) { size } unless block_given?

    self.class.members.each { |name| yield [name, self[name]] }
    self
  end

  def length
    self.class.members.length
  end

  alias size length

  def to_a
    self.class.members.map { |name| self[name] }
  end

  alias values to_a

  def inspect
    result = '#<struct '

    if Struct === self && self.class.name
      result += "#{self.class} "
    end

    result += each_pair.map do |name, value|
      "#{name}=#{value.inspect}"
    end.join ', '

    result += '>'

    result
  end

  alias to_s inspect

  def to_h(&block)
    return map(&block).to_h(*args) if block_given?

    self.class.members.each_with_object({}) { |name, h| h[name] = self[name] }
  end

  def values_at(*args)
    args = args.map { |arg| `arg.$$is_range ? #{arg.to_a} : arg` }.flatten
    %x{
      var result = [];
      for (var i = 0, len = args.length; i < len; i++) {
        if (!args[i].$$is_number) {
          #{raise TypeError, "no implicit conversion of #{`args[i]`.class} into Integer"}
        }
        result.push(#{self[`args[i]`]});
      }
      return result;
    }
  end

  def dig(key, *keys)
    item = if `key.$$is_string && self.$$data.hasOwnProperty(key)`
             `self.$$data[key] || nil`
           end

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
end
