describe "Keyword arguments" do
  def m a, b = nil, c: 123
    [a, b, c]
  end

  it "def method_a(b, c=nil, d:nil)" do
    m(1,2,c: 3).should == [1, 2, 3]
    m(1, c: 3).should == [1, nil, 3]
    m(1).should == [1, nil, 123]
  end
end
