describe "Symbol#to_proc" do
  it "returns a new Proc" do
    proc = :to_s.to_proc
    proc.should be_kind_of(Proc)
  end

  it "sends self to arguments passed when calling #call on the proc" do
    obj = Object.new
    def obj.to_s; "Received #to_s"; end
    :to_s.to_proc.call(obj).should == "Received #to_s"
  end
end