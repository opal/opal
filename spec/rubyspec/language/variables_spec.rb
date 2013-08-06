require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/variables', __FILE__)

# TODO: partition these specs into distinct cases based on the
# real parsed forms, not the superficial code forms.
describe "Basic assignment" do
  it "allows the rhs to be assigned to the lhs" do
    a = nil
    a.should == nil
  end

  it "assigns nil to lhs when rhs is an empty expression" do
    a = ()
    a.should be_nil
  end

  ruby_version_is "" ... "1.9" do
    it "assigns nil to lhs when rhs is an empty splat expression" do
      a = *()
      a.should be_nil
    end
  end

  ruby_version_is "1.9" do
    it "assigns [] to lhs when rhs is an empty splat expression" do
      a = *()
      a.should == []
    end
  end

  ruby_version_is "" ... "1.9" do
    it "allows the assignment of the rhs to the lhs using the rhs splat operator" do
      a = *nil;      a.should == nil
      a = *1;        a.should == 1
      a = *[];       a.should == nil
      a = *[1];      a.should == 1
      a = *[nil];    a.should == nil
      a = *[[]];     a.should == []
      a = *[1,2];    a.should == [1,2]
    end
  end

  ruby_version_is "1.9" do
    pending "allows the assignment of the rhs to the lhs using the rhs splat operator" do
      a = *nil;      a.should == []
      a = *1;        a.should == [1]
      a = *[];       a.should == []
      a = *[1];      a.should == [1]
      a = *[nil];    a.should == [nil]
      a = *[[]];     a.should == [[]]
      a = *[1,2];    a.should == [1,2]
    end
  end

  ruby_version_is "" ... "1.9" do
    it "allows the assignment of the rhs to the lhs using the lhs splat operator" do
      # * = 1,2        # Valid syntax, but pretty useless! Nothing to test
      *a = nil;      a.should == [nil]
      *a = 1;        a.should == [1]
      *a = [];       a.should == [[]]
      *a = [1];      a.should == [[1]]
      *a = [1,2];    a.should == [[1,2]]
    end
  end

  ruby_version_is "1.9" do
    pending "allows the assignment of the rhs to the lhs using the lhs splat operator" do
      # * = 1,2        # Valid syntax, but pretty useless! Nothing to test
      *a = nil;      a.should == [nil]
      *a = 1;        a.should == [1]
      *a = [];       a.should == []
      *a = [1];      a.should == [1]
      *a = [1,2];    a.should == [1,2]
    end
  end

  ruby_version_is "" ... "1.9" do
    it "allows the assignment of rhs to the lhs using the lhs and rhs splat operators simultaneously" do
      *a = *nil;      a.should == [nil]
      *a = *1;        a.should == [1]
      *a = *[];       a.should == []
      *a = *[1];      a.should == [1]
      *a = *[nil];    a.should == [nil]
      *a = *[1,2];    a.should == [1,2]
    end
  end

  ruby_version_is "1.9" do
    pending "allows the assignment of rhs to the lhs using the lhs and rhs splat operators simultaneously" do
      *a = *nil;      a.should == []
      *a = *1;        a.should == [1]
      *a = *[];       a.should == []
      *a = *[1];      a.should == [1]
      *a = *[nil];    a.should == [nil]
      *a = *[1,2];    a.should == [1,2]
    end
  end

  it "sets unavailable values to nil" do
    ary = []
    a, b, c = ary

    a.should be_nil
    b.should be_nil
    c.should be_nil
  end

  it "sets the splat to an empty Array if there are no more values" do
    ary = []
    a, b, *c = ary

    a.should be_nil
    b.should be_nil
    c.should == []
  end

  it "allows multiple values to be assigned" do
    a,b,*c = nil;       [a,b,c].should == [nil, nil, []]
    a,b,*c = 1;         [a,b,c].should == [1, nil, []]
    a,b,*c = [];        [a,b,c].should == [nil, nil, []]
    a,b,*c = [1];       [a,b,c].should == [1, nil, []]
    a,b,*c = [nil];     [a,b,c].should == [nil, nil, []]
    a,b,*c = [[]];      [a,b,c].should == [[], nil, []]
    a,b,*c = [1,2];     [a,b,c].should == [1,2,[]]

    a,b,*c = *nil;      [a,b,c].should == [nil, nil, []]
    a,b,*c = *1;        [a,b,c].should == [1, nil, []]
    a,b,*c = *[];       [a,b,c].should == [nil, nil, []]
    a,b,*c = *[1];      [a,b,c].should == [1, nil, []]
    a,b,*c = *[nil];    [a,b,c].should == [nil, nil, []]
    a,b,*c = *[[]];     [a,b,c].should == [[], nil, []]
    a,b,*c = *[1,2];    [a,b,c].should == [1,2,[]]
  end

  it "calls to_a on the given argument when using a splat" do
    a,b = *VariablesSpecs::ArrayLike.new([1,2]); [a,b].should == [1,2]
  end

  it "supports the {|r,| } form of block assignment" do
    f = lambda {|r,| r.should == []}
    f.call([], *[])

    f = lambda{|x,| x}
    f.call(42).should == 42
    f.call([42]).should == [42]
    f.call([[42]]).should == [[42]]
    f.call([42,55]).should == [42,55]
  end

  it "allows assignment through lambda" do
    f = lambda {|r,*l| r.should == []; l.should == [1]}
    f.call([], *[1])

    f = lambda{|x| x}
    f.call(42).should == 42
    f.call([42]).should == [42]
    f.call([[42]]).should == [[42]]
    f.call([42,55]).should == [42,55]

    f = lambda{|*x| x}
    f.call(42).should == [42]
    f.call([42]).should == [[42]]
    f.call([[42]]).should == [[[42]]]
    f.call([42,55]).should == [[42,55]]
    f.call(42,55).should == [42,55]
  end

  it "allows chained assignment" do
    (a = 1 + b = 2 + c = 4 + d = 8).should == 15
    d.should == 8
    c.should == 12
    b.should == 14
    a.should == 15
  end
