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

class ChainedNextTest
  def self.meth_with_yield(&b)
    yield.should == :next_return_value
    :method_return_value
  end
  def self.invoking_method(&b)
    meth_with_yield(&b)
  end
  def self.enclosing_method
    invoking_method do
      next :next_return_value
      :wrong_return_value
    end
  end
end