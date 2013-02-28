require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#frozen?" do
  pending "returns true if array is frozen" do
    a = [1, 2, 3]
    a.frozen?.should == false
    a.freeze
    a.frozen?.should == true
  end

  pending do
  not_compliant_on :rubinius do
    ruby_version_is "" .. "1.9" do
      it "returns true for an array being sorted by #sort!" do
        a = [1, 2, 3]
        a.sort! { |x,y| a.frozen?.should == true; x <=> y }
      end
    end

    ruby_version_is "1.9" do
      it "returns false for an array being sorted by #sort!" do
        a = [1, 2, 3]
        a.sort! { |x,y| a.frozen?.should == false; x <=> y }
      end
    end

    it "returns false for an array being sorted by #sort" do
      a = [1, 2, 3]
      a.sort { |x,y| a.frozen?.should == false; x <=> y }
    end
  end
  end
end
