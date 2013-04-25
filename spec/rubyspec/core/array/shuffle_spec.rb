require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#shuffle" do
  ruby_version_is "1.8.7" do
    it "returns the same values, in a usually different order" do
      a = [1, 2, 3, 4]
      different = false
      10.times do
        s = a.shuffle
        s.sort.should == a
        different ||= (a != s)
      end
      different.should be_true # Will fail once in a blue moon (4!^10)
    end

    it "is not destructive" do
      a = [1, 2, 3]
      10.times do
        a.shuffle
        a.should == [1, 2, 3]
      end
    end
  end

  ruby_version_is "1.8.7" ... "1.9.3" do
    pending "returns subclass instances with Array subclass" do
      ArraySpecs::MyArray[1, 2, 3].shuffle.should be_an_instance_of(ArraySpecs::MyArray)
    end
  end

  ruby_version_is "1.9.3" do
    it "does not return subclass instances with Array subclass" do
      ArraySpecs::MyArray[1, 2, 3].shuffle.should be_an_instance_of(Array)
    end
  end

  ruby_version_is "1.9.3" do
    it "attempts coercion via #to_hash" do
      obj = mock('hash')
      obj.should_receive(:to_hash).once.and_return({})
      [2, 3].shuffle(obj)
    end

    it "uses default random generator" do
      Kernel.should_receive(:rand).exactly(2).and_return(1, 0)
      [2, 3].shuffle(:random => Object.new).should == [3, 2]
    end

    it "uses given random generator" do
      random = Random.new
      random.should_receive(:rand).exactly(2).and_return(1, 0)
      [2, 3].shuffle(:random => random).should == [3, 2]
    end
  end
end

describe "Array#shuffle!" do
  ruby_version_is "1.8.7" do
    it "returns the same values, in a usually different order" do
      a = [1, 2, 3, 4]
      original = a
      different = false
      10.times do
        a = a.shuffle!
        a.sort.should == [1, 2, 3, 4]
        different ||= (a != [1, 2, 3, 4])
      end
      different.should be_true # Will fail once in a blue moon (4!^10)
      a.should equal(original)
    end

    ruby_version_is ""..."1.9" do
      it "raises a TypeError on a frozen array" do
        lambda { ArraySpecs.frozen_array.shuffle! }.should raise_error(TypeError)
        lambda { ArraySpecs.empty_frozen_array.shuffle! }.should raise_error(TypeError)
      end
    end

    ruby_version_is "1.9" do
      it "raises a RuntimeError on a frozen array" do
        lambda { ArraySpecs.frozen_array.shuffle! }.should raise_error(RuntimeError)
        lambda { ArraySpecs.empty_frozen_array.shuffle! }.should raise_error(RuntimeError)
      end
    end
  end
end
