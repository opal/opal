class Enumerator
  include Enumerable

  def initialize(obj, method = :each, *args)
    @object = obj
    @method = method
    @args   = args
  end

  def each(&block)
    return enum_for :each unless block_given?

    @object.__send__(@method, *@args) do |*e|
      block.call(*e)
    end
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
end
