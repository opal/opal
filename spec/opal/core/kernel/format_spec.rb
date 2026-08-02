describe "Kernel#format" do
  # https://github.com/opal/opal/issues/2758
  it "keeps the literal text preceding a %% escape" do
    format("foo %% %d", 100).should == "foo % 100"
    format("foo %%").should == "foo %"
    format("a%%b%%c").should == "a%b%c"
    format("%%%%").should == "%%"
    format("a%%%%%%b%dc", 3).should == "a%%%b3c"
  end
end
