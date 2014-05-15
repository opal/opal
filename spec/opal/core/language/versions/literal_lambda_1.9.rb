require File.join(File.dirname(__FILE__), '../fixtures/literal_lambda')

describe "->(){}" do
  it "can be specified as a literal" do
    expect { ->(){} }.not_to raise_error
  end

  it "returns a Proc object" do
    expect(){}.to be_an_instance_of(Proc)
  end

  it "returns a lambda" do
    expect(->(){}.lambda?).to be_true
  end

  it "can be assigned to a variable" do
    var = ->(){}
    expect(var.lambda?).to be_true
  end

  it "understands a do/end block in place of {}" do
    expect do
      ->() do
      end
    end.not_to raise_error
  end

  it "requires an associated block" do
    expect { eval "->()" }.to raise_error(SyntaxError)
    expect { eval "->" }.to raise_error(SyntaxError)
  end

  it "can be interpolated into a String" do
    expect("1+2=#{->{ 1 + 2}.call}").to eq("1+2=3")
  end

  it "can be be used as a Hash key" do
    h = new_hash
    # h[->(one=1){ one + 2}.call] = :value
    expect(h.key?(3)).to be_true
  end

  it "can be used in method parameter lists" do
    def glark7654(a=-> { :foo   })
      a.call
    end
    expect(glark7654).to eq(:foo)
  end

  it "accepts an parameter list between the parenthesis" do
    expect { ->(a) {} }.not_to raise_error
    expect { ->(a,b) {} }.not_to raise_error
  end

  it "accepts an empty parameter list" do
    expect { ->() {} }.not_to raise_error
  end

  it "allows the parenthesis to be omitted entirely" do
    expect { -> {} }.not_to raise_error
    expect { ->{} }.not_to raise_error
    expect do
      -> do
      end
    end.not_to raise_error
    expect{}.to be_an_instance_of(Proc)
  end

  it "aliases each argument to the corresponding parameter" do
    expect(->(a) {a}.call(:sym)).to eq(:sym)
    expect(->(a,b) {[a, b]}.call(:sym, :bol)).to eq([:sym, :bol])
  end

  it "accepts parameters with default parameters between the parenthesis" do
    # lambda { ->(a=1) {} }.should_not raise_error(SyntaxError)
    # lambda { ->(x=1, b=[]) {} }.should_not raise_error(SyntaxError)
  end

  it "aliases each argument with a default value to the corresponding parameter" do
    # ->(a=:cymbal) {a}.call(:sym).should == :sym
    # ->(a,b=:cymbal) {[a, b]}.call(:sym, :bol).should == [:sym, :bol]
  end

  it "sets arguments to their default value if one wasn't supplied" do
    # ->(a=:cymbal) {a}.call.should == :cymbal
    # ->(a,b=:cymbal) {[a, b]}.call(:sym).should == [:sym, :cymbal]
  end

  it "accepts a parameter prefixed with an asterisk between the parenthesis" do
    # lambda { ->(*a) {} }.should_not raise_error(SyntaxError)
    # lambda { ->(x, *a) {} }.should_not raise_error(SyntaxError)
  end

  it "assigns all remaining arguments to the variable in the parameter list prefixed with an asterisk, if one exists" do
    # ->(*a) {a}.call(:per, :cus, :si, :on).should == [:per, :cus, :si, :on]
    # ->(a,*b) {b}.call(:per, :cus, :si, :on).should == [:cus, :si, :on]
  end

  it "accepts a parameter prefixed with an ampersand between the parenthesis" do
    # lambda { ->(&a) {} }.should_not raise_error(SyntaxError)
    # lambda { ->(x, &a) {} }.should_not raise_error(SyntaxError)
  end

  it "assigns the given block to the parameter prefixed with an ampersand if such a parameter exists" do
    # l = ->(&a) { a }.call { :foo }
    expect(l.call).to eq(:foo)
  end

  it "assigns nil to the parameter prefixed with an ampersand unless a block was supplied" do
    # ->(&a) { a }.call.should be_nil
  end

  it "accepts a combination of argument types between the parenthesis" do
    # lambda { ->(x, y={}, z  = Object.new, *a, &b) {} }.
      should_not raise_error
  end

  it "sets parameters appropriately when a combination of parameter types is given between the parenthesis" do
    # l = ->(x, y={}, z  = Object.new, *a, &b) { [x,y,z,a,b]}
    expect(l.call(1, [], [], 30, 40)).to eq([1, [], [], [30, 40], nil])
    block = lambda { :lamb }
    expect(l.call(1, [], [], 30, 40, &block).last).to be_an_instance_of(Proc)
    # l2 = ->(x, y={}, *a) { [x, y, a]}
    expect(l2.call(:x)).to eq([:x, {}, []])
  end

  it "uses lambda's 'rigid' argument handling" do
    expect(->(a, b){}.parameters.first.first).to eq(:req)
    expect(->(a, b){}.parameters.last.first).to eq(:req)
    expect { ->(a, b){}.call 1 }.to raise_error(ArgumentError)
  end

  it "does not call the associated block" do
    @called = false
    ->() { @called = true }
    expect(@called).to be_false
  end

  it "evaluates constants as normal blocks do" do
    l = LiteralLambdaMethods.literal_lambda_with_constant
    expect(l.()).to eq("some value")
  end
end
