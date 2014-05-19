require File.expand_path('../fixtures/variables', __FILE__)

# TODO: partition these specs into distinct cases based on the
# real parsed forms, not the superficial code forms.
describe "Basic assignment" do
  it "allows the rhs to be assigned to the lhs" do
    a = nil
    expect(a).to eq(nil)
  end

  it "assigns nil to lhs when rhs is an empty expression" do
    a = ()
    expect(a).to be_nil
  end

  ruby_version_is "" ... "1.9" do
    it "assigns nil to lhs when rhs is an empty splat expression" do
      a = *()
      expect(a).to be_nil
    end
  end

  ruby_version_is "1.9" do
    it "assigns [] to lhs when rhs is an empty splat expression" do
      a = *()
      expect(a).to eq([])
    end
  end

  ruby_version_is "" ... "1.9" do
    it "allows the assignment of the rhs to the lhs using the rhs splat operator" do
      a = *nil;      expect(a).to eq(nil)
      a = *1;        expect(a).to eq(1)
      a = *[];       expect(a).to eq(nil)
      a = *[1];      expect(a).to eq(1)
      a = *[nil];    expect(a).to eq(nil)
      a = *[[]];     expect(a).to eq([])
      a = *[1,2];    expect(a).to eq([1,2])
    end
  end

  ruby_version_is "1.9" do
    it "allows the assignment of the rhs to the lhs using the rhs splat operator" do
      a = *nil;      expect(a).to eq([])
      a = *1;        expect(a).to eq([1])
      a = *[];       expect(a).to eq([])
      a = *[1];      expect(a).to eq([1])
      a = *[nil];    expect(a).to eq([nil])
      a = *[[]];     expect(a).to eq([[]])
      a = *[1,2];    expect(a).to eq([1,2])
    end
  end

  ruby_version_is "" ... "1.9" do
    it "allows the assignment of the rhs to the lhs using the lhs splat operator" do
      # * = 1,2        # Valid syntax, but pretty useless! Nothing to test
      *a = nil;      expect(a).to eq([nil])
      *a = 1;        expect(a).to eq([1])
      *a = [];       expect(a).to eq([[]])
      *a = [1];      expect(a).to eq([[1]])
      *a = [1,2];    expect(a).to eq([[1,2]])
    end
  end

  ruby_version_is "1.9" do
    it "allows the assignment of the rhs to the lhs using the lhs splat operator" do
      # * = 1,2        # Valid syntax, but pretty useless! Nothing to test
      *a = nil;      expect(a).to eq([nil])
      *a = 1;        expect(a).to eq([1])
      *a = [];       expect(a).to eq([])
      *a = [1];      expect(a).to eq([1])
      *a = [1,2];    expect(a).to eq([1,2])
    end
  end

  ruby_version_is "" ... "1.9" do
    it "allows the assignment of rhs to the lhs using the lhs and rhs splat operators simultaneously" do
      *a = *nil;      expect(a).to eq([nil])
      *a = *1;        expect(a).to eq([1])
      *a = *[];       expect(a).to eq([])
      *a = *[1];      expect(a).to eq([1])
      *a = *[nil];    expect(a).to eq([nil])
      *a = *[1,2];    expect(a).to eq([1,2])
    end
  end

  ruby_version_is "1.9" do
    it "allows the assignment of rhs to the lhs using the lhs and rhs splat operators simultaneously" do
      *a = *nil;      expect(a).to eq([])
      *a = *1;        expect(a).to eq([1])
      *a = *[];       expect(a).to eq([])
      *a = *[1];      expect(a).to eq([1])
      *a = *[nil];    expect(a).to eq([nil])
      *a = *[1,2];    expect(a).to eq([1,2])
    end
  end

  it "sets unavailable values to nil" do
    ary = []
    a, b, c = ary

    expect(a).to be_nil
    expect(b).to be_nil
    expect(c).to be_nil
  end

  it "sets the splat to an empty Array if there are no more values" do
    ary = []
    a, b, *c = ary

    expect(a).to be_nil
    expect(b).to be_nil
    expect(c).to eq([])
  end

  it "allows multiple values to be assigned" do
    a,b,*c = nil;       expect([a,b,c]).to eq([nil, nil, []])
    a,b,*c = 1;         expect([a,b,c]).to eq([1, nil, []])
    a,b,*c = [];        expect([a,b,c]).to eq([nil, nil, []])
    a,b,*c = [1];       expect([a,b,c]).to eq([1, nil, []])
    a,b,*c = [nil];     expect([a,b,c]).to eq([nil, nil, []])
    a,b,*c = [[]];      expect([a,b,c]).to eq([[], nil, []])
    a,b,*c = [1,2];     expect([a,b,c]).to eq([1,2,[]])

    a,b,*c = *nil;      expect([a,b,c]).to eq([nil, nil, []])
    a,b,*c = *1;        expect([a,b,c]).to eq([1, nil, []])
    a,b,*c = *[];       expect([a,b,c]).to eq([nil, nil, []])
    a,b,*c = *[1];      expect([a,b,c]).to eq([1, nil, []])
    a,b,*c = *[nil];    expect([a,b,c]).to eq([nil, nil, []])
    a,b,*c = *[[]];     expect([a,b,c]).to eq([[], nil, []])
    a,b,*c = *[1,2];    expect([a,b,c]).to eq([1,2,[]])
  end

  it "calls to_a on the given argument when using a splat" do
    a,b = *VariablesSpecs::ArrayLike.new([1,2]); expect([a,b]).to eq([1,2])
  end

  it "supports the {|r,| } form of block assignment" do
    f = lambda {|r,| expect(r).to eq([])}
    f.call([], *[])

    f = lambda{|x,| x}
    expect(f.call(42)).to eq(42)
    expect(f.call([42])).to eq([42])
    expect(f.call([[42]])).to eq([[42]])
    expect(f.call([42,55])).to eq([42,55])
  end

  it "allows assignment through lambda" do
    f = lambda {|r,*l| expect(r).to eq([]); expect(l).to eq([1])}
    f.call([], *[1])

    f = lambda{|x| x}
    expect(f.call(42)).to eq(42)
    expect(f.call([42])).to eq([42])
    expect(f.call([[42]])).to eq([[42]])
    expect(f.call([42,55])).to eq([42,55])

    f = lambda{|*x| x}
    expect(f.call(42)).to eq([42])
    expect(f.call([42])).to eq([[42]])
    expect(f.call([[42]])).to eq([[[42]]])
    expect(f.call([42,55])).to eq([[42,55]])
    expect(f.call(42,55)).to eq([42,55])
  end

  it "allows chained assignment" do
    expect(a = 1 + b = 2 + c = 4 + d = 8).to eq(15)
    expect(d).to eq(8)
    expect(c).to eq(12)
    expect(b).to eq(14)
    expect(a).to eq(15)
  end
