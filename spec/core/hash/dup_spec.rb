describe "Hash#dup" do
  it "copies instance variable but not the objects they refer to" do
    hash = {'key' => 'value'}

    clone = hash.dup

    clone.should == hash
    clone.object_id.should_not == hash.object_id
  end
end