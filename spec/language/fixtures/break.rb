module BreakSpecs
  class Driver
    def initialize(ensures=false)
      @ensures = ensures
    end

    def note(value)
      ScratchPad << value
    end
  end

  class Block < Driver
    def break_nil
      note :a
      note yielding {
        note :b
        break
        note :c
      }
      note :d
    end

    def break_value
      note :a
      note yielding {
        note :b
        break :break
        note :c
      }
      note :d
    end

    def yielding
      note :aa
      note yield
      note :bb
    end
  end

end