end

describe "Assignment using expansion" do
  ruby_version_is "" ... "1.9" do
    it "succeeds without conversion" do
      *x = (1..7).to_a
      x.should == [[1, 2, 3, 4, 5, 6, 7]]
    end
  end

  ruby_version_is "1.9" do
    it "succeeds without conversion" do
      *x = (1..7).to_a
      x.should == [1, 2, 3, 4, 5, 6, 7]
    end
  end
end

describe "Basic multiple assignment" do
  describe "with a single RHS value" do
    pending "does not call #to_ary on an Array instance" do
      x = [1, 2]
      x.should_not_receive(:to_ary)

      a, b = x
      a.should == 1
      b.should == 2
    end

    pending "does not call #to_a on an Array instance" do
      x = [1, 2]
      x.should_not_receive(:to_a)

      a, b = x
      a.should == 1
      b.should == 2
    end

    pending "does not call #to_ary on an Array subclass instance" do
      x = VariablesSpecs::ArraySubclass.new [1, 2]
      x.should_not_receive(:to_ary)

      a, b = x
      a.should == 1
      b.should == 2
    end

    pending "does not call #to_a on an Array subclass instance" do
      x = VariablesSpecs::ArraySubclass.new [1, 2]
      x.should_not_receive(:to_a)

      a, b = x
      a.should == 1
      b.should == 2
    end

    pending "calls #to_ary on an object" do
      x = mock("single rhs value for masgn")
      x.should_receive(:to_ary).and_return([1, 2])

      a, b = x
      a.should == 1
      b.should == 2
    end

    pending "does not call #to_a on an object if #to_ary is not defined" do
      x = mock("single rhs value for masgn")
      x.should_not_receive(:to_a)

      a, b = x
      a.should == x
      b.should be_nil
    end

    it "does not call #to_a on a String" do
      x = "one\ntwo"

      a, b = x
      a.should == x
      b.should be_nil
    end
  end

  describe "with a splatted single RHS value" do
    pending "does not call #to_ary on an Array instance" do
      x = [1, 2]
      x.should_not_receive(:to_ary)

      a, b = *x
      a.should == 1
      b.should == 2
    end

    pending "does not call #to_a on an Array instance" do
      x = [1, 2]
      x.should_not_receive(:to_a)

      a, b = *x
      a.should == 1
      b.should == 2
    end

    pending "does not call #to_ary on an Array subclass instance" do
      x = VariablesSpecs::ArraySubclass.new [1, 2]
      x.should_not_receive(:to_ary)

      a, b = *x
      a.should == 1
      b.should == 2
    end

    pending "does not call #to_a on an Array subclass instance" do
      x = VariablesSpecs::ArraySubclass.new [1, 2]
      x.should_not_receive(:to_a)

      a, b = *x
      a.should == 1
      b.should == 2
    end

    pending "calls #to_a on an object if #to_ary is not defined" do
      x = mock("single splatted rhs value for masgn")
      x.should_receive(:to_a).and_return([1, 2])

      a, b = *x
      a.should == 1
      b.should == 2
    end

    ruby_version_is ""..."1.9" do
      it "calls #to_ary on an object" do
        x = mock("single splatted rhs value for masgn")
        x.should_receive(:to_ary).and_return([1, 2])

        a, b = *x
        a.should == 1
        b.should == 2
      end

      it "calls #to_a on a String" do
        x = "one\ntwo"

        a, b = *x
        a.should == "one\n"
        b.should == "two"
      end
    end

    ruby_version_is "1.9" do
      pending "does not call #to_ary on an object" do
        x = mock("single splatted rhs value for masgn")
        x.should_not_receive(:to_ary)

        a, b = *x
        a.should == x
        b.should be_nil
      end

      pending "does not call #to_a on a String" do
        x = "one\ntwo"

        a, b = *x
        a.should == x
        b.should be_nil
      end
    end
  end