end

describe "Assignment using expansion" do
  ruby_version_is "" ... "1.9" do
    it "succeeds without conversion" do
      *x = (1..7).to_a
      expect(x).to eq([[1, 2, 3, 4, 5, 6, 7]])
    end
  end

  ruby_version_is "1.9" do
    it "succeeds without conversion" do
      *x = (1..7).to_a
      expect(x).to eq([1, 2, 3, 4, 5, 6, 7])
    end
  end
end

describe "Basic multiple assignment" do
  describe "with a single RHS value" do
    it "does not call #to_ary on an Array instance" do
      x = [1, 2]
      expect(x).not_to receive(:to_ary)

      a, b = x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "does not call #to_a on an Array instance" do
      x = [1, 2]
      expect(x).not_to receive(:to_a)

      a, b = x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "does not call #to_ary on an Array subclass instance" do
      x = VariablesSpecs::ArraySubclass.new [1, 2]
      expect(x).not_to receive(:to_ary)

      a, b = x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "does not call #to_a on an Array subclass instance" do
      x = VariablesSpecs::ArraySubclass.new [1, 2]
      expect(x).not_to receive(:to_a)

      a, b = x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "calls #to_ary on an object" do
      x = double("single rhs value for masgn")
      expect(x).to receive(:to_ary).and_return([1, 2])

      a, b = x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "does not call #to_a on an object if #to_ary is not defined" do
      x = double("single rhs value for masgn")
      expect(x).not_to receive(:to_a)

      a, b = x
      expect(a).to eq(x)
      expect(b).to be_nil
    end

    it "does not call #to_a on a String" do
      x = "one\ntwo"

      a, b = x
      expect(a).to eq(x)
      expect(b).to be_nil
    end
  end

  describe "with a splatted single RHS value" do
    it "does not call #to_ary on an Array instance" do
      x = [1, 2]
      expect(x).not_to receive(:to_ary)

      a, b = *x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "does not call #to_a on an Array instance" do
      x = [1, 2]
      expect(x).not_to receive(:to_a)

      a, b = *x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "does not call #to_ary on an Array subclass instance" do
      x = VariablesSpecs::ArraySubclass.new [1, 2]
      expect(x).not_to receive(:to_ary)

      a, b = *x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "does not call #to_a on an Array subclass instance" do
      x = VariablesSpecs::ArraySubclass.new [1, 2]
      expect(x).not_to receive(:to_a)

      a, b = *x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    it "calls #to_a on an object if #to_ary is not defined" do
      x = double("single splatted rhs value for masgn")
      expect(x).to receive(:to_a).and_return([1, 2])

      a, b = *x
      expect(a).to eq(1)
      expect(b).to eq(2)
    end

    ruby_version_is ""..."1.9" do
      it "calls #to_ary on an object" do
        x = double("single splatted rhs value for masgn")
        expect(x).to receive(:to_ary).and_return([1, 2])

        a, b = *x
        expect(a).to eq(1)
        expect(b).to eq(2)
      end

      it "calls #to_a on a String" do
        x = "one\ntwo"

        a, b = *x
        expect(a).to eq("one\n")
        expect(b).to eq("two")
      end
    end

    ruby_version_is "1.9" do
      it "does not call #to_ary on an object" do
        x = double("single splatted rhs value for masgn")
        expect(x).not_to receive(:to_ary)

        a, b = *x
        expect(a).to eq(x)
        expect(b).to be_nil
      end

      it "does not call #to_a on a String" do
        x = "one\ntwo"

        a, b = *x
        expect(a).to eq(x)
        expect(b).to be_nil
      end
    end
  end
