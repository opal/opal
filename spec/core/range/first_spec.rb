require File.expand_path('../../../spec_helper', __FILE__)

describe "Range#first" do
  it "returns the first element of self" do
    (-1..1).first.should == -1
    (0..1).first.should == 0
    ('Q'..'T').first.should == 'Q'
    ('Q'...'T').first.should == 'Q'
    (0.5..2.4).first.should == 0.5
  end
end

