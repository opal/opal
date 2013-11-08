class Enumerator
  include Enumerable

  def initialize(obj = undefined, method = :each, *args, &block)
    if block
      @size   = obj
      @object = Generator.new(&block)
      @method = :each
    else
      if `obj === undefined`
        raise ArgumentError, "wrong number of arguments (0 for 1+)"
      end

      @size   = nil
      @object = obj
      @method = method
      @args   = args
    end
  end

  def each(&block)
    return enum_for :each unless block_given?

    @object.__send__(@method, *@args, &block)
  end

  def size
    Proc === @size ? @size.call : @size
  end

  def next
    @cache ||= to_a

    raise StopIteration, 'end of enumeration' if @cache.empty?

    @cache.shift
  end

  def rewind
    @cache = nil

    self
  end

  def inspect
    "#<Enumerator: #{@object.inspect}:#{@method}>"
  end

  class Generator
    include Enumerable

    def initialize(&block)
      raise LocalJumpError, 'no block given' unless block

      @block = block
    end

    def each(*args, &block)
      yielder = Yielder.new(&block)

      %x{
        try {
          args.unshift(#{yielder});

          if ($opal.$yieldX(#@block, args) === $breaker) {
            return $breaker.$v;
          }
        }
        catch (e) {
          if (e === $breaker) {
            return $breaker.$v;
          }
          else {
            throw e;
          }
        }
      }

      self
    end
  end

  class Yielder
    def initialize(&block)
      @block = block
    end

    def yield(*values)
      %x{
        if ($opal.$yieldX(#@block, values) === $breaker) {
          throw $breaker;
        }
      }

      self
    end

    alias << yield
  end
end
