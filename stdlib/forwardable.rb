module Forwardable
  def instance_delegate(hash)
    hash.each do |methods, accessor|
      methods = [methods] unless methods.respond_to?(:each)
      methods.each do |method|
        def_instance_delegator(accessor, method)
      end
    end
  end

  def def_instance_delegators(accessor, *methods)
    methods.each { |m| def_instance_delegator accessor, m }
  end

  def def_instance_delegator(accessor, method, ali = method)
    accessor = accessor.to_s
    if accessor.start_with? '@'
      define_method ali do |args|
        `args = $slice.call(arguments, 1);`
        instance_variable_get(accessor).__send__(method, *args)
      end
    else
      define_method ali do |args|
        `args = $slice.call(arguments, 1);`
        __send__(accessor).__send__(method, *args)
      end
    end
  end

  alias delegate instance_delegate
  alias def_delegators def_instance_delegators
  alias def_delegator def_instance_delegator
end
