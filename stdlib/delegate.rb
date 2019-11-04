class Delegator < BasicObject
  def initialize(obj)
    __setobj__(obj)
  end

  def method_missing(m, *args, &block)
    target = __getobj__

    if target.respond_to?(m)
      target.__send__(m, *args, &block)
    else
      super(m, *args, &block)
    end
  end

  #
  # Checks for a method provided by this the delegate object by forwarding the
  # call through \_\_getobj\_\_.
  #
  def respond_to_missing?(m, include_private)
    __getobj__.respond_to?(m, include_private)
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
