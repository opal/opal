describe "Hash#select" do
  before(:each) do
    @hsh = {1 => 2, 3 => 4, 5 => 6}
    @empty = {}
  end

  it "yields two arguments: key and value" do
    all_args = []
    {1 => 2, 3 => 4}.select { |*args| all_args << args }
    all_args.should == [[1, 2], [3, 4]]
  end

  it "returns a Hash of entries for which block is true" do
    a_pairs = {'a' => 9, 'c' => 4, 'b' => 5, 'd' => 2}.select { |k,v| v % 2 == 0 }
    a_pairs.should be_kind_of(Hash)
    a_pairs.should == {'c' => 4, 'd' => 2}
  end

  it "processes entries with the same order as reject" do
    h = {:a => 9, :c => 4, :b => 5, :d => 2}

    select_pairs = []
    reject_pairs = []
    h.select { |*pair| select_pairs << pair }
    h.reject { |*pair| reject_pairs << pair }

    select_pairs.should == reject_pairs
  end
end

describe "Hash#select!" do
  before(:each) do
    @hsh = {1 => 2, 3 => 4, 5 => 6}
    @empty = {}
  end

  it "is equivalent to keep_if if changes are made" do
    {:a => 2}.select! { |k,v| v <= 1 }.should ==
      {:a => 2}.keep_if { |k, v| v <= 1 }

    h = {1 => 2, 3 => 4}
    all_args_select = []
    all_args_keep_if = []
    h.dup.select! { |*args| all_args_select << args }
    h.dup.keep_if { |*args| all_args_keep_if << args }
    all_args_select.should == all_args_keep_if
  end

  it "returns nil if no changes were made" do
    {:a => 1}.select! { |k,v| v <= 1 }.should == nil
  end
end