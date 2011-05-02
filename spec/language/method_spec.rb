
describe "Calling a method" do
  it "with no arguments is ok" do
    def fooP0; 100; end
    
    fooP0.should == 100
  end
  
  it "with simple required arguments works" do
    def fooP1(a); [a]; end
    fooP1(1).should == [1]
    
    def fooP2(a, b); [a, b]; end
    fooP2(1, 2).should == [1, 2]
    
    def fooP3(a,b,c); [a,b,c]; end
    fooP3(1,2,3).should == [1,2,3]

    def fooP4(a,b,c,d); [a,b,c,d]; end
    fooP4(1,2,3,4).should == [1,2,3,4]

    def fooP5(a,b,c,d,e); [a,b,c,d,e]; end
    fooP5(1,2,3,4,5).should == [1,2,3,4,5]
  end
  
  it "works with optional arguments" do
    def fooP0O1(a=1); [a]; end
    fooP0O1().should == [1]
    
    def fooP1O1(a, b=1); [a, b]; end
    fooP1O1(1).should == [1, 1]
    
    def fooP2O1(a, b, c=1); [a, b, c]; end
    fooP2O1(1, 2).should == [1, 2, 1]
    
    def fooP3O1(a, b, c, d=1); [a, b, c, d]; end
    fooP3O1(1, 2, 3).should == [1, 2, 3, 1]
    
    def fooP4O1(a, b, c, d, e=1); [a, b, c, d, e]; end
    fooP4O1(1, 2, 3, 4).should == [1, 2, 3, 4, 1]
    
    def fooP0O2(a=1, b=2); [a, b]; end
    fooP0O2.should == [1, 2]
  end
  
  it "works with rest arguments" do
    def fooP0R(*r); r; end
    fooP0R().should == []
    fooP0R(1).should == [1]
    fooP0R(1, 2).should == [1, 2]
    
    def fooP1R(a, *r); [a, r]; end
    fooP1R(1).should == [1, []]
    fooP1R(1, 2).should == [1, [2]]
    
    # def fooP0O1R(a=1, *r); [a, r]; end
    # fooP0O1R().should == [1, []]
  end
  
  it "with an empty expression is like calling with nil argument" do
    def foo(a); a; end
    foo(()).should == nil
  end
  
  it "with block as block argument is ok" do
    # def foo(a, &b); [a, yield(b)] end
    
    foo(10) do 200 end.should == [10, 200]
    foo(10) { 200 }.should == [10, 200]
  end
  
  it "with block argument converts the block to proc" do
    def makeproc(&b) b end
      makeproc { "hello" }.call.should == "hello"
      makeproc { "hello" }.class.should == Proc
      
      def proc_caller(&b) b.call end
      def enclosing_method
        proc_caller { return :break_return_value }
        :method_return_value
      end
      
      enclosing_method.should == :break_return_value
  end
  
  it "with same names as existing variables is ok" do
    foobar = 100
    
    def foobar; 200; end
    
    foobar.should == 100
    foobar().should == 200
  end
  
  it "with splat operator * and literal array unpacks params" do
    def fooP3(a, b, c); [a, b, c]; end
    
    fooP3(*[1, 2, 3]).should == [1, 2, 3]
  end
  
  it "with splat operator * and references array unpacks params" do
    def fooP3(a,b,c); [a,b,c] end
    
    a = [1,2,3]
    fooP3(*a).should == [1,2,3]
  end
  
  it "without parentheses works" do
    def fooP3(a,b,c); [a,b,c] end
    
    (fooP3 1,2,3).should == [1,2,3]
  end
  
  it "with a space separating method name and parenthesis treats expression in parenthesis as first argument" do
    def myfoo(x); x * 2 end
    def mybar
      # means myfoo((5).to_s)
      # NOT   (myfoo(5)).to_s
      # myfoo (5).to_s
    end
    
    # mybar().should == "55"
  end
end