end

describe "Assigning multiple values" do
  it "allows parallel assignment" do
    a, b = 1, 2
    expect(a).to eq(1)
    expect(b).to eq(2)

    # a, = 1,2
    expect(a).to eq(1)
  end

  it "allows safe parallel swapping" do
    a, b = 1, 2
    a, b = b, a
    expect(a).to eq(2)
    expect(b).to eq(1)
  end

  not_compliant_on :rubinius do
    it "returns the rhs values used for assignment as an array" do
      # x = begin; a, b, c = 1, 2, 3; end
      expect(x).to eq([1,2,3])
    end
  end

  ruby_version_is "" ... "1.9" do
    it "wraps a single value in an Array" do
      *a = 1
      expect(a).to eq([1])

      b = [1]
      *a = b
      expect(a).to eq([b])
    end
  end

  ruby_version_is "1.9" do
    it "wraps a single value in an Array if it's not already one" do
      *a = 1
      expect(a).to eq([1])

      b = [1]
      *a = b
      expect(a).to eq(b)
    end
  end

  it "evaluates rhs left-to-right" do
    a = VariablesSpecs::ParAsgn.new
    d, e ,f = a.inc, a.inc, a.inc
    expect(d).to eq(1)
    expect(e).to eq(2)
    expect(f).to eq(3)
  end

  it "supports parallel assignment to lhs args via object.method=" do
    a = VariablesSpecs::ParAsgn.new
    a.x, b = 1, 2

    expect(a.x).to eq(1)
    expect(b).to eq(2)

    c = VariablesSpecs::ParAsgn.new
    c.x, a.x = a.x, b

    expect(c.x).to eq(1)
    expect(a.x).to eq(2)
  end

  it "supports parallel assignment to lhs args using []=" do
    a = [1,2,3]
    a[3], b = 4,5

    expect(a).to eq([1,2,3,4])
    expect(b).to eq(5)
  end

  it "bundles remaining values to an array when using the splat operator" do
    a, *b = 1, 2, 3
    expect(a).to eq(1)
    expect(b).to eq([2, 3])

    *a = 1, 2, 3
    expect(a).to eq([1, 2, 3])

    *a = 4
    expect(a).to eq([4])

    *a = nil
    expect(a).to eq([nil])

    a, = *[1]
    expect(a).to eq(1)
  end

  ruby_version_is ""..."1.9" do
    it "calls #to_ary on rhs arg if rhs has only a single arg" do
      x = VariablesSpecs::ParAsgn.new
      a,b,c = x
      expect(a).to eq(1)
      expect(b).to eq(2)
      expect(c).to eq(3)

      a,b,c = x,5
      expect(a).to eq(x)
      expect(b).to eq(5)
      expect(c).to eq(nil)

      a,b,c = 5,x
      expect(a).to eq(5)
      expect(b).to eq(x)
      expect(c).to eq(nil)

      a,b,*c = x,5
      expect(a).to eq(x)
      expect(b).to eq(5)
      expect(c).to eq([])

      # a,(b,c) = 5,x
      expect(a).to eq(5)
      expect(b).to eq(1)
      expect(c).to eq(2)

      # a,(b,*c) = 5,x
      expect(a).to eq(5)
      expect(b).to eq(1)
      expect(c).to eq([2,3,4])

      # a,(b,(*c)) = 5,x
      expect(a).to eq(5)
      expect(b).to eq(1)
      expect(c).to eq([2])

      # a,(b,(*c),(*d)) = 5,x
      expect(a).to eq(5)
      expect(b).to eq(1)
      expect(c).to eq([2])
      expect(d).to eq([3])

      # a,(b,(*c),(d,*e)) = 5,x
      expect(a).to eq(5)
      expect(b).to eq(1)
      expect(c).to eq([2])
      expect(d).to eq(3)
      expect(e).to eq([])
    end
  end

  ruby_version_is "1.9" do
    it "calls #to_ary on RHS arg if the corresponding LHS var is a splat" do
      x = VariablesSpecs::ParAsgn.new

      # a,(*b),c = 5,x
      expect(a).to eq(5)
      expect(b).to eq(x.to_ary)
      expect(c).to eq(nil)
    end
  end

  ruby_version_is ""..."1.9" do
    it "doen't call #to_ary on RHS arg when the corresponding LHS var is a splat" do
      x = VariablesSpecs::ParAsgn.new

      # a,(*b),c = 5,x
      expect(a).to eq(5)
      expect(b).to eq([x])
      expect(c).to eq(nil)
    end
  end

  it "allows complex parallel assignment" do
    # a, (b, c), d = 1, [2, 3], 4
    expect(a).to eq(1)
    expect(b).to eq(2)
    expect(c).to eq(3)
    expect(d).to eq(4)

    # x, (y, z) = 1, 2, 3
    expect([x,y,z]).to eq([1,2,nil])
    # x, (y, z) = 1, [2,3]
    expect([x,y,z]).to eq([1,2,3])
    # x, (y, z) = 1, [2]
    expect([x,y,z]).to eq([1,2,nil])

    # a,(b,c,*d),(e,f),*g = 0,[1,2,3,4],[5,6],7,8
    expect(a).to eq(0)
    expect(b).to eq(1)
    expect(c).to eq(2)
    expect(d).to eq([3,4])
    expect(e).to eq(5)
    expect(f).to eq(6)
    expect(g).to eq([7,8])

    x = VariablesSpecs::ParAsgn.new
    # a,(b,c,*d),(e,f),*g = 0,x,[5,6],7,8
    expect(a).to eq(0)
    expect(b).to eq(1)
    expect(c).to eq(2)
    expect(d).to eq([3,4])
    expect(e).to eq(5)
    expect(f).to eq(6)
    expect(g).to eq([7,8])
  end

  it "allows a lhs arg to be used in another lhs args parallel assignment" do
    c = [4,5,6]
    a,b,c[a] = 1,2,3
    expect(a).to eq(1)
    expect(b).to eq(2)
    expect(c).to eq([4,3,6])

    c[a],b,a = 7,8,9
    expect(a).to eq(9)
    expect(b).to eq(8)
    expect(c).to eq([4,7,6])
  end