end

describe "Assigning multiple values" do
  it "allows parallel assignment" do
    a, b = 1, 2
    a.should == 1
    b.should == 2

    # a, = 1,2
    a.should == 1
  end

  it "allows safe parallel swapping" do
    a, b = 1, 2
    a, b = b, a
    a.should == 2
    b.should == 1
  end

  pending do
  not_compliant_on :rubinius do
    pending "returns the rhs values used for assignment as an array" do
      # x = begin; a, b, c = 1, 2, 3; end
      x.should == [1,2,3]
    end
  end
  end

  ruby_version_is "" ... "1.9" do
    it "wraps a single value in an Array" do
      *a = 1
      a.should == [1]

      b = [1]
      *a = b
      a.should == [b]
    end
  end

  ruby_version_is "1.9" do
    it "wraps a single value in an Array if it's not already one" do
      *a = 1
      a.should == [1]

      b = [1]
      *a = b
      a.should == b
    end
  end

  it "evaluates rhs left-to-right" do
    a = VariablesSpecs::ParAsgn.new
    d, e ,f = a.inc, a.inc, a.inc
    d.should == 1
    e.should == 2
    f.should == 3
  end

  it "supports parallel assignment to lhs args via object.method=" do
    a = VariablesSpecs::ParAsgn.new
    a.x, b = 1, 2

    a.x.should == 1
    b.should == 2

    c = VariablesSpecs::ParAsgn.new
    c.x, a.x = a.x, b

    c.x.should == 1
    a.x.should == 2
  end

  it "supports parallel assignment to lhs args using []=" do
    a = [1,2,3]
    a[3], b = 4,5

    a.should == [1,2,3,4]
    b.should == 5
  end

  it "bundles remaining values to an array when using the splat operator" do
    a, *b = 1, 2, 3
    a.should == 1
    b.should == [2, 3]

    *a = 1, 2, 3
    a.should == [1, 2, 3]

    *a = 4
    a.should == [4]

    *a = nil
    a.should == [nil]

    a, = *[1]
    a.should == 1
  end

  ruby_version_is ""..."1.9" do
    it "calls #to_ary on rhs arg if rhs has only a single arg" do
      x = VariablesSpecs::ParAsgn.new
      a,b,c = x
      a.should == 1
      b.should == 2
      c.should == 3

      a,b,c = x,5
      a.should == x
      b.should == 5
      c.should == nil

      a,b,c = 5,x
      a.should == 5
      b.should == x
      c.should == nil

      a,b,*c = x,5
      a.should == x
      b.should == 5
      c.should == []

      # a,(b,c) = 5,x
      a.should == 5
      b.should == 1
      c.should == 2

      # a,(b,*c) = 5,x
      a.should == 5
      b.should == 1
      c.should == [2,3,4]

      # a,(b,(*c)) = 5,x
      a.should == 5
      b.should == 1
      c.should == [2]

      # a,(b,(*c),(*d)) = 5,x
      a.should == 5
      b.should == 1
      c.should == [2]
      d.should == [3]

      # a,(b,(*c),(d,*e)) = 5,x
      a.should == 5
      b.should == 1
      c.should == [2]
      d.should == 3
      e.should == []
    end
  end

  ruby_version_is "1.9" do
    pending "calls #to_ary on RHS arg if the corresponding LHS var is a splat" do
      x = VariablesSpecs::ParAsgn.new

      # a,(*b),c = 5,x
      a.should == 5
      b.should == x.to_ary
      c.should == nil
    end
  end

  ruby_version_is ""..."1.9" do
    it "doen't call #to_ary on RHS arg when the corresponding LHS var is a splat" do
      x = VariablesSpecs::ParAsgn.new

      # a,(*b),c = 5,x
      a.should == 5
      b.should == [x]
      c.should == nil
    end
  end

  pending "allows complex parallel assignment" do
    # a, (b, c), d = 1, [2, 3], 4
    a.should == 1
    b.should == 2
    c.should == 3
    d.should == 4

    # x, (y, z) = 1, 2, 3
    [x,y,z].should == [1,2,nil]
    # x, (y, z) = 1, [2,3]
    [x,y,z].should == [1,2,3]
    # x, (y, z) = 1, [2]
    [x,y,z].should == [1,2,nil]

    # a,(b,c,*d),(e,f),*g = 0,[1,2,3,4],[5,6],7,8
    a.should == 0
    b.should == 1
    c.should == 2
    d.should == [3,4]
    e.should == 5
    f.should == 6
    g.should == [7,8]

    x = VariablesSpecs::ParAsgn.new
    # a,(b,c,*d),(e,f),*g = 0,x,[5,6],7,8
    a.should == 0
    b.should == 1
    c.should == 2
    d.should == [3,4]
    e.should == 5
    f.should == 6
    g.should == [7,8]
  end

  it "allows a lhs arg to be used in another lhs args parallel assignment" do
    c = [4,5,6]
    a,b,c[a] = 1,2,3
    a.should == 1
    b.should == 2
    c.should == [4,3,6]

    c[a],b,a = 7,8,9
    a.should == 9
    b.should == 8
    c.should == [4,7,6]
  end
