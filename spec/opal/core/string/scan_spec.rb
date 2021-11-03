describe 'String#scan' do
  it 'supports block argument destructuring' do
    foo = []
    "/foo/:bar".scan(/:(\w+)/) { |name,| foo << name }

    foo.should == ["bar"]
  end
end
