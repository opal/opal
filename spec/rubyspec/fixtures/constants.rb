CS_GLOBAL = "global"
CS_NIL = nil
CS_ZERO = 0
CS_BLANK = ""
CS_FALSE = false

module ConstantSpecs
  class ClassA
    CS_CONST10 = :const10_10
    CS_CONST16 = :const16
    CS_CONST17 = :const17_2
    CS_CONST22 = :const22_1

    def self.const_missing(const)
      const
    end

    def self.constx;  CS_CONSTX;       end
    def self.const10; CS_CONST10;      end
    def self.const16; ParentA.const16; end
    def self.const22; ParentA.const22 { CS_CONST22 }; end

    def const10; CS_CONST10; end
    def constx;  CS_CONSTX;  end
  end
end