end

describe "Conditional assignment" do
  it "assigns the lhs if previously unassigned" do
    a=[]
    a[0] ||= "bar"
    expect(a[0]).to eq("bar")

    h={}
    h["foo"] ||= "bar"
    expect(h["foo"]).to eq("bar")

    h["foo".to_sym] ||= "bar"
    expect(h["foo".to_sym]).to eq("bar")

    aa = 5
    aa ||= 25
    expect(aa).to eq(5)

    bb ||= 25
    expect(bb).to eq(25)

    cc &&=33
    expect(cc).to eq(nil)

    cc = 5
    cc &&=44
    expect(cc).to eq(44)
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
    expect(x += 5).to eq(18)
    expect(x).to eq(18)

    x = 17
    expect(x -= 11).to eq(6)
    expect(x).to eq(6)

    x = 2
    expect(x *= 5).to eq(10)
    expect(x).to eq(10)

    x = 36
    expect(x /= 9).to eq(4)
    expect(x).to eq(4)

    x = 23
    expect(x %= 5).to eq(3)
    expect(x).to eq(3)
    expect(x %= 3).to eq(0)
    expect(x).to eq(0)

    x = 2
    expect(x **= 3).to eq(8)
    expect(x).to eq(8)

    x = 4
    expect(x |= 3).to eq(7)
    expect(x).to eq(7)
    expect(x |= 4).to eq(7)
    expect(x).to eq(7)

    x = 6
    expect(x &= 3).to eq(2)
    expect(x).to eq(2)
    expect(x &= 4).to eq(0)
    expect(x).to eq(0)

    # XOR
    x = 2
    expect(x ^= 3).to eq(1)
    expect(x).to eq(1)
    expect(x ^= 4).to eq(5)
    expect(x).to eq(5)

    # Bit-shift left
    x = 17
    expect(x <<= 3).to eq(136)
    expect(x).to eq(136)

    # Bit-shift right
    x = 5
    expect(x >>= 1).to eq(2)
    expect(x).to eq(2)
  end
