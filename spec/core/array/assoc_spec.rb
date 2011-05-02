
describe "Array#assoc" do
  it "returns the first array whose 1st item is == obj or nil" do
    s1 = ["colors", "red", "blue", "green"]
    s2 = [:letters, "a", "b", "c"]
    s3 = [4]
    s4 = ["colors", "cyan", "yellow", "magenda"]
    s5 = [:letters, "a", "i", "u"]
    s_nil = [nil, nil]
    a = [s1, s2, s3, s4, s5, s_nil]
    a.assoc(s1.first).should == s1
    a.assoc(s2.first).should == s2
    a.assoc(s3.first).should == s3
    a.assoc(s4.first).should == s1
    a.assoc(s5.first).should == s2
    a.assoc(s_nil.first).should == s_nil
    a.assoc(4).should == s3
    a.assoc("key not in array").should == nil
  end
  
  it "ignores any non-Array elements" do
    [1, 2, 3].assoc(2).should == nil
    s1 = [4]
    s2 = [5, 4, 3]
    a = ["foo", [], s1, s2, nil, []]
    a.assoc(s1.first).should == s1
    a.assoc(s2.first).should == s2
  end
end
