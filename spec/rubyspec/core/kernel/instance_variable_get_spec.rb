describe "Kernel#instance_variable_get" do
  before(:each) do
    @obj = Object.new
    @obj.instance_variable_set("@test", :test)
  end

  it "returns nil when the referred instance variable does not exist" do
    @obj.instance_variable_get(:@does_not_exist).should be_nil
  end

  it "returns the value of the passed instance variable" do
    @obj.instance_variable_get(:@test).should == :test
  end
end