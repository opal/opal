describe "Symbol#to_proc" do
  it "returns a new Proc" do
    proc = :to_s.to_proc
    proc.should be_kind_of(Proc)
  end
end