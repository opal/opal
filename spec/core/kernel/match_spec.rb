describe "Kernel#=~" do
  it "should return false" do
    (Object.new =~ 'abc').should be_false
  end
end