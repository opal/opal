describe "Native#each" do
  it "enumerates on object properties" do
    Native(`{ a: 2, b: 3 }`).each {|name, value|
      ((name == :a && value == 2) || (name == :b && value == 3)).should be_true
    }
  end

  it "accesses the native when no block is given" do
    Native(`{ a: 2, b: 3, each: function() { return 42; } }`).each.should == 42
  end
end
