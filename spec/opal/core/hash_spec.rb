describe 'Hash' do
  it 'works with object-strings with regards to deleting' do
    h = {`new String('a')` => 'a'}
    k = h.keys.first
    h.delete(k)
    h.inspect.should == '{}'
  end
end
