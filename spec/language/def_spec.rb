
describe "Redefining a method" do
  
  it "replaces the original method" do
    def barFoo; 100; end
    barFoo.should == 100
    
    def barFoo; 200; end
    barFoo.should == 200
  end
end

describe "A singleton method definition" do
  it "can be declared for a local variable" do
    a = Object.new
    def a.foo
      5
    end
    a.foo.should == 5
  end
end
