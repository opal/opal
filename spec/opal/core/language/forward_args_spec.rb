describe "Forward arguments" do
  it "forwards args, kwargs and blocks" do
    def fwd_t1_pass1(...)
      fwd_t1_pass2(...)
    end

    def fwd_t1_pass2(*args, **kwargs, &block)
      [args.count, kwargs.count, block_given?]
    end

    fwd_t1_pass1(1, 2, 3, a: 1, b: 2).should == [3, 2, false]
    fwd_t1_pass1(1, 2, &:itself).should == [2, 0, true]
    fwd_t1_pass1(a: 1, b: 2).should == [0, 2, false]
  end

  it "supports forwarding with initial arguments (3.0 behavior)" do
    def fwd_t2_pass1(initial, ...)
      fwd_t2_pass2(0, initial + 1, ...)
    end

    def fwd_t2_pass2(a, b, c)
      a + b + c
    end

    fwd_t2_pass1(2, 3).should == 6
    error = nil
    begin
      fwd_t2_pass1(2, 3, 4) # Too many arguments passwd to fwd_t2_pass2
    rescue ArgumentError
      error = :ArgumentError
    end
    error.should == :ArgumentError
  end

  it "supports forwarding to multiple methods at once" do
    def fwd_t3_pass1(...)
      fwd_t3_pass2a(...) + fwd_t3_pass2b(...) + fwd_t3_pass2c(...)
    end

    def fwd_t3_pass2a(*args)
      -2 * args.count
    end
    def fwd_t3_pass2b(*args)
      1 * args.count
    end
    def fwd_t3_pass2c(*args)
      0 * args.count
    end

    fwd_t3_pass1(0, 0, 0).should == -3
    fwd_t3_pass1(0, 0).should == -2
  end
end