end

describe "Conditional assignment" do
  it "assigns the lhs if previously unassigned" do
    a=[]
    a[0] ||= "bar"
    a[0].should == "bar"

    h={}
    h["foo"] ||= "bar"
    h["foo"].should == "bar"

    h["foo".to_sym] ||= "bar"
    h["foo".to_sym].should == "bar"

    aa = 5
    aa ||= 25
    aa.should == 5

    bb ||= 25
    bb.should == 25

    cc &&=33
    cc.should == nil

    cc = 5
    cc &&=44
    cc.should == 44
  end

  it "checks for class variable definition before fetching its value" do
    class VariableSpecCVarSpec
      @@cvarspec ||= 5
      @@cvarspec.should == 5
    end
  end
end

describe "Unconditional operator assignment 'var op= expr'" do
  it "is equivalent to 'var = var op expr'" do
    x = 13
    (x += 5).should == 18
    x.should == 18

    x = 17
    (x -= 11).should == 6
    x.should == 6

    x = 2
    (x *= 5).should == 10
    x.should == 10

    x = 36
    (x /= 9).should == 4
    x.should == 4

    x = 23
    (x %= 5).should == 3
    x.should == 3
    (x %= 3).should == 0
    x.should == 0

    x = 2
    (x **= 3).should == 8
    x.should == 8

    x = 4
    (x |= 3).should == 7
    x.should == 7
    (x |= 4).should == 7
    x.should == 7

    x = 6
    (x &= 3).should == 2
    x.should == 2
    (x &= 4).should == 0
    x.should == 0

    # XOR
    x = 2
    (x ^= 3).should == 1
    x.should == 1
    (x ^= 4).should == 5
    x.should == 5

    # Bit-shift left
    x = 17
    (x <<= 3).should == 136
    x.should == 136

    # Bit-shift right
    x = 5
    (x >>= 1).should == 2
    x.should == 2
  end
end

describe "Conditional operator assignment 'var op= expr'" do
  it "assigns the lhs if its truthiness is false for ||, true for &&" do
    x = nil
    (x ||= 17).should == 17
    x.should == 17
    (x ||= 2).should == 17
    x.should == 17

    x = false
    (x &&= true).should == false
    x.should == false
    (x &&= false).should == false
    x.should == false
    x = true
    (x &&= true).should == true
    x.should == true
    (x &&= false).should == false
    x.should == false
  end

  pending "may not assign at all, depending on the truthiness of lhs" do
    Object.new.instance_eval do
      @falsey = false
      @truthy = true
      freeze
      # lambda{ @truthy ||= 42 }.should_not raise_error
      # lambda{ @falsey &&= 42 }.should_not raise_error
    end
  end

  pending "uses short-circuit arg evaluation" do
    x = 8
    y = VariablesSpecs::OpAsgn.new
    (x ||= y.do_side_effect).should == 8
    y.side_effect.should == nil

    x = nil
    (x &&= y.do_side_effect).should == nil
    y.side_effect.should == nil

    y.a = 5
    (x ||= y.do_side_effect).should == 5
    y.side_effect.should == true
  end
end

