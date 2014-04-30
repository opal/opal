require 'support/parser_helpers'

describe "The begin keyword" do
  it "should be removed when used without a resuce or enusre body" do
    parsed('begin; 1; end').should == [:int, 1]
    parsed('begin; 1; 2; end').should == [:block, [:int, 1], [:int, 2]]
  end

  describe "with 'rescue' bodies" do
    it "should create a s(:rescue) sexp" do
      parsed('begin; 1; rescue; 2; end').should == [:rescue, [:int, 1], [:resbody, [:array], [:int, 2]]]
    end

    it "allows multiple rescue bodies" do
      parsed('begin 1; rescue; 2; rescue; 3; end').should == [:rescue, [:int, 1], [:resbody, [:array], [:int, 2]], [:resbody, [:array], [:int, 3]]]
    end

    it "accepts a list of classes used to match against the exception" do
      parsed('begin 1; rescue Klass; 2; end').should == [:rescue, [:int, 1], [:resbody, [:array, [:const, :Klass]], [:int, 2]]]
    end

    it "accepts an identifier to assign exception to" do
      parsed('begin 1; rescue => a; 2; end').should == [:rescue, [:int, 1], [:resbody, [:array, [:lasgn, :a, [:gvar, :$!]]], [:int, 2]]]
      parsed('begin 1; rescue Klass => a; 2; end').should == [:rescue, [:int, 1], [:resbody, [:array, [:const, :Klass],[:lasgn, :a, [:gvar, :$!]]], [:int, 2]]]
    end

    it "accepts an ivar to assign exception to" do
      parsed('begin 1; rescue => @a; 2; end').should == [:rescue, [:int, 1], [:resbody, [:array, [:iasgn, :@a, [:gvar, :$!]]], [:int, 2]]]
      parsed('begin 1; rescue Klass => @a; 2; end').should == [:rescue, [:int, 1], [:resbody, [:array, [:const, :Klass],[:iasgn, :@a, [:gvar, :$!]]], [:int, 2]]]
    end

    it "should parse newline right after rescue" do
      parsed("begin; 1; rescue\n 2; end").should == [:rescue, [:int, 1], [:resbody, [:array], [:int, 2]]]
    end
  end

  describe "with an 'ensure' block" do
    it "should propagate into single s(:ensure) statement when no rescue block given" do
      parsed('begin; 1; ensure; 2; end').should == [:ensure, [:int, 1], [:int, 2]]
    end
  end
end
