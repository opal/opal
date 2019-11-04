describe "Struct#dup" do
  it "should return another struct instance" do
    klass = Struct.new("Klass", :foo)
    a = klass.new(1)
    b = a.dup
    b.foo = 2

    a.foo.should == 1
    b.foo.should == 2
  end
end