describe "Unconditional operator assignment 'obj.meth op= expr'" do
  it "is equivalent to 'obj.meth = obj.meth op expr'" do
    @x = VariablesSpecs::OpAsgn.new
    @x.a = 13
    (@x.a += 5).should == 18
    @x.a.should == 18

    @x.a = 17
    (@x.a -= 11).should == 6
    @x.a.should == 6

    @x.a = 2
    (@x.a *= 5).should == 10
    @x.a.should == 10

    @x.a = 36
    (@x.a /= 9).should == 4
    @x.a.should == 4

    @x.a = 23
    (@x.a %= 5).should == 3
    @x.a.should == 3
    (@x.a %= 3).should == 0
    @x.a.should == 0

    @x.a = 2
    (@x.a **= 3).should == 8
    @x.a.should == 8

    @x.a = 4
    (@x.a |= 3).should == 7
    @x.a.should == 7
    (@x.a |= 4).should == 7
    @x.a.should == 7

    @x.a = 6
    (@x.a &= 3).should == 2
    @x.a.should == 2
    (@x.a &= 4).should == 0
    @x.a.should == 0

    # XOR
    @x.a = 2
    (@x.a ^= 3).should == 1
    @x.a.should == 1
    (@x.a ^= 4).should == 5
    @x.a.should == 5

    @x.a = 17
    (@x.a <<= 3).should == 136
    @x.a.should == 136

    @x.a = 5
    (@x.a >>= 1).should == 2
    @x.a.should == 2
  end
end

describe "Conditional operator assignment 'obj.meth op= expr'" do
  it "is equivalent to 'obj.meth op obj.meth = expr'" do
    @x = VariablesSpecs::OpAsgn.new
    @x.a = nil
    (@x.a ||= 17).should == 17
    @x.a.should == 17
    (@x.a ||= 2).should == 17
    @x.a.should == 17

    @x.a = false
    (@x.a &&= true).should == false
    @x.a.should == false
    (@x.a &&= false).should == false
    @x.a.should == false
    @x.a = true
    (@x.a &&= true).should == true
    @x.a.should == true
    (@x.a &&= false).should == false
    @x.a.should == false
  end

  pending "may not assign at all, depending on the truthiness of lhs" do
    m = mock("object")
    m.should_receive(:foo).and_return(:truthy)
    m.should_not_receive(:foo=)
    # m.foo ||= 42

    m.should_receive(:bar).and_return(false)
    m.should_not_receive(:bar=)
    # m.bar &&= 42
  end

  pending "uses short-circuit arg evaluation" do
    x = 8
    y = VariablesSpecs::OpAsgn.new
    (x ||= y.do_side_effect).should == 8
    y.side_effect.should == nil

    x = nil
    (x &&= y.do_side_effect).should == nil
    y.side_effect.should == nil

    y.a = 5
    (x ||= y.do_side_effect).should == 5
    y.side_effect.should == true
  end
end

describe "Operator assignment 'obj.meth op= expr'" do
  it "evaluates lhs one time" do
    x = VariablesSpecs::OpAsgn.new
    x.a = 5
    (x.do_more_side_effects.a += 5).should == 15
    x.a.should == 15

    x.a = 5
    (x.do_more_side_effects.a -= 4).should == 6
    x.a.should == 6

    x.a = 2
    (x.do_more_side_effects.a *= 5).should == 35
    x.a.should == 35

    x.a = 31
    (x.do_more_side_effects.a /= 9).should == 4
    x.a.should == 4

    x.a = 18
    (x.do_more_side_effects.a %= 5).should == 3
    x.a.should == 3

    x.a = 0
    (x.do_more_side_effects.a **= 3).should == 125
    x.a.should == 125

    x.a = -1
    (x.do_more_side_effects.a |= 3).should == 7
    x.a.should == 7

    x.a = 1
    (x.do_more_side_effects.a &= 3).should == 2
    x.a.should == 2

    # XOR
    x.a = -3
    (x.do_more_side_effects.a ^= 3).should == 1
    x.a.should == 1

    x.a = 12
    (x.do_more_side_effects.a <<= 3).should == 136
    x.a.should == 136

    x.a = 0
    (x.do_more_side_effects.a >>= 1).should == 2
    x.a.should == 2

    x.a = nil
    x.b = 0
    (x.do_bool_side_effects.a ||= 17).should == 17
    x.a.should == 17
    x.b.should == 1

    x.a = false
    x.b = 0
    (x.do_bool_side_effects.a &&= true).should == false
    x.a.should == false
    x.b.should == 1
    (x.do_bool_side_effects.a &&= false).should == false
    x.a.should == false
    x.b.should == 2
    x.a = true
    x.b = 0
    (x.do_bool_side_effects.a &&= true).should == true
    x.a.should == true
    x.b.should == 1
    (x.do_bool_side_effects.a &&= false).should == false
    x.a.should == false
    x.b.should == 2
  end
end

