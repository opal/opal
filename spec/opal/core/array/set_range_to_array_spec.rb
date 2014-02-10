describe "Array#[]=" do
  it 'expands the array when assigning another array to a range' do
    a = ['a']
    a[3..4] = ['b', 'c']
    a.should == ['a', nil, nil, 'b', 'c']
  end
end
