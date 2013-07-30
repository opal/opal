module Singleton
  def clone
    raise TypeError, "can't clone instance of singleton #{self.class}"
  end

  def dup
    raise TypeError, "can't dup instance of singleton #{self.class}"
  end

  module SingletonClassMethods

    def clone
      Singleton.__init__(super)
    end

    def inherited(sub_klass)
      super
      Singleton.__init__(sub_klass)
    end
  end

  class << Singleton
    def __init__(klass)
      klass.instance_eval {
        @singleton__instance__ = nil
      }
      def klass.instance
        return @singleton__instance__ if @singleton__instance__
        @singleton__instance__ = new()
      end
      klass
    end

    def included(klass)
      super
      klass.extend SingletonClassMethods
      Singleton.__init__(klass)
    end
  end
end
