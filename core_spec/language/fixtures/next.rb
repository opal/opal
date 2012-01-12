class NextSpecs
  def self.yielding_method(expected)
    yield.should == expected
    :method_return_value
  end

  def self.yielding
    yield
  end

  def self.while_next(arg)
    x = true
    while x
      begin
        ScratchPad << :begin
        x = false
        if arg
          next 42
        else
          next
        end
      ensure
        ScratchPad << :ensure
      end
    end
  end

  def self.while_within_iter(arg)
    yielding do
      x = true
      while x
        begin
          ScratchPad << :begin
          x = false
          if arg
            next 42
          else
            next
          end
        ensure
          ScratchPad << :ensure
        end
      end
    end
  end
end
