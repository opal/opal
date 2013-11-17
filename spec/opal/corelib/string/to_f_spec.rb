describe "String#to_f" do
  it "treats leading characters of self as a floating point number" do
    "45.67 degress".to_f.should == 45.67
    "0".to_f.should == 0.0

    ".5".to_f.should == 0.5
    "5e".to_f.should == 5.0
    "5E".to_f.should == 5.0
  end

  it "treats special float value strings as characters" do
    "NaN".to_f.should == 0
  end
end