module CoreClassSpecs
  module Inherited
    class D
      def self.inherited(subclass)
        ScratchPad << self
      end
    end
  end
end
module Include
  module Mod
    def a
      'M:a'
    end
  end

  class AClass
    def a
      'A:a'
    end
    include Mod
  end

  class BClass
    include Mod
  end

  class CClass < AClass 
    include Mod
  end
end