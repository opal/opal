describe "Array#[]=" do
  it 'expands the array when assigning another array to a range' do
    a = ['a']
    a[3..4] = ['b', 'c']
    expect(a).to eq(['a', nil, nil, 'b', 'c'])
  end
end
