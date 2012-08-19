describe "NilClass#to_json" do
  it "returns 'null'" do
    nil.to_json.should == "null"
  end
end