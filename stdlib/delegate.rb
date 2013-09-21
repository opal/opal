class Delegator < BasicObject
  def initialize(obj)
    __setobj__(obj)
  end

  def method_missing(m, *args, &block)
    target = self.__getobj__

    if target.respond_to?(m)
      target.__send__(m, *args, &block)
    else
      super(m, *args, &block)
    end
  end
end

class SimpleDelegator < Delegator
  def __getobj__
    @delegate_sd_obj
  end

  def __setobj__(obj)
    @delegate_sd_obj = obj
  end
end

def DelegateClass(superklass)
  SimpleDelegator
end