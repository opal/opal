require File.expand_path('../../../spec_helper', __FILE__)

describe "Range#inspect" do
  it "provides a printable form, using #inspect to convert the start and end objects" do
    ('A'..'Z').inspect.should == '"A".."Z"'
    ('A'...'Z').inspect.should == '"A"..."Z"'

    (0..21).inspect.should == "0..21"
    (-8..0).inspect.should == "-8..0"
    (-411..959).inspect.should == "-411..959"
    (0.5..2.4).inspect.should == "0.5..2.4"
  end
end

