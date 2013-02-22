class Enumerator
  include Enumerable

  def initialize(obj, method = :each, *args)
    @object = obj
    @method = method
    @args = args
  end

  def each(&block)
    #raise "sending #{@method}, => #{@args.inspect} to #{@object.inspect}"
    @object.__send__(@method, *@args) do |e|
      block.call e
    end
  end
end
