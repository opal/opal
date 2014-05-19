describe "Kernel#=~" do
  it "should return false" do
    expect(Object.new =~ 'abc').to be_false
  end
end