describe "empty __END__ section without trailing newline" do
  it "returns an empty string" do
    DATA.read.should == ""
  end
end

__END__