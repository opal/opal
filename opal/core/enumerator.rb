class Enumerator
  include Enumerable

  def initialize(obj = nil, method = :each, *args, &block)
    if block
      @size  = obj
      @block = block
    else
      @object = obj
      @method = method
      @args   = args
    end
  end

  def each(&block)
    return enum_for :each unless block_given?

    if @block
      Yielder.new(self, @block).each(&block)
    else
      @object.__send__(@method, *@args, &block)
    end
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

  class Yielder
    def initialize(enumerator, block)
      @enumerator = enumerator
      @block      = block
    end

    def yield(*values)
      %x{
        if ($opal.$yieldX(#@to, values) === $breaker) {
          throw $breaker;
        }
      }

      self
    end

    alias << yield

    def each(&block)
      @to = block

      %x{
        try {
          #@block(self)
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
    end
  end
end