describe "Unconditional operator assignment 'obj[idx] op= expr'" do
  pending "is equivalent to 'obj[idx] = obj[idx] op expr'" do
    # x = [2,13,7]
    # (x[1] += 5).should == 18
    # x.should == [2,18,7]

    # x = [17,6]
    # (x[0] -= 11).should == 6
    # x.should == [6,6]

    # x = [nil,2,28]
    # (x[2] *= 2).should == 56
    # x.should == [nil,2,56]

    # x = [3,9,36]
    # (x[2] /= x[1]).should == 4
    # x.should == [3,9,4]

    # x = [23,4]
    # (x[0] %= 5).should == 3
    # x.should == [3,4]
    # (x[0] %= 3).should == 0
    # x.should == [0,4]

    # x = [1,2,3]
    # (x[1] **= 3).should == 8
    # x.should == [1,8,3]

    # x = [4,5,nil]
    # (x[0] |= 3).should == 7
    # x.should == [7,5,nil]
    # (x[0] |= 4).should == 7
    # x.should == [7,5,nil]

    # x = [3,6,9]
    # (x[1] &= 3).should == 2
    # x.should == [3,2,9]
    # (x[1] &= 4).should == 0
    # x.should == [3,0,9]

    # # XOR
    # x = [0,1,2]
    # (x[2] ^= 3).should == 1
    # x.should == [0,1,1]
    # (x[2] ^= 4).should == 5
    # x.should == [0,1,5]

    # x = [17]
    # (x[0] <<= 3).should == 136
    # x.should == [136]

    # x = [nil,5,8]
    # (x[1] >>= 1).should == 2
    # x.should == [nil,2,8]
  end
end

describe "Conditional operator assignment 'obj[idx] op= expr'" do
  pending "is equivalent to 'obj[idx] op obj[idx] = expr'" do
    # x = [1,nil,12]
    # (x[1] ||= 17).should == 17
    # x.should == [1,17,12]
    # (x[1] ||= 2).should == 17
    # x.should == [1,17,12]

    # x = [true, false, false]
    # (x[1] &&= true).should == false
    # x.should == [true, false, false]
    # (x[1] &&= false).should == false
    # x.should == [true, false, false]
    # (x[0] &&= true).should == true
    # x.should == [true, false, false]
    # (x[0] &&= false).should == false
    # x.should == [false, false, false]
  end

  pending "may not assign at all, depending on the truthiness of lhs" do
    # m = mock("object")
    # m.should_receive(:[]).and_return(:truthy)
    # m.should_not_receive(:[]=)
    # m[:foo] ||= 42

    # m = mock("object")
    # m.should_receive(:[]).and_return(false)
    # m.should_not_receive(:[]=)
    # m[:bar] &&= 42
  end

  pending "uses short-circuit arg evaluation" do
    # x = 8
    # y = VariablesSpecs::OpAsgn.new
    # (x ||= y.do_side_effect).should == 8
    # y.side_effect.should == nil

    # x = nil
    # (x &&= y.do_side_effect).should == nil
    # y.side_effect.should == nil

    # y.a = 5
    # (x ||= y.do_side_effect).should == 5
    # y.side_effect.should == true
  end
end

describe "Operator assignment 'obj[idx] op= expr'" do
  class ArrayWithDefaultIndex < Array
    def [](index=nil)
      super(index || 0)
    end

    def []=(first_arg, second_arg=nil)
      if second_arg
        index = fist_arg
        value = second_arg
      else
        index = 0
        value = first_arg
      end

      super(index, value)
    end
  end

  pending "handles empty index (idx) arguments" do
#     array = ArrayWithDefaultIndex.new
#     array << 1
#     (array[] += 5).should == 6
  end

  pending "handles complex index (idx) arguments" do
#     x = [1,2,3,4]
#     (x[0,2] += [5]).should == [1,2,5]
#     x.should == [1,2,5,3,4]
#     (x[0,2] += [3,4]).should == [1,2,3,4]
#     x.should == [1,2,3,4,5,3,4]

#     (x[2..3] += [8]).should == [3,4,8]
#     x.should == [1,2,3,4,8,5,3,4]

#     y = VariablesSpecs::OpAsgn.new
#     y.a = 1
#     (x[y.do_side_effect] *= 2).should == 4
#     x.should == [1,4,3,4,8,5,3,4]

#     h = {'key1' => 23, 'key2' => 'val'}
#     (h['key1'] %= 5).should == 3
#     (h['key2'] += 'ue').should == 'value'
#     h.should == {'key1' => 3, 'key2' => 'value'}
  end

  pending "handles empty splat index (idx) arguments" do
#     array = ArrayWithDefaultIndex.new
#     array << 5
#     splat_index = []

