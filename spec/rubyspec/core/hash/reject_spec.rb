describe "Hash#reject" do
  it "returns a new hash removing keys for which the block yields true" do
    h = {1=>false, 2=>true, 3=>false, 4=>true}
    h.reject { |k,v| v }.keys.should == [1,3]
  end

  it "is equivalent to hsh.dup.delete_if" do
    h = {:a => 'a', :b => 'b', :c => 'd'}
    h.reject { |k,v| k == 'd' }.should == (h.dup.delete_if { |k, v| k == 'd' })

    all_args_reject = []
    all_args_delete_if = []
    h = {1 => 2, 3 => 4}
    h.reject { |*args| all_args_reject << args }
    h.delete_if { |*args| all_args_delete_if << args }
    all_args_reject.should == all_args_delete_if
  end
end