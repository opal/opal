class Set
  include Enumerable

  def self.[](*ary)
    new(ary)
  end

  def initialize(enum = nil, &block)
    @hash = Hash.new

    return if enum.nil?
    raise ArgumentError, 'value must be enumerable' unless Enumerable === enum

    if block
      do_with_enum(enum) { |o| add(block[o]) }
    else
      merge(enum)
    end
  end

  def inspect
    "#<Set: {#{to_a.join(',')}}>"
  end

  def ==(other)
    if self.equal?(other)
      true
    elsif other.instance_of?(self.class)
      @hash == other.instance_variable_get(:@hash)
    elsif other.is_a?(Set) && self.size == other.size
      other.all? { |o| @hash.include?(o) }
    else
      false
    end
  end

  def add(o)
    @hash[o] = true
    self
  end
  alias << add

  def delete(o)
    @hash.delete(o)
    self
  end

  def delete?(o)
    if include?(o)
      delete(o)
      self
    else
      nil
    end
  end

  def delete_if
    block_given? or return enum_for(__method__)
    # @hash.delete_if should be faster, but using it breaks the order
    # of enumeration in subclasses.
    select { |o| yield o }.each { |o| @hash.delete(o) }
    self
  end

  def add?(o)
    if include?(o)
      nil
    else
      add(o)
    end
  end

  def each(&block)
    return enum_for :each unless block_given?
    @hash.each_key(&block)
    self
  end

  def empty?
    @hash.empty?
  end

  def clear
    @hash.clear
    self
  end

  def include?(o)
    @hash.include?(o)
  end
  alias member? include?

  def merge(enum)
    do_with_enum(enum) { |o| add o }
    self
  end

  def do_with_enum(enum, &block)
    enum.each(&block)
  end

  def size
    @hash.size
  end
  alias length size

  def to_a
    @hash.keys
  end
end

module Enumerable
  def to_set(klass = Set, *args, &block)
    klass.new(self, *args, &block)
  end
end
