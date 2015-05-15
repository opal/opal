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
      enum.each { |item| add block.call(item) }
    else
      merge(enum)
    end
  end

  def dup
    result = self.class.new
    result.merge(self)
  end

  def -(enum)
    unless enum.respond_to? :each
      raise ArgumentError, "value must be enumerable"
    end

    dup.subtract(enum)
  end
  alias difference -

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

  def classify(&block)
    return enum_for(:classify) unless block_given?

    result = Hash.new { |h, k| h[k] = self.class.new }

    each { |item| result[yield(item)].add item }

    result
  end

  def collect!(&block)
    return enum_for(:collect!) unless block_given?
    result = self.class.new
    each { |item| result << yield(item) }
    replace result
  end
  alias map! collect!

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

  def eql?(other)
    @hash.eql?(other.instance_eval { @hash })
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
    enum.each { |item| add item }
    self
  end

  def replace(enum)
    clear
    merge(enum)

    self
  end

  def size
    @hash.size
  end
  alias length size

  def subtract(enum)
    enum.each { |item| delete item }
    self
  end
  
  def |(enum)
    unless enum.respond_to? :each
      raise ArgumentError, "value must be enumerable"
    end
    dup.merge(enum)
  end
  
  alias + |
  alias union |

  def to_a
    @hash.keys
  end
end

module Enumerable
  def to_set(klass = Set, *args, &block)
    klass.new(self, *args, &block)
  end
end
