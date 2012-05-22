describe "Hash#values" do
  it "returns an array of values" do
    h = {1 => :a, 'a' => :a, 'the' => 'lang'}
    h.values.should be_kind_of(Array)
    h.values.should == [:a, :a, 'lang']
  end
end