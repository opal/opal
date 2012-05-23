module CoreClassSpecs
  module Inherited
    class D
      def self.inherited(subclass)
        ScratchPad << self
      end
    end
  end
end