describe 'duplicated underscore parameter' do
  it 'assigns the first arg' do
    klass = Class.new {
      def req_req(_, _) = _
      def req_rest_req(_, *, _) = _
      def rest_req(*_, _) = _
      def req_opt(_, _ = 0) = _
      def opt_req(_ = 0, _) = _
      def req_kwopt(_, _: 0) = _
      def req_kwrest(_, **_) = _
      def req_block(_, &_) = _
      def req_mlhs(_, (_)) = _
      def mlhs_req((_), _) = _
      def rest_kw(*_, _:) = _
      def nested_mlhs(((_), _)) = _
      def nested_mlhs_rest(((*_, _))) = _
    }
    o = klass.new

    o.req_req(1, 2).should == 1
    o.req_rest_req(1, 2, 3, 4).should == 1
    o.rest_req(1, 2, 3).should == [1, 2]
    o.req_opt(1).should == 1
    o.req_opt(1, 2).should == 1
    o.opt_req(1).should == 0
    o.opt_req(1, 2).should == 1
    o.req_kwopt(1, _: 2).should == 1
    o.req_kwrest(1, a: 2).should == 1
    o.req_block(1).should == 1
    o.req_block(1) {}.should == 1
    o.req_mlhs(1, [2]).should == 1
    o.mlhs_req([1], 2).should == 1
    o.rest_kw(1, 2, _: 3).should == [1, 2]
    o.nested_mlhs([[1], 2]).should == 1
    o.nested_mlhs_rest([[1, 2, 3]]).should == [1, 2]
  end

  context 'in block parameters' do
    it 'assignes the first arg' do
      proc { |_, _| _ }.call(1, 2).should == 1
      proc { |_, *_| _ }.call(1, 2, 3).should == 1
      proc { |*_, _| _ }.call(1, 2, 3).should == [1, 2]
      proc { |_, _:| _ }.call(1, _: 2).should == 1
      proc { |**_, &_| _ }.call(a: 1) {}.should == {a: 1}
    end
  end

  it 'distinguishes two arguments starting with _' do
    klass = Class.new {
      def foo(_a, _a, _b, _b) = [_a, _b]
    }
    o = klass.new
    o.foo(1, 2, 3, 4).should == [1, 3]
  end

  it 'works with yield' do
    klass = Class.new {
      def foo(_, &_) = yield * 2
    }
    o = klass.new
    o.foo(1) { 2 }.should == 4
  end

  it 'works with block_given?' do
    klass = Class.new {
      def foo(_, &_) = block_given?
    }
    o = klass.new

    o.foo(1).should == false
    o.foo(1) {}.should == true
  end
end
