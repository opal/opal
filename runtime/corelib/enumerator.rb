# NOTE: our next/peek/rewind implementation is REALLY slow

class Enumerator
  include Enumerable

  class Yielder
    def initialize (block)
      @block = block
    end

    def call (block)
      @call = block

      @block.call
    end

    def yield (value)
      @call.call(value)
    end

    alias_method :<<, :yield
  end

  class Generator
    attr_reader :enumerator

    def initialize (block)
      @yielder = Yielder.new(block)
    end

    def each (&block)
      @yielder.call(block)
    end
  end

  def initialize (object = nil, method = :each, *args, &block)
    if block_given?
      @object = Generator.new(block)
      method  = :each
    end

    raise ArgumentError, 'wrong number of argument (0 for 1+)' unless object

    @object = object
    @method = method
    @args   = args

    @current = 0
  end

  def next
  end

  def each (&block)
    return self unless block

    @object.__send__ @method, *args, &block
  end

  def each_with_index (&block)
    with_index &block
  end

  def with_index (offset = 0, &block)
    return Enumerator.new(self, :with_index, offset) unless block
  end

  def with_object (object, &block)
    return Enumerator.new(self, :with_object, object) unless block

  end
end

module Kernel
  def enum_for (method = :each, *args)
    Enumerator.new(self, method, *args)
  end

  alias_method :to_enum, :enum_for
end
