
describe "File.join" do
  it "returns an empty string when given no arguments" do
    File.join.should == ""
  end
  
  it "when given a single argument returns an equal string" do
    # File.join("").should == ""
    File.join("usr").should == "usr"
  end
  
  it "joins parts using File::SEPARATOR" do
    File.join('usr', 'bin').should == 'usr/bin'
  end
  
  it "supports any number of arguments" do
    File.join("a", "b", "c", "d").should == "a/b/c/d"
  end
end