end

describe "Conditional operator assignment 'var op= expr'" do
  it "assigns the lhs if its truthiness is false for ||, true for &&" do
    x = nil
    expect(x ||= 17).to eq(17)
    expect(x).to eq(17)
    expect(x ||= 2).to eq(17)
    expect(x).to eq(17)

    x = false
    expect(x &&= true).to eq(false)
    expect(x).to eq(false)
    expect(x &&= false).to eq(false)
    expect(x).to eq(false)
    x = true
    expect(x &&= true).to eq(true)
    expect(x).to eq(true)
    expect(x &&= false).to eq(false)
    expect(x).to eq(false)
  end

  it "may not assign at all, depending on the truthiness of lhs" do
    Object.new.instance_eval do
      @falsey = false
      @truthy = true
      freeze
      # lambda{ @truthy ||= 42 }.should_not raise_error
      # lambda{ @falsey &&= 42 }.should_not raise_error
    end
  end

  it "uses short-circuit arg evaluation" do
    x = 8
    y = VariablesSpecs::OpAsgn.new
    expect(x ||= y.do_side_effect).to eq(8)
    expect(y.side_effect).to eq(nil)

    x = nil
    expect(x &&= y.do_side_effect).to eq(nil)
    expect(y.side_effect).to eq(nil)

    y.a = 5
    expect(x ||= y.do_side_effect).to eq(5)
    expect(y.side_effect).to eq(true)
  end
end

describe "Unconditional operator assignment 'obj.meth op= expr'" do
  it "is equivalent to 'obj.meth = obj.meth op expr'" do
    @x = VariablesSpecs::OpAsgn.new
    @x.a = 13
    expect(@x.a += 5).to eq(18)
    expect(@x.a).to eq(18)

    @x.a = 17
    expect(@x.a -= 11).to eq(6)
    expect(@x.a).to eq(6)

    @x.a = 2
    expect(@x.a *= 5).to eq(10)
    expect(@x.a).to eq(10)

    @x.a = 36
    expect(@x.a /= 9).to eq(4)
    expect(@x.a).to eq(4)

    @x.a = 23
    expect(@x.a %= 5).to eq(3)
    expect(@x.a).to eq(3)
    expect(@x.a %= 3).to eq(0)
    expect(@x.a).to eq(0)

    @x.a = 2
    expect(@x.a **= 3).to eq(8)
    expect(@x.a).to eq(8)

    @x.a = 4
    expect(@x.a |= 3).to eq(7)
    expect(@x.a).to eq(7)
    expect(@x.a |= 4).to eq(7)
    expect(@x.a).to eq(7)

    @x.a = 6
    expect(@x.a &= 3).to eq(2)
    expect(@x.a).to eq(2)
    expect(@x.a &= 4).to eq(0)
    expect(@x.a).to eq(0)

    # XOR
    @x.a = 2
    expect(@x.a ^= 3).to eq(1)
    expect(@x.a).to eq(1)
    expect(@x.a ^= 4).to eq(5)
    expect(@x.a).to eq(5)

    @x.a = 17
    expect(@x.a <<= 3).to eq(136)
    expect(@x.a).to eq(136)

    @x.a = 5
    expect(@x.a >>= 1).to eq(2)
    expect(@x.a).to eq(2)
  end
end

