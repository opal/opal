describe "characters support of the DATA contstant" do
  it "supports all characters" do
    DATA.read.should == "azAZ09`~!@#$%^&*(\n)_+{}\\|;:'\",<.>/?\n"
  end
end

__END__
azAZ09`~!@#$%^&*(
)_+{}\|;:'",<.>/?
