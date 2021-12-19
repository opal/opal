# helpers: slice, coerce_to

require 'corelib/enumerable'

class ::Enumerator
  include ::Enumerable

  `self.$$prototype.$$is_enumerator = true`

  def self.for(object, method = :each, *args, &block)
    %x{
      var obj = #{allocate};

      obj.object = object;
      obj.size   = block;
      obj.method = method;
      obj.args   = args;
      obj.cursor = 0;

      return obj;
    }
  end

  def initialize(*, &block)
    @cursor = 0
    if block
      @object = Generator.new(&block)
      @method = :each
      @args   = []
      @size   = `arguments[0] || nil`

      if @size && !@size.respond_to?(:call)
        @size = `$coerce_to(#{@size}, #{::Integer}, 'to_int')`
      end
    else
      @object = `arguments[0]`
      @method = `arguments[1] || "each"`
      @args   = `$slice.call(arguments, 2)`
      @size   = nil
    end
  end

  def each(*args, &block)
    return self if block.nil? && args.empty?

    args = @args + args

    return self.class.new(@object, @method, *args) if block.nil?

    @object.__send__(@method, *args, &block)
  end

  def size
    @size.respond_to?(:call) ? @size.call(*@args) : @size
  end

  def with_index(offset = 0, &block)
    offset = if offset
               `$coerce_to(offset, #{::Integer}, 'to_int')`
             else
               0
             end

    return enum_for(:with_index, offset) { size } unless block

    %x{
      var result, index = offset;

      self.$each.$$p = function() {
        var param = #{::Opal.destructure(`arguments`)},
            value = block(param, index);

        index++;

        return value;
      }

      return self.$each();
    }
  end

  def each_with_index(&block)
    return enum_for(:each_with_index) { size } unless block_given?

    super
    @object
  end

  def rewind
    @cursor = 0

    self
  end

  def peek_values
    @values ||= map { |*i| i }
    ::Kernel.raise ::StopIteration, 'iteration reached an end' if @cursor >= @values.length
    @values[@cursor]
  end

  def peek
    values = peek_values
    values.length <= 1 ? values[0] : values
  end

  def next_values
    out = peek_values
    @cursor += 1
    out
  end

  def next
    values = next_values
    values.length <= 1 ? values[0] : values
  end

  def feed(arg)
    raise NotImplementedError, "Opal doesn't support Enumerator#feed"
  end

  def +(other)
    ::Enumerator::Chain.new(self, other)
  end

  def inspect
    result = "#<#{self.class}: #{@object.inspect}:#{@method}"

    if @args.any?
      result += "(#{@args.inspect[::Range.new(1, -2)]})"
    end

    result + '>'
  end

  alias with_object each_with_object

  autoload :ArithmeticSequence, 'corelib/enumerator/arithmetic_sequence'
  autoload :Chain, 'corelib/enumerator/chain'
  autoload :Generator, 'corelib/enumerator/generator'
  autoload :Lazy, 'corelib/enumerator/lazy'
  autoload :Yielder, 'corelib/enumerator/yielder'
end
