describe "DATA constant with multiple __END__ sections" do
  it "returns everything after first __END__" do
    DATA.read.should == "1\n__END__\n2\n"
  end
end

__END__
1
__END__
2
