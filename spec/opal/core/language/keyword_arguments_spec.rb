describe "Keyword arguments" do
  it 'works with keys that are reserved words in JS' do
    o = Object.new
    def o.foo(default:)
      default
    end
    o.foo(default: :bar).should == :bar
  end
end

describe "A double splat of nil" do
  it "passes no keywords to a method accepting them" do
    def kwnil_keywords(**kw)
      kw
    end

    kwnil_keywords(**nil).should == {}
  end

  # A method taking no arguments at all still sees one under an arity check,
  # because an empty double splat is passed rather than dropped. That is the
  # separate, wider issue #1872, which needs the compiler to tell `f(**x)`
  # apart from `f({**x})`.

  it "splats nothing into a hash literal" do
    { **nil }.should == {}
    { **nil, a: 1 }.should == { a: 1 }
  end

  it "still raises a TypeError for a non-nil value that is not a Hash" do
    -> { { **5 } }.should raise_error(TypeError)
  end
end
