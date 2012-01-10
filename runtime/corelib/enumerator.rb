class Enumerator
  include Enumerable

  class Yielder
    def initialize(block)
      @block = block
    end

    def call(block)
      @call = block

      @block.call
    end

    def yield(value)
      @call.call(value)
    end

    alias << yield
  end

  class Generator
    attr_reader :enumerator

    def initialize(block)
      @yielder = Yielder.new(block)
    end

    def each(&block)
      @yielder.call(block)
    end
  end

  def initialize(object = nil, method = :each, *args, &block)
    if block_given?
      @object = Generator.new(block)
    end

    raise ArgumentError, 'wrong number of argument (0 for 1+)' unless object

    @object = object
    @method = method
    @args   = args
  end

  def next
    _init_cache

    result    = @cache[@current] or raise StopIteration, 'iteration reached an end'
    @current += 1

    result
  end

  def next_values
    result = self.next

    result.is_a?(Array) ? result : [result]
  end

  def peek
    _init_cache

    @cache[@current] or raise StopIteration, 'iteration reached an end'
  end

  def peel_values
    result = self.peek

    result.is_a?(Array) ? result : [result]
  end

  def rewind
    _clear_cache
  end

  def each(&block)
    return self unless block

    @object.__send__ @method, *args, &block
  end

  def each_with_index(&block)
    with_index &block
  end

  def with_index(offset = 0)
    return Enumerator.new(self, :with_index, offset) unless block_given?

    current = 0

    each {|*args|
      next unless current >= offset

      yield *args, current

      current += 1
    }
  end

  def with_object(object)
    return Enumerator.new(self, :with_object, object) unless block_given?

    each {|*args|
      yield *args, object
    }
  end

private
  def _init_cache
    @current ||= 0
    @cache   ||= to_a
  end

  def _clear_cache
    @cache   = nil
    @current = nil
  end
end

module Kernel
  def enum_for (method = :each, *args)
    Enumerator.new(self, method, *args)
  end

  alias to_enum enum_for
end