describe "Conditional operator assignment 'obj.meth op= expr'" do
  it "is equivalent to 'obj.meth op obj.meth = expr'" do
    @x = VariablesSpecs::OpAsgn.new
    @x.a = nil
    expect(@x.a ||= 17).to eq(17)
    expect(@x.a).to eq(17)
    expect(@x.a ||= 2).to eq(17)
    expect(@x.a).to eq(17)

    @x.a = false
    expect(@x.a &&= true).to eq(false)
    expect(@x.a).to eq(false)
    expect(@x.a &&= false).to eq(false)
    expect(@x.a).to eq(false)
    @x.a = true
    expect(@x.a &&= true).to eq(true)
    expect(@x.a).to eq(true)
    expect(@x.a &&= false).to eq(false)
    expect(@x.a).to eq(false)
  end

  it "may not assign at all, depending on the truthiness of lhs" do
    m = double("object")
    expect(m).to receive(:foo).and_return(:truthy)
    expect(m).not_to receive(:foo=)
    # m.foo ||= 42

    expect(m).to receive(:bar).and_return(false)
    expect(m).not_to receive(:bar=)
    # m.bar &&= 42
  end

  it "uses short-circuit arg evaluation" do
    x = 8
    y = VariablesSpecs::OpAsgn.new
    expect(x ||= y.do_side_effect).to eq(8)
    expect(y.side_effect).to eq(nil)

    x = nil
    expect(x &&= y.do_side_effect).to eq(nil)
    expect(y.side_effect).to eq(nil)

    y.a = 5
    expect(x ||= y.do_side_effect).to eq(5)
    expect(y.side_effect).to eq(true)
  end
end

describe "Operator assignment 'obj.meth op= expr'" do
  it "evaluates lhs one time" do
    x = VariablesSpecs::OpAsgn.new
    x.a = 5
    expect(x.do_more_side_effects.a += 5).to eq(15)
    expect(x.a).to eq(15)

    x.a = 5
    expect(x.do_more_side_effects.a -= 4).to eq(6)
    expect(x.a).to eq(6)

    x.a = 2
    expect(x.do_more_side_effects.a *= 5).to eq(35)
    expect(x.a).to eq(35)

    x.a = 31
    expect(x.do_more_side_effects.a /= 9).to eq(4)
    expect(x.a).to eq(4)

    x.a = 18
    expect(x.do_more_side_effects.a %= 5).to eq(3)
    expect(x.a).to eq(3)

    x.a = 0
    expect(x.do_more_side_effects.a **= 3).to eq(125)
    expect(x.a).to eq(125)

    x.a = -1
    expect(x.do_more_side_effects.a |= 3).to eq(7)
    expect(x.a).to eq(7)

    x.a = 1
    expect(x.do_more_side_effects.a &= 3).to eq(2)
    expect(x.a).to eq(2)

    # XOR
    x.a = -3
    expect(x.do_more_side_effects.a ^= 3).to eq(1)
    expect(x.a).to eq(1)

    x.a = 12
    expect(x.do_more_side_effects.a <<= 3).to eq(136)
    expect(x.a).to eq(136)

    x.a = 0
    expect(x.do_more_side_effects.a >>= 1).to eq(2)
    expect(x.a).to eq(2)

    x.a = nil
    x.b = 0
    expect(x.do_bool_side_effects.a ||= 17).to eq(17)
    expect(x.a).to eq(17)
    expect(x.b).to eq(1)

    x.a = false
    x.b = 0
    expect(x.do_bool_side_effects.a &&= true).to eq(false)
    expect(x.a).to eq(false)
    expect(x.b).to eq(1)
    expect(x.do_bool_side_effects.a &&= false).to eq(false)
    expect(x.a).to eq(false)
    expect(x.b).to eq(2)
    x.a = true
    x.b = 0
    expect(x.do_bool_side_effects.a &&= true).to eq(true)
    expect(x.a).to eq(true)
    expect(x.b).to eq(1)
    expect(x.do_bool_side_effects.a &&= false).to eq(false)
    expect(x.a).to eq(false)
    expect(x.b).to eq(2)
  end
end

