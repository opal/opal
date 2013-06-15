describe "Kernel#to_json" do
  it "returns an escaped #to_s of the receiver" do
    self.to_json.should be_kind_of(String)
  end
end