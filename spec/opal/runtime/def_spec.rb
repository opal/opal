def def_test_bar
  42
end

def self.def_test_foo
  "bar"
end

$top_level_object = self

describe "Defining top level methods" do
  it "should work with def self.x" do
    $top_level_object.def_test_foo.should == "bar"
  end

  it "should work with def x" do
    $top_level_object.def_test_bar.should == 42
  end

  it "defines methods on singleton class" do
    Object.new.respond_to?(:def_test_bar).should == false
  end
end