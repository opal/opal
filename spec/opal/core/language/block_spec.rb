require File.expand_path('../fixtures/block', __FILE__)

describe "A block" do
  before :each do
    @y = BlockSpecs::Yielder.new
  end

  it "captures locals from the surrounding scope" do
    var = 1
    expect(@y.z { var }).to eq(1)
  end

  it "allows for a leading space before the arguments" do
    # res = @y.s (:a){ 1 }
    # res.should == 1
  end

  it "allows to define a block variable with the same name as the enclosing block" do
    o = BlockSpecs::OverwriteBlockVariable.new
    expect(o.z { 1 }).to eq(1)
  end

  ruby_version_is ""..."1.9" do
    it "overwrites a captured local when used as an argument" do
      var = 1
      expect(@y.s(2) { |var| var }).to eq(2)
      expect(var).to eq(2)
    end
  end

  ruby_version_is "1.9" do
    it "does not capture a local when an argument has the same name" do
      var = 1
      expect(@y.s(2) { |var| var }).to eq(2)
      expect(var).to eq(1)
    end
  end

  describe "taking zero arguments" do
    it "does not raise an exception when no values are yielded" do
      expect(@y.z { 1 }).to eq(1)
    end

    it "does not raise an exception when values are yielded" do
      expect(@y.s(0) { 1 }).to eq(1)
    end
  end

  describe "taking || arguments" do
    it "does not raise an exception when no values are yielded" do
      expect(@y.z { || 1 }).to eq(1)
    end

    it "does not raise an exception when values are yielded" do
      expect(@y.s(0) { || 1 }).to eq(1)
    end
  end

  describe "taking |a| arguments" do
    it "assigns nil to the argument when no values are yielded" do
      expect(@y.z { |a| a }).to be_nil
    end

    it "assigns the value yielded to the argument" do
      expect(@y.s(1) { |a| a }).to eq(1)
    end

    it "does not call #to_ary to convert a single yielded object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).not_to receive(:to_ary)

      expect(@y.s(obj) { |a| a }).to equal(obj)
    end

    ruby_version_is ""..."1.9" do
      it "assigns all the values yielded to the argument as an Array" do
        expect(@y.m(1, 2) { |a| a }).to eq([1, 2])
      end
    end

    ruby_version_is "1.9" do
      it "assigns the first value yielded to the argument" do
        expect(@y.m(1, 2) { |a| a }).to eq(1)
      end
    end

    it "does not destructure a single Array value" do
      expect(@y.s([1, 2]) { |a| a }).to eq([1, 2])
    end
  end

  describe "taking |a, b| arguments" do
    it "assgins nil to the arguments when no values are yielded" do
      expect(@y.z { |a, b| [a, b] }).to eq([nil, nil])
    end

    it "assigns one value yielded to the first argument" do
      expect(@y.s(1) { |a, b| [a, b] }).to eq([1, nil])
    end

    it "assigns the first two values yielded to the arguments" do
      expect(@y.m(1, 2, 3) { |a, b| [a, b] }).to eq([1, 2])
    end

    it "does not destructure an Array value as one of several values yielded" do
      expect(@y.m([1, 2], 3, 4) { |a, b| [a, b] }).to eq([[1, 2], 3])
    end

    it "assigns 'nil' and 'nil' to the arguments when a single, empty Array is yielded" do
      expect(@y.s([]) { |a, b| [a, b] }).to eq([nil, nil])
    end

    it "assigns the element of a single element Array to the first argument" do
      expect(@y.s([1]) { |a, b| [a, b] }).to eq([1, nil])
      expect(@y.s([nil]) { |a, b| [a, b] }).to eq([nil, nil])
      expect(@y.s([[]]) { |a, b| [a, b] }).to eq([[], nil])
    end

    it "destructures a single Array value yielded" do
      expect(@y.s([1, 2, 3]) { |a, b| [a, b] }).to eq([1, 2])
    end

    ruby_version_is ""..."1.9" do
      it "does not destructure a splatted Array" do
        expect(@y.r([[]]) { |a, b| [a, b] }).to eq([[], nil])
        expect(@y.r([[1]]) { |a, b| [a, b] }).to eq([[1], nil])
      end
    end

    ruby_version_is "1.9" do
      it "destructures a splatted Array" do
        expect(@y.r([[]]) { |a, b| [a, b] }).to eq([nil, nil])
        expect(@y.r([[1]]) { |a, b| [a, b] }).to eq([1, nil])
      end
    end

    it "calls #to_ary to convert a single yielded object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).to receive(:to_ary).and_return([1, 2])

      expect(@y.s(obj) { |a, b| [a, b] }).to eq([1, 2])
    end

    it "does not call #to_ary if the single yielded object is an Array" do
      obj = [1, 2]
      expect(obj).not_to receive(:to_ary)

      expect(@y.s(obj) { |a, b| [a, b] }).to eq([1, 2])
    end

    it "does not call #to_ary if the object does not respond to #to_ary" do
      obj = double("block yield no to_ary")

      expect(@y.s(obj) { |a, b| [a, b] }).to eq([obj, nil])
    end

    it "raises an TypeError if #to_ary does not return an Array" do
      obj = double("block yield to_ary invalid")
      expect(obj).to receive(:to_ary).and_return(1)

      expect { @y.s(obj) { |a, b| } }.to raise_error(TypeError)
    end
  end

  describe "taking |a, *b| arguments" do
    it "assigns 'nil' and '[]' to the arguments when no values are yielded" do
      expect(@y.z { |a, *b| [a, b] }).to eq([nil, []])
    end

    it "assigns all yielded values after the first to the rest argument" do
      expect(@y.m(1, 2, 3) { |a, *b| [a, b] }).to eq([1, [2, 3]])
    end

    it "assigns 'nil' and '[]' to the arguments when a single, empty Array is yielded" do
      expect(@y.s([]) { |a, *b| [a, b] }).to eq([nil, []])
    end

    it "assigns the element of a single element Array to the first argument" do
      expect(@y.s([1]) { |a, *b| [a, b] }).to eq([1, []])
      expect(@y.s([nil]) { |a, *b| [a, b] }).to eq([nil, []])
      expect(@y.s([[]]) { |a, *b| [a, b] }).to eq([[], []])
    end

    ruby_version_is ""..."1.9" do
      it "does not destructure a splatted Array" do
        expect(@y.r([[]]) { |a, *b| [a, b] }).to eq([[], []])
        expect(@y.r([[1]]) { |a, *b| [a, b] }).to eq([[1], []])
      end
    end

    ruby_version_is "1.9" do
      it "destructures a splatted Array" do
        expect(@y.r([[]]) { |a, *b| [a, b] }).to eq([nil, []])
        expect(@y.r([[1]]) { |a, *b| [a, b] }).to eq([1, []])
      end
    end

    it "destructures a single Array value assigning the remaining values to the rest argument" do
      expect(@y.s([1, 2, 3]) { |a, *b| [a, b] }).to eq([1, [2, 3]])
    end

    it "calls #to_ary to convert a single yielded object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).to receive(:to_ary).and_return([1, 2])

      expect(@y.s(obj) { |a, *b| [a, b] }).to eq([1, [2]])
    end

    it "does not call #to_ary if the single yielded object is an Array" do
      obj = [1, 2]
      expect(obj).not_to receive(:to_ary)

      expect(@y.s(obj) { |a, *b| [a, b] }).to eq([1, [2]])
    end

    it "does not call #to_ary if the object does not respond to #to_ary" do
      obj = double("block yield no to_ary")

      expect(@y.s(obj) { |a, *b| [a, b] }).to eq([obj, []])
    end

    it "raises an TypeError if #to_ary does not return an Array" do
      obj = double("block yield to_ary invalid")
      expect(obj).to receive(:to_ary).and_return(1)

      expect { @y.s(obj) { |a, *b| } }.to raise_error(TypeError)
    end
  end

  describe "taking |*| arguments" do
    it "does not raise an exception when no values are yielded" do
      # @y.z { |*| 1 }.should == 1
    end

    it "does not raise an exception when values are yielded" do
      # @y.s(0) { |*| 1 }.should == 1
    end

    it "does not call #to_ary if the single yielded object is an Array" do
      obj = [1, 2]
      expect(obj).not_to receive(:to_ary)

      # @y.s(obj) { |*| 1 }.should == 1
    end

    it "does not call #to_ary if the object does not respond to #to_ary" do
      obj = double("block yield no to_ary")

      # @y.s(obj) { |*| 1 }.should == 1
    end

    ruby_version_is ""..."1.9" do
      it "calls #to_ary to convert a single yielded object to an Array" do
        obj = double("block yield to_ary")
        expect(obj).to receive(:to_ary).and_return([1, 2])

        # @y.s(obj) { |*| 1 }.should == 1
      end

      it "does not raise a TypeError if #to_ary returns nil" do
        obj = double("block yield to_ary nil")
        expect(obj).to receive(:to_ary).and_return(nil)

        # @y.s(obj) { |*o| o }.should == [obj]
      end

      it "raises an TypeError if #to_ary does not return an Array" do
        obj = double("block yield to_ary invalid")
        expect(obj).to receive(:to_ary).and_return(1)

        # lambda { @y.s(obj) { |*| } }.should raise_error(TypeError)
      end
    end

    ruby_version_is "1.9" do
      it "does not call #to_ary to convert a single yielded object to an Array" do
        obj = double("block yield to_ary")
        expect(obj).not_to receive(:to_ary)

        # @y.s(obj) { |*| 1 }.should == 1
      end
    end
  end

  describe "taking |*a| arguments" do
    it "assigns '[]' to the argument when no values are yielded" do
      expect(@y.z { |*a| a }).to eq([])
    end

    it "assigns a single value yielded to the argument as an Array" do
      expect(@y.s(1) { |*a| a }).to eq([1])
    end

    it "assigns all the values passed to the argument as an Array" do
      expect(@y.m(1, 2, 3) { |*a| a }).to eq([1, 2, 3])
    end

    it "assigns '[[]]' to the argument when passed an empty Array" do
      expect(@y.s([]) { |*a| a }).to eq([[]])
    end

    it "assigns a single Array value passed to the argument by wrapping it in an Array" do
      expect(@y.s([1, 2, 3]) { |*a| a }).to eq([[1, 2, 3]])
    end

    it "does not call #to_ary if the single yielded object is an Array" do
      obj = [1, 2]
      expect(obj).not_to receive(:to_ary)

      expect(@y.s(obj) { |*a| a }).to eq([[1, 2]])
    end

    it "does not call #to_ary if the object does not respond to #to_ary" do
      obj = double("block yield no to_ary")

      expect(@y.s(obj) { |*a| a }).to eq([obj])
    end

    ruby_version_is ""..."1.9" do
      it "calls #to_ary to convert a single yielded object to an Array" do
        obj = double("block yield to_ary")
        expect(obj).to receive(:to_ary).and_return([1, 2])

        expect(@y.s(obj) { |*a| a }).to eq([obj])
      end

      it "raises an TypeError if #to_ary does not return an Array" do
        obj = double("block yield to_ary invalid")
        expect(obj).to receive(:to_ary).and_return(1)

        expect { @y.s(obj) { |*a| } }.to raise_error(TypeError)
      end
    end

    ruby_version_is "1.9" do
      it "does not call #to_ary to convert a single yielded object to an Array" do
        obj = double("block yield to_ary")
        expect(obj).not_to receive(:to_ary)

        expect(@y.s(obj) { |*a| a }).to eq([obj])
      end
    end
  end

  describe "taking |a, | arguments" do
    it "assigns nil to the argument when no values are yielded" do
      # @y.z { |a, | a }.should be_nil
    end

    it "assgins the argument a single value yielded" do
      # @y.s(1) { |a, | a }.should == 1
    end

    it "assigns the argument the first value yielded" do
      # @y.m(1, 2) { |a, | a }.should == 1
    end

    it "assigns the argument the first of several values yielded when it is an Array" do
      # @y.m([1, 2], 3) { |a, | a }.should == [1, 2]
    end

    it "assigns nil to the argument when passed an empty Array" do
      # @y.s([]) { |a, | a }.should be_nil
    end

    it "assigns the argument the first element of the Array when passed a single Array" do
      # @y.s([1, 2]) { |a, | a }.should == 1
    end

    it "calls #to_ary to convert a single yielded object to an Array" do
      # obj = mock("block yield to_ary")
      # obj.should_receive(:to_ary).and_return([1, 2])

      # @y.s(obj) { |a, | a }.should == 1
    end

    it "does not call #to_ary if the single yielded object is an Array" do
      # obj = [1, 2]
      # obj.should_not_receive(:to_ary)

      # @y.s(obj) { |a, | a }.should == 1
    end

    it "does not call #to_ary if the object does not respond to #to_ary" do
      # obj = mock("block yield no to_ary")

      # @y.s(obj) { |a, | a }.should == obj
    end

    it "raises an TypeError if #to_ary does not return an Array" do
      # obj = mock("block yield to_ary invalid")
      # obj.should_receive(:to_ary).and_return(1)

      # lambda { @y.s(obj) { |a, | } }.should raise_error(TypeError)
    end
  end

  describe "taking |(a, b)| arguments" do
    it "assigns nil to the arguments when yielded no values" do
      expect(@y.z { |(a, b)| [a, b] }).to eq([nil, nil])
    end

    it "destructures a single Array value yielded" do
      expect(@y.s([1, 2]) { |(a, b)| [a, b] }).to eq([1, 2])
    end

    it "calls #to_ary to convert a single yielded object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).to receive(:to_ary).and_return([1, 2])

      expect(@y.s(obj) { |(a, b)| [a, b] }).to eq([1, 2])
    end

    it "does not call #to_ary if the single yielded object is an Array" do
      obj = [1, 2]
      expect(obj).not_to receive(:to_ary)

      expect(@y.s(obj) { |(a, b)| [a, b] }).to eq([1, 2])
    end

    it "does not call #to_ary if the object does not respond to #to_ary" do
      obj = double("block yield no to_ary")

      expect(@y.s(obj) { |(a, b)| [a, b] }).to eq([obj, nil])
    end

    it "raises an TypeError if #to_ary does not return an Array" do
      obj = double("block yield to_ary invalid")
      expect(obj).to receive(:to_ary).and_return(1)

      expect { @y.s(obj) { |(a, b)| } }.to raise_error(TypeError)
    end
  end

  describe "taking |(a, b), c| arguments" do
    it "assigns nil to the arguments when yielded no values" do
      expect(@y.z { |(a, b), c| [a, b, c] }).to eq([nil, nil, nil])
    end

    it "destructures a single one-level Array value yielded" do
      expect(@y.s([1, 2]) { |(a, b), c| [a, b, c] }).to eq([1, nil, 2])
    end

    it "destructures a single multi-level Array value yielded" do
      expect(@y.s([[1, 2, 3], 4]) { |(a, b), c| [a, b, c] }).to eq([1, 2, 4])
    end

    it "calls #to_ary to convert a single yielded object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).to receive(:to_ary).and_return([1, 2])

      expect(@y.s(obj) { |(a, b), c| [a, b, c] }).to eq([1, nil, 2])
    end

    it "does not call #to_ary if the single yielded object is an Array" do
      obj = [1, 2]
      expect(obj).not_to receive(:to_ary)

      expect(@y.s(obj) { |(a, b), c| [a, b, c] }).to eq([1, nil, 2])
    end

    it "does not call #to_ary if the object does not respond to #to_ary" do
      obj = double("block yield no to_ary")

      expect(@y.s(obj) { |(a, b), c| [a, b, c] }).to eq([obj, nil, nil])
    end

    it "raises an TypeError if #to_ary does not return an Array" do
      obj = double("block yield to_ary invalid")
      expect(obj).to receive(:to_ary).and_return(1)

      expect { @y.s(obj) { |(a, b), c| } }.to raise_error(TypeError)
    end
  end

  describe "taking nested |a, (b, (c, d))|" do
    it "assigns nil to the arguments when yielded no values" do
      # @y.m { |a, (b, (c, d))| [a, b, c, d] }.should == [nil, nil, nil, nil]
    end

    it "destructures separate yielded values" do
      # @y.m(1, 2) { |a, (b, (c, d))| [a, b, c, d] }.should == [1, 2, nil, nil]
    end

    it "destructures a single multi-level Array value yielded" do
      # @y.m(1, [2, 3]) { |a, (b, (c, d))| [a, b, c, d] }.should == [1, 2, 3, nil]
    end

    it "destructures a single multi-level Array value yielded" do
      # @y.m(1, [2, [3, 4]]) { |a, (b, (c, d))| [a, b, c, d] }.should == [1, 2, 3, 4]
    end
  end

  describe "taking nested |a, ((b, c), d)|" do
    it "assigns nil to the arguments when yielded no values" do
      # @y.m { |a, ((b, c), d)| [a, b, c, d] }.should == [nil, nil, nil, nil]
    end

    it "destructures separate yielded values" do
      # @y.m(1, 2) { |a, ((b, c), d)| [a, b, c, d] }.should == [1, 2, nil, nil]
    end

    it "destructures a single multi-level Array value yielded" do
      # @y.m(1, [2, 3]) { |a, ((b, c), d)| [a, b, c, d] }.should == [1, 2, nil, 3]
    end

    it "destructures a single multi-level Array value yielded" do
      # @y.m(1, [[2, 3], 4]) { |a, ((b, c), d)| [a, b, c, d] }.should == [1, 2, 3, 4]
    end
  end

  describe "arguments with _" do

    ruby_version_is ""..."1.9" do
      it "extracts arguments with _" do
        expect(@y.m([[1, 2, 3], 4]) { |(_, a, _), _| a }).to eq(4)
      end

      it "assigns the last variable named" do
        expect(@y.m(1, 2) { |_, _| _ }).to eq(2)
      end
    end

    ruby_version_is "1.9" do
      it "extracts arguments with _" do
        expect(@y.m([[1, 2, 3], 4]) { |(_, a, _), _| a }).to eq(2)
      end

      it "assigns the first variable named" do
        expect(@y.m(1, 2) { |_, _| _ }).to eq(1)
      end
    end

  end

end

language_version __FILE__, "block"
