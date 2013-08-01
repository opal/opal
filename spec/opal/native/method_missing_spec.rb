describe "Native::Object#method_missing" do
  it 'should return values' do
    Native(`{ a: 23 }`).a.should == 23
    Native(`{ a: { b: 42 } }`).a.b.should == 42
  end

  it 'should call functions' do
    Native(`{ a: function() { return 42 } }`).a.should == 42
  end

  it 'should set values' do
    var = `{}`

    Native(var).a = 42
    `#{var}.a`.should == 42
    Native(var).a.should == 42
  end
end
