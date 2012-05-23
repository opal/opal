describe "Kernel#tap" do
  it "always yields self and returns self" do
    a = Object.new
    a.tap {|o| o.should equal(a); 42}.should equal(a)
  end

  it "raises a LocalJumpError when no block given" do
    lambda { 3.tap }.should raise_error(LocalJumpError)
  end
end