module Forwardable
  def instance_delegate(hash)
    hash.each {|methods, accessor|
      methods = [methods] unless methods.respond_to? :each

      methods.each {|method|
        def_instance_delegator(accessor, method)
      }
    }
  end

  def def_instance_delegators(accessor, *methods)
    methods.each {|method|
      next if %w[__send__ __id__].include?(method)

      def_instance_delegator(accessor, method)
    }
  end

  def def_instance_delegator(accessor, method, ali = method)
    if accessor.to_s.start_with? ?@
      define_method ali do |*args, &block|
        instance_variable_get(accessor).__send__(method, *args, &block)
      end
    else
      define_method ali do |*args, &block|
        __send__(accessor).__send__(method, *args, &block)
      end
    end
  end

  alias delegate instance_delegate
  alias def_delegators def_instance_delegators
  alias def_delegator def_instance_delegator
end

module SingleForwardable
  def single_delegate(hash)
    hash.each {|methods, accessor|
      methods = [methods] unless methods.respond_to? :each

      methods.each {|method|
        def_single_delegator(accessor, method)
      }
    }
  end

  def def_single_delegators(accessor, *methods)
    methods.each {|method|
      next if %w[__send__ __id__].include? method

      def_single_delegator(accessor, method)
    }
  end

  def def_single_delegator(accessor, method, ali = method)
    if accessor.to_s.start_with? ?@
      define_singleton_method ali do |*args, &block|
        instance_variable_get(accessor).__send__(method, *args, &block)
      end
    else
      define_singleton_method ali do |*args, &block|
        __send__(accessor).__send__(method, *args, &block)
      end
    end
  end

  alias delegate single_delegate
  alias def_delegators def_single_delegators
  alias def_delegator def_single_delegator
end
