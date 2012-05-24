describe "->(){}" do
  it "can be specified as a literal" do
    lambda { ->(){} }.call
  end

  it "returns a Proc object" do
    ->(){}.should be_kind_of(Proc)
  end

  it "returns a lambda" do
    ->(){}.lambda?.should be_true
  end

  it "can be assigned to a variable" do
    var = ->(){}
    var.lambda?.should be_true
  end

  it "understands a do/end block in place of {}" do
    lambda do
      ->() do
      end
    end.call
  end

  it "can be interpolated into a String" do
    "1+2=#{->{ 1 + 2 }.call}".should == "1+2=3"
  end

  it "can be used as a Hash key" do
    h = {}
    h[->(){ 1 + 2 }.call] = :value
    h.key?(3).should be_true
  end

  it "can be used in method parameter lists" do
    def glark7654(a=-> { :foo })
      a.call
    end
    glark7654.should == :foo
  end

  it "accepts an paramter list between the paranthesis" do
    lambda { ->(a) {} }.call
    lambda { ->(a,b) {} }.call
  end
end