#     (array[*splat_index] += 5).should == 10
#     array.should== [10]
  end

  pending "handles single splat index (idx) arguments" do
#     array = [1,2,3,4]
#     splat_index = [0]

#     (array[*splat_index] += 5).should == 6
#     array.should == [6,2,3,4]
  end

  pending "handles multiple splat index (idx) arguments" do
#     array = [1,2,3,4]
#     splat_index = [0,2]

#     (array[*splat_index] += [5]).should == [1,2,5]
#     array.should == [1,2,5,3,4]
  end

  pending "handles splat index (idx) arguments with normal arguments" do
#     array = [1,2,3,4]
#     splat_index = [2]

#     (array[0, *splat_index] += [5]).should == [1,2,5]
#     array.should == [1,2,5,3,4]
  end

  # This example fails on 1.9 because of bug #2050
  pending "returns result of rhs not result of []=" do
#     a = VariablesSpecs::Hashalike.new

#     (a[123] =   2).should == 2
#     (a[123] +=  2).should == 125
#     (a[123] -=  2).should == 121
#     (a[123] *=  2).should == 246
#     # Guard against the Mathn library
#     # TODO: Make these specs not rely on specific behaviour / result values
#     # by using mocks.
#     conflicts_with :Prime do
#       (a[123] /=  2).should == 61
#     end
#     (a[123] %=  2).should == 1
#     (a[123] **= 2).should == 15129
#     (a[123] |=  2).should == 123
#     (a[123] &=  2).should == 2
#     (a[123] ^=  2).should == 121
#     (a[123] <<= 2).should == 492
#     (a[123] >>= 2).should == 30
#     (a[123] ||= 2).should == 123
#     (a[nil] ||= 2).should == 2
#     (a[123] &&= 2).should == 2
#     (a[nil] &&= 2).should == nil
  end
end

describe "Single assignment" do
  it "Assignment does not modify the lhs, it reassigns its reference" do
    a = 'Foobar'
    b = a
    b = 'Bazquux'
    a.should == 'Foobar'
    b.should == 'Bazquux'
  end

  it "Assignment does not copy the object being assigned, just creates a new reference to it" do
    a = []
    b = a
    b << 1
    a.should == [1]
  end

  it "If rhs has multiple arguments, lhs becomes an Array of them" do
    a = 1, 2, 3
    a.should == [1, 2, 3]

    a = 1, (), 3
    a.should == [1, nil, 3]
  end
end

describe "Multiple assignment without grouping or splatting" do
  it "An equal number of arguments on lhs and rhs assigns positionally" do
    a, b, c, d = 1, 2, 3, 4
    a.should == 1
    b.should == 2
    c.should == 3
    d.should == 4
  end

  it "If rhs has too few arguments, the missing ones on lhs are assigned nil" do
    a, b, c = 1, 2
    a.should == 1
    b.should == 2
    c.should == nil
  end

  it "If rhs has too many arguments, the extra ones are silently not assigned anywhere" do
    a, b = 1, 2, 3
    a.should == 1
    b.should == 2
  end

  it "The assignments are done in parallel so that lhs and rhs are independent of eachother without copying" do
    o_of_a, o_of_b = mock('a'), mock('b')
    a, b = o_of_a, o_of_b
    a, b = b, a
    a.should equal(o_of_b)
    b.should equal(o_of_a)
  end
end

describe "Multiple assignments with splats" do
  ruby_version_is ""..."1.9" do
    it "* on the lhs has to be applied to the last parameter" do
      lambda { eval 'a, *b, c = 1, 2, 3' }.should raise_error(SyntaxError)
    end
  end

  it "* on the lhs collects all parameters from its position onwards as an Array or an empty Array" do
    a, *b = 1, 2
    c, *d = 1
    e, *f = 1, 2, 3
    g, *h = 1, [2, 3]
    *i = 1, [2,3]
    *k = 1,2,3

    a.should == 1
    b.should == [2]
    c.should == 1
    d.should == []
    e.should == 1
    f.should == [2, 3]
    g.should == 1
    h.should == [[2, 3]]
    i.should == [1, [2, 3]]
    k.should == [1,2,3]
  end

  ruby_version_is ""..."1.9" do
    it "* on the LHS returns the Array on the RHS enclosed in an Array" do
      *j = [1,2,3]
      j.should == [[1,2,3]]
    end
  end

  ruby_version_is "1.9" do
    it "* on the LHS returns the Array on the RHS without enclosing it in an Array" do
      *j = [1,2,3]
      j.should == [1,2,3]
    end
  end
end

