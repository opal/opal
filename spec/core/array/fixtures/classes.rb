module ArraySpecs
  class MyArray < Array
    def initialize(a, b)
      self << a << b
      ScratchPad.record :my_array_initialize
    end
  end
end
