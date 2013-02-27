require File.join(File.dirname(__FILE__), '../fixtures/literal_lambda')

describe "->(){}" do
  pending "can be specified as a literal" do
    lambda { ->(){} }.should_not raise_error
  end

  pending "returns a Proc object" do
    ->(){}.should be_an_instance_of(Proc)
  end

  it "returns a lambda" do
    ->(){}.lambda?.should be_true
  end

  it "can be assigned to a variable" do
    var = ->(){}
    var.lambda?.should be_true
  end

  pending "understands a do/end block in place of {}" do
    lambda do
      ->() do
      end
    end.should_not raise_error(SyntaxError)
  end

  pending "requires an associated block" do
    lambda { eval "->()" }.should raise_error(SyntaxError)
    lambda { eval "->" }.should raise_error(SyntaxError)
  end

  it "can be interpolated into a String" do
    "1+2=#{->{ 1 + 2}.call}".should == "1+2=3"
  end

  pending "can be be used as a Hash key" do
    h = new_hash
    # h[->(one=1){ one + 2}.call] = :value
    h.key?(3).should be_true
  end

  it "can be used in method parameter lists" do
    def glark7654(a=-> { :foo   })
      a.call
    end
    glark7654.should == :foo
  end

  pending "accepts an parameter list between the parenthesis" do
    lambda { ->(a) {} }.should_not raise_error(SyntaxError)
    lambda { ->(a,b) {} }.should_not raise_error(SyntaxError)
  end

  pending "accepts an empty parameter list" do
    lambda { ->() {} }.should_not raise_error(SyntaxError)
  end

  pending "allows the parenthesis to be omitted entirely" do
    lambda { -> {} }.should_not raise_error(SyntaxError)
    lambda { ->{} }.should_not raise_error(SyntaxError)
    lambda do
      -> do
      end
    end.should_not raise_error(SyntaxError)
    ->{}.should be_an_instance_of(Proc)
  end

  it "aliases each argument to the corresponding parameter" do
    ->(a) {a}.call(:sym).should == :sym
    ->(a,b) {[a, b]}.call(:sym, :bol).should == [:sym, :bol]
  end

  pending "accepts parameters with default parameters between the parenthesis" do
    # lambda { ->(a=1) {} }.should_not raise_error(SyntaxError)
    # lambda { ->(x=1, b=[]) {} }.should_not raise_error(SyntaxError)
  end

  pending "aliases each argument with a default value to the corresponding parameter" do
    # ->(a=:cymbal) {a}.call(:sym).should == :sym
    # ->(a,b=:cymbal) {[a, b]}.call(:sym, :bol).should == [:sym, :bol]
  end

  pending "sets arguments to their default value if one wasn't supplied" do
    # ->(a=:cymbal) {a}.call.should == :cymbal
    # ->(a,b=:cymbal) {[a, b]}.call(:sym).should == [:sym, :cymbal]
  end

  pending "accepts a parameter prefixed with an asterisk between the parenthesis" do
    # lambda { ->(*a) {} }.should_not raise_error(SyntaxError)
    # lambda { ->(x, *a) {} }.should_not raise_error(SyntaxError)
  end

  pending "assigns all remaining arguments to the variable in the parameter list prefixed with an asterisk, if one exists" do
    # ->(*a) {a}.call(:per, :cus, :si, :on).should == [:per, :cus, :si, :on]
    # ->(a,*b) {b}.call(:per, :cus, :si, :on).should == [:cus, :si, :on]
  end

  pending "accepts a parameter prefixed with an ampersand between the parenthesis" do
    # lambda { ->(&a) {} }.should_not raise_error(SyntaxError)
    # lambda { ->(x, &a) {} }.should_not raise_error(SyntaxError)
  end

  pending "assigns the given block to the parameter prefixed with an ampersand if such a parameter exists" do
    # l = ->(&a) { a }.call { :foo }
    l.call.should == :foo
  end

  pending "assigns nil to the parameter prefixed with an ampersand unless a block was supplied" do
    # ->(&a) { a }.call.should be_nil
  end

  pending "accepts a combination of argument types between the parenthesis" do
    # lambda { ->(x, y={}, z  = Object.new, *a, &b) {} }.
      should_not raise_error(SyntaxError)
  end

  pending "sets parameters appropriately when a combination of parameter types is given between the parenthesis" do
    # l = ->(x, y={}, z  = Object.new, *a, &b) { [x,y,z,a,b]}
    l.call(1, [], [], 30, 40).should == [1, [], [], [30, 40], nil]
    block = lambda { :lamb }
    l.call(1, [], [], 30, 40, &block).last.should be_an_instance_of(Proc)
    # l2 = ->(x, y={}, *a) { [x, y, a]}
    l2.call(:x).should == [:x, {}, []]
  end

  pending "uses lambda's 'rigid' argument handling" do
    ->(a, b){}.parameters.first.first.should == :req
    ->(a, b){}.parameters.last.first.should == :req
    lambda { ->(a, b){}.call 1 }.should raise_error(ArgumentError)
  end

  it "does not call the associated block" do
    @called = false
    ->() { @called = true }
    @called.should be_false
  end

  it "evaluates constants as normal blocks do" do
    l = LiteralLambdaMethods.literal_lambda_with_constant
    l.().should == "some value"
  end
end
