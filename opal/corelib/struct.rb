require 'corelib/enumerable'

class Struct
  include Enumerable

  def self.new(const_name, *args, &block)
    if const_name
      begin
        const_name = Opal.const_name!(const_name)
      rescue TypeError, NameError
        args.unshift(const_name)
        const_name = nil
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

        alias [] new
      end
    end

    klass.module_eval(&block) if block

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

    klass.instance_eval {
      @members = members
    }
  end

  def initialize(*args)
    if args.length > self.class.members.length
      raise ArgumentError, "struct size differs"
    end

    self.class.members.each_with_index {|name, index|
      self[name] = args[index]
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
    return enum_for(:each){self.size} unless block_given?

    self.class.members.each { |name| yield self[name] }
    self
  end

  def each_pair
    return enum_for(:each_pair){self.size} unless block_given?

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
    result = "#<struct "

    if Struct === self && self.class.name
      result += "#{self.class} "
    end

    result += each_pair.map {|name, value|
      "#{name}=#{value.inspect}"
    }.join ", "

    result += ">"

    result
  end

  alias to_s inspect

  def to_h
    self.class.members.inject({}) {|h, name| h[name] = self[name]; h}
  end

  def values_at(*args)
    args = args.map{|arg| `arg.$$is_range ? #{arg.to_a} : arg`}.flatten
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
    if `key.$$is_string && self.$$data.hasOwnProperty(key)`
      item = `self.$$data[key] || nil`
    else
      item = nil
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