describe "Unconditional operator assignment 'obj[idx] op= expr'" do
  it "is equivalent to 'obj[idx] = obj[idx] op expr'" do
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
  it "is equivalent to 'obj[idx] op obj[idx] = expr'" do
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

  it "may not assign at all, depending on the truthiness of lhs" do
    # m = mock("object")
    # m.should_receive(:[]).and_return(:truthy)
    # m.should_not_receive(:[]=)
    # m[:foo] ||= 42

    # m = mock("object")
    # m.should_receive(:[]).and_return(false)
    # m.should_not_receive(:[]=)
    # m[:bar] &&= 42
  end

  it "uses short-circuit arg evaluation" do
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

  it "handles empty index (idx) arguments" do
#     array = ArrayWithDefaultIndex.new
#     array << 1
#     (array[] += 5).should == 6
  end

  it "handles complex index (idx) arguments" do
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

  it "handles empty splat index (idx) arguments" do
#     array = ArrayWithDefaultIndex.new
#     array << 5
#     splat_index = []

#     (array[*splat_index] += 5).should == 10
#     array.should== [10]
  end

  it "handles single splat index (idx) arguments" do
#     array = [1,2,3,4]
#     splat_index = [0]

#     (array[*splat_index] += 5).should == 6
#     array.should == [6,2,3,4]
  end

  it "handles multiple splat index (idx) arguments" do
#     array = [1,2,3,4]
#     splat_index = [0,2]

#     (array[*splat_index] += [5]).should == [1,2,5]
#     array.should == [1,2,5,3,4]
  end

  it "handles splat index (idx) arguments with normal arguments" do
#     array = [1,2,3,4]
#     splat_index = [2]

#     (array[0, *splat_index] += [5]).should == [1,2,5]
#     array.should == [1,2,5,3,4]
  end

  # This example fails on 1.9 because of bug #2050
  it "returns result of rhs not result of []=" do
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
    expect(a).to eq('Foobar')
    expect(b).to eq('Bazquux')
  end

  it "Assignment does not copy the object being assigned, just creates a new reference to it" do
    a = []
    b = a
    b << 1
    expect(a).to eq([1])
  end

  it "If rhs has multiple arguments, lhs becomes an Array of them" do
    a = 1, 2, 3
    expect(a).to eq([1, 2, 3])

    a = 1, (), 3
    expect(a).to eq([1, nil, 3])
  end
end

describe "Multiple assignment without grouping or splatting" do
  it "An equal number of arguments on lhs and rhs assigns positionally" do
    a, b, c, d = 1, 2, 3, 4
    expect(a).to eq(1)
    expect(b).to eq(2)
    expect(c).to eq(3)
    expect(d).to eq(4)
  end

  it "If rhs has too few arguments, the missing ones on lhs are assigned nil" do
    a, b, c = 1, 2
    expect(a).to eq(1)
    expect(b).to eq(2)
    expect(c).to eq(nil)
  end

  it "If rhs has too many arguments, the extra ones are silently not assigned anywhere" do
    a, b = 1, 2, 3
    expect(a).to eq(1)
    expect(b).to eq(2)
  end

  it "The assignments are done in parallel so that lhs and rhs are independent of eachother without copying" do
    o_of_a, o_of_b = double('a'), double('b')
    a, b = o_of_a, o_of_b
    a, b = b, a
    expect(a).to equal(o_of_b)
    expect(b).to equal(o_of_a)
  end
end

describe "Multiple assignments with splats" do
  ruby_version_is ""..."1.9" do
    it "* on the lhs has to be applied to the last parameter" do
      expect { eval 'a, *b, c = 1, 2, 3' }.to raise_error(SyntaxError)
    end
  end

  it "* on the lhs collects all parameters from its position onwards as an Array or an empty Array" do
    a, *b = 1, 2
    c, *d = 1
    e, *f = 1, 2, 3
    g, *h = 1, [2, 3]
    *i = 1, [2,3]
    *k = 1,2,3

    expect(a).to eq(1)
    expect(b).to eq([2])
    expect(c).to eq(1)
    expect(d).to eq([])
    expect(e).to eq(1)
    expect(f).to eq([2, 3])
    expect(g).to eq(1)
    expect(h).to eq([[2, 3]])
    expect(i).to eq([1, [2, 3]])
    expect(k).to eq([1,2,3])
  end

  ruby_version_is ""..."1.9" do
    it "* on the LHS returns the Array on the RHS enclosed in an Array" do
      *j = [1,2,3]
      expect(j).to eq([[1,2,3]])
    end
  end

  ruby_version_is "1.9" do
    it "* on the LHS returns the Array on the RHS without enclosing it in an Array" do
      *j = [1,2,3]
      expect(j).to eq([1,2,3])
    end
  end
