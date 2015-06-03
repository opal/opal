class Object
  
  def catch(sym)
    yield
  rescue CatchThrow => e
    return e.arg if e.sym == sym
    raise e
  end

  def throw(*args)
    raise CatchThrow.new(args)
  end
  
  protected
  
  class CatchThrow < Exception 
    attr_reader :sym
    attr_reader :arg
    def initialize(args)
      @sym = args[0]
      @arg = args[1] if args.count > 1
    end
  end
  
end