describe "Multiple assignments with grouping" do
  pending "A group on the lhs is considered one position and treats its corresponding rhs position like an Array" do
    # a, (b, c), d = 1, 2, 3, 4
    # e, (f, g), h = 1, [2, 3, 4], 5
    # i, (j, k), l = 1, 2, 3
    a.should == 1
    b.should == 2
    c.should == nil
    d.should == 3
    e.should == 1
    f.should == 2
    g.should == 3
    h.should == 5
    i.should == 1
    j.should == 2
    k.should == nil
    l.should == 3
  end

  pending "supports multiple levels of nested groupings" do
    # a,(b,(c,d)) = 1,[2,[3,4]]
    a.should == 1
    b.should == 2
    c.should == 3
    d.should == 4

    # a,(b,(c,d)) = [1,[2,[3,4]]]
    a.should == 1
    b.should == 2
    c.should == 3
    d.should == 4

    x = [1,[2,[3,4]]]
    # a,(b,(c,d)) = x
    a.should == 1
    b.should == 2
    c.should == 3
    d.should == 4
  end

  pending "rhs cannot use parameter grouping, it is a syntax error" do
    lambda { eval '(a, b) = (1, 2)' }.should raise_error(SyntaxError)
  end
end

# TODO: merge the following two describe blocks and partition the specs
# into distinct cases.
describe "Multiple assignment" do
  pending do
  not_compliant_on :rubinius do
    it "has the proper return value" do
      # (a,b,*c = *[5,6,7,8,9,10]).should == [5,6,7,8,9,10]
      # (d,e = VariablesSpecs.reverse_foo(4,3)).should == [3,4]
      # (f,g,h = VariablesSpecs.reverse_foo(6,7)).should == [7,6]
      # (i,*j = *[5,6,7]).should == [5,6,7]
      # (k,*l = [5,6,7]).should == [5,6,7]
      a.should == 5
      b.should == 6
      c.should == [7,8,9,10]
      d.should == 3
      e.should == 4
      f.should == 7
      g.should == 6
      h.should == nil
      i.should == 5
      j.should == [6,7]
      k.should == 5
      l.should == [6,7]
    end
  end
  end

  # TODO: write Rubinius versions
end

# For now, masgn is deliberately non-compliant with MRI wrt the return val from an masgn.
# Rubinius returns true as the result of the assignment, but MRI returns an array
# containing all the elements on the rhs. As this result is never used, the cost
# of creating and then discarding this array is avoided
describe "Multiple assignment, array-style" do
  pending do
  not_compliant_on :rubinius do
    it "returns an array of all rhs values" do
      (a,b = 5,6,7).should == [5,6,7]
      a.should == 5
      b.should == 6

      (c,d,*e = 99,8).should == [99,8]
      c.should == 99
      d.should == 8
      e.should == []

      (f,g,h = 99,8).should == [99,8]
      f.should == 99
      g.should == 8
      h.should == nil
    end
  end

  deviates_on :rubinius do
    it "returns true" do
      (a,b = 5,6,7).should == true
      a.should == 5
      b.should == 6

      (c,d,*e = 99,8).should == true
      c.should == 99
      d.should == 8
      e.should == []

      (f,g,h = 99,8).should == true
      f.should == 99
      g.should == 8
      h.should == nil
    end
  end
  end
end

describe "Scope of variables" do
  pending "instance variables not overwritten by local variable in each block" do

    class ScopeVariables
      attr_accessor :v

      def initialize
        @v = ['a', 'b', 'c']
      end

      def check_access
        v.should == ['a', 'b', 'c']
        self.v.should == ['a', 'b', 'c']
      end

      def check_local_variable
        v = nil
        self.v.should == ['a', 'b', 'c']
      end

      def check_each_block
        self.v.each { |v|
          # Don't actually do anything
        }
        self.v.should == ['a', 'b', 'c']
        v.should == ['a', 'b', 'c']
        self.v.object_id.should == v.object_id
      end
    end # Class ScopeVariables

    instance = ScopeVariables.new()
    instance.check_access
    instance.check_local_variable
    instance.check_each_block
  end
end

describe "A local variable in a #define_method scope" do
  pending do
  ruby_bug '#1322', '1.8.7.228' do
    it "shares the lexical scope containing the call to #define_method" do
      # We need a new scope to reproduce this bug.
      handle = mock("handle for containing scope method")

      def handle.produce_bug
        local = 1

        klass = Class.new
        klass.send :define_method, :set_local do |arg|
          lambda { local = 2 }.call
        end

        # We must call with at least one argument to reproduce the bug.
        klass.new.set_local(nil)

        local
      end

      handle.produce_bug.should == 2
    end
  end
  end
end

# # language_version __FILE__, "variables"
