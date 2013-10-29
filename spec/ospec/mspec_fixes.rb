require 'mspec/mocks/mock'

# 1. Opal does not support mutable strings
class ExceptionState
  def initialize(state, location, exception)
    @exception = exception

    @description = location ? ["An exception occurred during: #{location}"] : []
    if state
      @description << "\n" unless @description.empty?
      @description << state.description
      @describe = state.describe
      @it = state.it
      @description = @description.join ""
    else
      @describe = @it = ""
    end
  end
end

# 2. class_eval() doesnt except string parameter
def Mock.install_method(obj, sym, type=nil)
  meta = obj.singleton_class

  key = replaced_key obj, sym
  sym = sym.to_sym

  if (sym == :respond_to? or mock_respond_to?(obj, sym, true)) and !replaced?(key.first)
    meta.__send__ :alias_method, key.first, sym
  end

  # meta.class_eval <<-END
  #   def #{sym}(*args, &block)
  #     Mock.verify_call self, :#{sym}, *args, &block
  #   end
  # END
  meta.class_eval {
    define_method(sym) do |*args, &block|
      Mock.verify_call self, sym, *args, &block
    end
  }

  proxy = MockProxy.new type

  if proxy.mock?
    MSpec.expectation
    MSpec.actions :expectation, MSpec.current.state
  end

  if proxy.stub?
    stubs[key].unshift proxy
  else
    mocks[key] << proxy
  end
  objects[key] = obj

  proxy
end
