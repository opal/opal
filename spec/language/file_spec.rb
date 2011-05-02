require File.expand_path('../../spec_helper', __FILE__)

# specs for __FILE__

describe "The __FILE__ constant" do
  it "equals the current filename" do
    File.basename(__FILE__).should == "file_spec.rb"
  end
  
  it "equals (eval) inside an eval" do
    # eval("__FILE__").should == "(eval)"
  end
end
