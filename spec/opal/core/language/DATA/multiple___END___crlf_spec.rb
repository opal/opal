describe "DATA constant with multiple __END__ sections" do
  it "returns everything after first __END__" do
    DATA.read.should == "1\r\n__END__\r\n2\r\n"
  end
end

__END__
1
__END__
2
