class Struct
  def self.new(name, *args)
    return super unless self == Struct

    if name.is_a?(String)
      Struct.const_set(name, new(*args))
    else
      args.unshift name

      Class.new(self) {
        args.each { |name| define_struct_attribute name }
      }
    end
  end

  def self.define_struct_attribute(name)
    members << name

    define_method name do
      instance_variable_get "@#{name}"
    end

    define_method "#{name}=" do |value|
      instance_variable_set "@#{name}", value
    end
  end

  def self.members
    @members ||= []
  end

  include Enumerable

  def initialize(*args)
    members.each_with_index {|name, index|
      instance_variable_set "@#{name}", args[index]
    }
  end

  def members
    self.class.members
  end

  def [](name)
    if name.is_a?(Integer)
      raise IndexError, "offset #{name} too large for struct(size:#{members.size})" if name >= members.size

      name = members[name]
    else
      raise NameError, "no member '#{name}' in struct" unless members.include?(name.to_sym)
    end

    instance_variable_get "@#{name}"
  end

  def []=(name, value)
    if name.is_a?(Integer)
      raise IndexError, "offset #{name} too large for struct(size:#{members.size})" if name >= members.size

      name = members[name]
    else
      raise NameError, "no member '#{name}' in struct" unless members.include?(name.to_sym)
    end

    instance_variable_set "@#{name}", value
  end

  def each
    return enum_for :each unless block_given?

    members.each { |name| yield self[name] }
  end

  def each_pair
    return enum_for :each_pair unless block_given?

    members.each { |name| yield name, self[name] }
  end

  def eql?(other)
    hash == other.hash || other.each_with_index.all? {|object, index|
      self[members[index]] == object
    }
  end

  def length
    members.length
  end

  alias size length

  def to_a
    members.map { |name| self[name] }
  end

  alias values to_a
end
