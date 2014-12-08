describe "Kernel.rand" do
  it "returns a float if no argument is passed" do
    rand.should be_kind_of(Float)
  end

  it "returns an integer for an integer argument" do
    rand(77).should be_kind_of(Integer)
  end

  it "return member from range" do
    r = (1..10)
    r.to_a.include?(rand(r)).should == true
  end

  # this is wrong, so commenting out. see https://github.com/rubyspec/rubyspec/blob/master/core/kernel/rand_spec.rb 
  # it "should convert negative number and convert to integer" do
  #   rand(-0.1).should == 0
  # end

  it "returns a numeric in opal" do
    rand.should be_kind_of(Numeric)
    rand(77).should be_kind_of(Numeric)
  end
end
