module BlockSpecs
  class Yielder
    def z
      yield
    end

    def m(*a)
      yield(*a)
    end

    def s(a)
      yield(a)
    end

    def r(a)
      yield(*a)
    end
  end
end

describe "A block" do
  before :each do
    @y = BlockSpecs::Yielder.new
  end

  it "captures locals from the surrounding scope" do
    var = 1
    @y.z { var }.should == 1
  end

  it "does not capture a local when an argument has the same name" do
    var = 1
    @y.s(2) { |var| var }.should == 2
    var.should == 1
  end

  describe "taking zero arguments" do
    before :each do
      @y = BlockSpecs::Yielder.new
    end

    it "does not raise an exception when no values are yielded" do
      @y.z { 1 }.should == 1
    end

    it "does not raise an exception when values are yielded" do
      @y.s(0) { 1 }.should == 1
    end
  end

  describe "taking || arguments" do
    before :each do
      @y = BlockSpecs::Yielder.new
    end

    it "does not raise an exception when no values are yielded" do
      @y.z { || 1 }.should == 1
    end

    it "does not raise an exception when values are yielded" do
      @y.s(0) { || 1 }.should == 1
    end
  end

  describe "taking |a| arguments" do
    before :each do
      @y = BlockSpecs::Yielder.new
    end

    it "assigns nil to the argument when no values are yielded" do
      @y.z { |a| a }.should be_nil
    end

    it "assigns the value yielded to the argument" do
      @y.s(1) { |a| a }.should == 1
    end

    it "assigns the first value yielded to the argument" do
      @y.m(1, 2) { |a| a }.should == 1
    end

    it "does not deconstruct a single Array value" do
      @y.s([1, 2]) { |a| a }.should == [1, 2]
    end
  end

  describe "taking |a, b| arguments" do
    before :each do
      @y = BlockSpecs::Yielder.new
    end

    it "assigns nil to the arguments when no values are yielded" do
      @y.z { |a, b| [a, b] }.should == [nil, nil]
    end

    it "assigns one value yielded to the first argument" do
      @y.s(1) { |a, b| [a, b] }.should == [1, nil]
    end

    it "assigns the first two values yielded to the arguments" do
      @y.m(1, 2, 3) { |a, b| [a, b] }.should == [1, 2]
    end

    it "does not destructive an Array value as one of the several values yielded" do
      @y.m([1, 2], 3, 4) { |a, b| [a, b] }.should == [[1, 2], 3]
    end
  end

  describe "taking |a, *b| arguments" do
    before :each do
      @y = BlockSpecs::Yielder.new
    end

    it "assigns 'nil' and '[]' to the arguments when no values are yielded" do
      @y.z { |a, *b| [a, b] }.should == [nil, []]
    end

    it "assigns all yielded values after the first to the rest arguments" do
      @y.m(1, 2, 3) { |a, *b| [a, b] }.should == [1, [2, 3]]
    end
  end
end