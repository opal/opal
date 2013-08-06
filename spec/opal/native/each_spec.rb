describe "Native#each" do
  it "enumerates on object properties" do
    Native(`{ a: 2, b: 3 }`).each {|name, value|
      ((name == :a && value == 2) || (name == :b && value == 3)).should be_true
    }
  end

  it "returns an enumerator when no block is given" do
    enum = Native(`{ a: 2, b: 3 }`).each

    enum.should be_kind_of Enumerator
    enum.to_a.should == [[:a, 2], [:b, 3]]
  end
end
