describe "Ruby string interpolation" do
  it "uses an internal representation when #to_s doesn't return a String" do
    obj = Object.new
    def obj.to_s
      BasicObject.new
    end

    str = "#{obj}"
    str.should be_an_instance_of(String)
    str.should =~ /\A#<Object:0x[0-9a-fA-F]+>\z/
  end

  it "uses Ruby's to_s rather than JavaScript's toString" do
    # Array.prototype.toString returns "1,2"
    "#{[1, 2]}".should == "[1, 2]"
    # Function.prototype.toString returns its source code
    "#{-> {}}".should =~ /\A#<Proc:0x[0-9a-fA-F]+>\z/
  end
end
