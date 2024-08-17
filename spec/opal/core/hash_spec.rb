# backtick_javascript: true

describe 'Hash' do
  it 'works with object-strings with regards to deleting' do
    h = {`new String('a')` => 'a'}
    k = h.keys.first
    h.delete(k)
    h.inspect.should == '{}'
  end

  it 'compacts nil and JavaScript null and undefined values' do
    h = { a: nil, b: `null`, c: `undefined`, d: 1 }
    expect(h.size).to eq 4
    expect(h.compact.size).to eq 1
    h.compact!
    expect(h.size).to eq 1
  end
end
