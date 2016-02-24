require 'support/parser_helpers'

describe "Lambda literals" do
  it "should parse with either do/end construct or curly braces" do
    parsed("-> {}").first.should == :call
    parsed("-> do; end").first.should == :call
  end

  it "should parse as a call to 'lambda' with the lambda body as a block" do
    parsed("-> {}").should == [:call, nil, :lambda, [:arglist], [:iter, nil]]
  end

  def parsed_args(source)
    parsed(source)[4][1][1]
  end

  describe "with no args" do
    it "should accept no args" do
      parsed("-> {}")[4][1].should == nil
    end
  end

  describe "with normal args" do
    it "adds a single s(:masgn) for 1 norm arg" do
      parsed("->(a) {}")[4][1].should == [:masgn, [:args, [:arg, :a]]]
    end

    it "lists multiple norm args inside a s(:masgn)" do
      parsed("-> (a, b) {}")[4][1].should == [:masgn, [:args, [:arg, :a], [:arg, :b]]]
      parsed("-> (a, b, c) {}")[4][1].should == [:masgn, [:args, [:arg, :a], [:arg, :b], [:arg, :c]]]
    end
  end

  describe "with optional braces" do
    it "parses normal args" do
      parsed("-> a {}")[4][1].should == [:masgn, [:args, [:arg, :a]]]
      parsed("-> a, b {}")[4][1].should == [:masgn, [:args, [:arg, :a], [:arg, :b]]]
    end

    it "parses splat args" do
      parsed("-> *a {}")[4][1].should == [:masgn, [:args, [:restarg, :a]]]
      parsed("-> a, *b {}")[4][1].should == [:masgn, [:args, [:arg, :a], [:restarg, :b]]]
    end

    it "parses opt args" do
      parsed("-> a = 1 {}")[4][1].should == [:masgn, [:args, [:optarg, :a, [:int, 1]]]]
      parsed("-> a = 1, b = 2 {}")[4][1].should == [:masgn, [:args, [:optarg, :a, [:int, 1]], [:optarg, :b, [:int, 2]]]]
    end

    it "parses block args" do
      parsed("-> &a {}")[4][1].should == [:masgn, [:args, [:block_pass, [:lasgn, :a]]]]
    end
  end

  describe "with body statements" do
    it "should be nil when no statements given" do
      parsed("-> {}")[4][2].should == nil
    end

    it "should be the single sexp when given one statement" do
      parsed("-> { 42 }")[4][2].should == [:int, 42]
    end

    it "should wrap multiple statements into a s(:block)" do
      parsed("-> { 42; 3.142 }")[4][2].should == [:block, [:int, 42], [:float, 3.142]]
    end
  end

  it "can parse do..end blocks inside lambda body" do
    # regression test; see GH issue 544
    call_b   = [:call, nil, :b, [:arglist], [:iter, [:masgn, [:args, [:arg, :c]]]]]
    lambda   = [:call, nil, :lambda, [:arglist], [:iter, nil, call_b]]
    expected = [:call, nil, :a, [:arglist, lambda]]
    parsed("a -> { b do |c| end }").should == expected
  end

  it "can parse do..end after lambda body" do
    # regression test; see GH issue 1228
    expected = [:call, nil, :a, [:arglist, [:call, nil, :lambda, [:arglist], [:iter, nil, [:call, nil, :b, [:arglist]]]]], [:iter, nil]]
    parsed("a ->{b} do; end").should == expected
  end

  context "kwargs as arguments" do
    def s_kwarg
      [:kwarg, :kw]
    end

    def s_kwoptarg
      [:kwoptarg, :kwopt, [:sym, :default]]
    end

    def s_kwrestarg
      [:kwrestarg, :kwrest]
    end

    def s_block
      [:block_pass, [:lasgn, :blk]]
    end

    it "parses kwarg" do
      parsed_args("->(kw:){}").should == [:args, s_kwarg]
    end

    it "parses kwoptarg" do
      parsed_args("->(kwopt: :default){}").should == [:args, s_kwoptarg]
    end

    it "parses kwrestarg" do
      parsed_args("->(**kwrest){}").should == [:args, s_kwrestarg]
    end

    it "parses kwarg + kwoptarg" do
      parsed_args("->(kw:,kwopt: :default){}").should == [:args, s_kwarg, s_kwoptarg]
    end

    it "parses kwarg + kwrestarg" do
      parsed_args("->(kw:,**kwrest){}").should == [:args, s_kwarg, s_kwrestarg]
    end

    it "parses kwarg + kwoptarg + kwrestarg" do
      parsed_args("->(kw:,kwopt: :default,**kwrest){}").should == [:args, s_kwarg, s_kwoptarg, s_kwrestarg]
    end

    it "parses block + kwarg" do
      parsed_args("->(kw:,&blk){}").should == [:args, s_kwarg, s_block]
    end

    it "parses block + kwoptarg" do
      parsed_args("->(kwopt: :default,&blk){}").should == [:args, s_kwoptarg, s_block]
    end

    it "parses block + kwrestarg" do
      parsed_args("->(**kwrest,&blk){}").should == [:args, s_kwrestarg, s_block]
    end
  end

  context 'rest args' do
    it "parses ->(*a,b)" do
      parsed_args("->(*a, b){}").should == [:args, [:restarg, :a], [:arg, :b]]
    end

    it "parses ->(a,b=1,*c,d,&blk)" do
      expected = [:args, [:arg, :a], [:optarg, :b, [:int, 1]], [:restarg, :c], [:arg, :d], [:block_pass, [:lasgn, :blk]]]
      parsed_args("->(a,b=1,*c,d,&blk){}").should == expected
    end

    it "parses ->(a,b=1,c,&blk)" do
      expected = [:args, [:arg, :a], [:optarg, :b, [:int, 1]], [:arg, :c], [:block_pass, [:lasgn, :blk]]]
      parsed_args("->(a,b=1,c,&blk){}").should == expected
    end

    it "parses ->(a,*b,c,&blk){}" do
      expected = [:args, [:arg, :a], [:restarg, :b], [:arg, :c], [:block_pass, [:lasgn, :blk]]]
      parsed_args("->(a,*b,c,&blk){}").should == expected
    end

    it "parses ->(a=1,*b,c,&blk){}" do
      expected = [:args, [:optarg, :a, [:int, 1]], [:restarg, :b], [:arg, :c], [:block_pass, [:lasgn, :blk]]]
      parsed_args("->(a=1,*b,c,&blk){}").should == expected
    end

    it "parses ->(a=1,b,&blk)" do
      expected = [:args, [:optarg, :a, [:int, 1]], [:arg, :b], [:block_pass, [:lasgn, :blk]]]
      parsed_args("->(a=1,b,&blk){}").should == expected
    end
  end
end