end

describe "Multiple assignments with grouping" do
  it "A group on the lhs is considered one position and treats its corresponding rhs position like an Array" do
    # a, (b, c), d = 1, 2, 3, 4
    # e, (f, g), h = 1, [2, 3, 4], 5
    # i, (j, k), l = 1, 2, 3
    expect(a).to eq(1)
    expect(b).to eq(2)
    expect(c).to eq(nil)
    expect(d).to eq(3)
    expect(e).to eq(1)
    expect(f).to eq(2)
    expect(g).to eq(3)
    expect(h).to eq(5)
    expect(i).to eq(1)
    expect(j).to eq(2)
    expect(k).to eq(nil)
    expect(l).to eq(3)
  end

  it "supports multiple levels of nested groupings" do
    # a,(b,(c,d)) = 1,[2,[3,4]]
    expect(a).to eq(1)
    expect(b).to eq(2)
    expect(c).to eq(3)
    expect(d).to eq(4)

    # a,(b,(c,d)) = [1,[2,[3,4]]]
    expect(a).to eq(1)
    expect(b).to eq(2)
    expect(c).to eq(3)
    expect(d).to eq(4)

    x = [1,[2,[3,4]]]
    # a,(b,(c,d)) = x
    expect(a).to eq(1)
    expect(b).to eq(2)
    expect(c).to eq(3)
    expect(d).to eq(4)
  end

  it "rhs cannot use parameter grouping, it is a syntax error" do
    expect { eval '(a, b) = (1, 2)' }.to raise_error(SyntaxError)
  end
end

# TODO: merge the following two describe blocks and partition the specs
# into distinct cases.
describe "Multiple assignment" do
  not_compliant_on :rubinius do
    it "has the proper return value" do
      # (a,b,*c = *[5,6,7,8,9,10]).should == [5,6,7,8,9,10]
      # (d,e = VariablesSpecs.reverse_foo(4,3)).should == [3,4]
      # (f,g,h = VariablesSpecs.reverse_foo(6,7)).should == [7,6]
      # (i,*j = *[5,6,7]).should == [5,6,7]
      # (k,*l = [5,6,7]).should == [5,6,7]
      expect(a).to eq(5)
      expect(b).to eq(6)
      expect(c).to eq([7,8,9,10])
      expect(d).to eq(3)
      expect(e).to eq(4)
      expect(f).to eq(7)
      expect(g).to eq(6)
      expect(h).to eq(nil)
      expect(i).to eq(5)
      expect(j).to eq([6,7])
      expect(k).to eq(5)
      expect(l).to eq([6,7])
    end
  end

  # TODO: write Rubinius versions
end

# For now, masgn is deliberately non-compliant with MRI wrt the return val from an masgn.
# Rubinius returns true as the result of the assignment, but MRI returns an array
# containing all the elements on the rhs. As this result is never used, the cost
# of creating and then discarding this array is avoided
describe "Multiple assignment, array-style" do
  not_compliant_on :rubinius do
    it "returns an array of all rhs values" do
      expect(a,b = 5,6,7).to eq([5,6,7])
      expect(a).to eq(5)
      expect(b).to eq(6)

      expect(c,d,*e = 99,8).to eq([99,8])
      expect(c).to eq(99)
      expect(d).to eq(8)
      expect(e).to eq([])

      expect(f,g,h = 99,8).to eq([99,8])
      expect(f).to eq(99)
      expect(g).to eq(8)
      expect(h).to eq(nil)
    end
  end

  deviates_on :rubinius do
    it "returns true" do
      expect(a,b = 5,6,7).to eq(true)
      expect(a).to eq(5)
      expect(b).to eq(6)

      expect(c,d,*e = 99,8).to eq(true)
      expect(c).to eq(99)
      expect(d).to eq(8)
      expect(e).to eq([])

      expect(f,g,h = 99,8).to eq(true)
      expect(f).to eq(99)
      expect(g).to eq(8)
      expect(h).to eq(nil)
    end
  end
end

describe "Scope of variables" do
  it "instance variables not overwritten by local variable in each block" do

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
  ruby_bug '#1322', '1.8.7.228' do
    it "shares the lexical scope containing the call to #define_method" do
      # We need a new scope to reproduce this bug.
      handle = double("handle for containing scope method")

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

      expect(handle.produce_bug).to eq(2)
    end
  end
end

language_version __FILE__, "variables"
