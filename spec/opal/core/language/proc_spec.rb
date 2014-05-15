describe "A Proc" do
  it "captures locals from the surrounding scope" do
    var = 1
    expect(lambda { var }.call).to eq(1)
  end

  ruby_version_is ""..."1.9" do
    it "overwrites a captured local when used as an argument" do
      var = 1
      expect(lambda { |var| var }.call(2)).to eq(2)
      expect(var).to eq(2)
    end
  end

  ruby_version_is "1.9" do
    it "does not capture a local when an argument has the same name" do
      var = 1
      expect(lambda { |var| var }.call(2)).to eq(2)
      expect(var).to eq(1)
    end
  end

  describe "taking zero arguments" do
    before :each do
      @l = lambda { 1 }
    end

    it "does not raise an exception if no values are passed" do
      expect(@l.call).to eq(1)
    end

    ruby_version_is ""..."1.9" do
      it "does not raise an exception if a value is passed" do
        expect(@l.call(0)).to eq(1)
      end
    end

    ruby_version_is "1.9" do
      it "raises an ArgumentErro if a value is passed" do
        expect { @l.call(0) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "taking || arguments" do
    before :each do
      @l = lambda { || 1 }
    end

    it "does not raise an exception when passed no values" do
      expect(@l.call).to eq(1)
    end

    it "raises an ArgumentError if a value is passed" do
      expect { @l.call(0) }.to raise_error(ArgumentError)
    end
  end

  describe "taking |a| arguments" do
    before :each do
      @l = lambda { |a| a }
    end

    it "assigns the value passed to the argument" do
      expect(@l.call(2)).to eq(2)
    end

    it "does not destructure a single Array value" do
      expect(@l.call([1, 2])).to eq([1, 2])
    end

    it "does not call #to_ary to convert a single passed object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).not_to receive(:to_ary)

      expect(@l.call(obj)).to equal(obj)
    end

    ruby_version_is ""..."1.9" do
      it "assigns nil to the argument if no value is passed" do
        expect(@l.call).to be_nil
      end

      it "assigns all the values passed to the argument as an Array" do
        expect(@l.call(1, 2)).to eq([1, 2])
      end
    end

    ruby_version_is "1.9" do
      it "raises an ArgumentError if no value is passed" do
        expect { @l.call }.to raise_error(ArgumentError)
      end
    end
  end

  describe "taking |a, b| arguments" do
    before :each do
      @l = lambda { |a, b| [a, b] }
    end

    it "raises an ArgumentError if passed no values" do
      expect { @l.call }.to raise_error(ArgumentError)
    end

    it "raises an ArgumentError if passed one value" do
      expect { @l.call(0) }.to raise_error(ArgumentError)
    end

    it "assigns the values passed to the arguments" do
      expect(@l.call(1, 2)).to eq([1, 2])
    end

    it "does not call #to_ary to convert a single passed object to an Array" do
      obj = double("proc call to_ary")
      expect(obj).not_to receive(:to_ary)

      expect { @l.call(obj) }.to raise_error(ArgumentError)
    end
  end

  describe "taking |a, *b| arguments" do
    before :each do
      @l = lambda { |a, *b| [a, b] }
    end

    it "raises an ArgumentError if passed no values" do
      expect { @l.call }.to raise_error(ArgumentError)
    end

    it "does not destructure a single Array value yielded" do
      expect(@l.call([1, 2, 3])).to eq([[1, 2, 3], []])
    end

    it "assigns all passed values after the first to the rest argument" do
        expect(@l.call(1, 2, 3)).to eq([1, [2, 3]])
    end

    it "does not call #to_ary to convert a single passed object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).not_to receive(:to_ary)

      expect(@l.call(obj)).to eq([obj, []])
    end
  end

  describe "taking |*| arguments" do
    before :each do
      # @l = lambda { |*| 1 }
    end

    it "does not raise an exception when passed no values" do
      expect(@l.call).to eq(1)
    end

    it "does not raise an exception when passed multiple values" do
      expect(@l.call(2, 3, 4)).to eq(1)
    end

    it "does not call #to_ary to convert a single passed object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).not_to receive(:to_ary)

      expect(@l.call(obj)).to eq(1)
    end
  end

  describe "taking |*a| arguments" do
    before :each do
      @l = lambda { |*a| a }
    end

    it "assigns [] to the argument when passed no values" do
      expect(@l.call).to eq([])
    end

    it "assigns the argument an Array wrapping one passed value" do
      expect(@l.call(1)).to eq([1])
    end

    it "assigns the argument an Array wrapping all values passed" do
      expect(@l.call(1, 2, 3)).to eq([1, 2, 3])
    end

    it "does not call #to_ary to convert a single passed object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).not_to receive(:to_ary)

      expect(@l.call(obj)).to eq([obj])
    end
  end

  describe "taking |a, | arguments" do
    before :each do
      # @l = lambda { |a, | a }
    end

    it "raises an ArgumentError when passed no values" do
      expect { @l.call }.to raise_error(ArgumentError)
    end

    it "raises an ArgumentError when passed more than one value" do
      expect { @l.call(1, 2) }.to raise_error(ArgumentError)
    end

    it "assigns the argument the value passed" do
      expect(@l.call(1)).to eq(1)
    end

    it "does not destructure when passed a single Array" do
      expect(@l.call([1,2])).to eq([1, 2])
    end

    it "does not call #to_ary to convert a single passed object to an Array" do
      obj = double("block yield to_ary")
      expect(obj).not_to receive(:to_ary)

      expect(@l.call(obj)).to eq(obj)
    end
  end

  describe "taking |(a, b)| arguments" do
    before :each do
      # @l = lambda { |(a, b)| [a, b] }
    end

    it "raises an ArgumentError when passed no values" do
      expect { @l.call }.to raise_error(ArgumentError)
    end

    ruby_version_is ""..."1.9" do
      it "raises an ArgumentError when passed a single Array" do
        expect { @l.call([1, 2]) }.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError when passed a single object" do
        obj = double("block yield to_ary")
        expect(obj).not_to receive(:to_ary)

        expect { @l.call(obj) }.to raise_error(ArgumentError)
      end
    end

    ruby_version_is "1.9" do
      it "destructures a single Array value yielded" do
        expect(@l.call([1, 2])).to eq([1, 2])
      end

      it "calls #to_ary to convert a single passed object to an Array" do
        obj = double("block yield to_ary")
        expect(obj).to receive(:to_ary).and_return([1, 2])

        expect(@l.call(obj)).to eq([1, 2])
      end

      it "raises an TypeError if #to_ary does not return an Array" do
        obj = double("block yield to_ary invalid")
        expect(obj).to receive(:to_ary).and_return(1)

        expect { @l.call(obj) }.to raise_error(TypeError)
      end
    end
  end
end
