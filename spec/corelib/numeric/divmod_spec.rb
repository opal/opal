describe 'Numeric#divmod' do
  it 'returns the quotient and modulus of self and a given divisor' do
    # Examples taken from table on http://ruby-doc.org/core-2.0.0/Numeric.html#method-i-divmod
    13.divmod(4).should == [3, 1]
    13.divmod(-4).should == [-4, -3]
    (-13).divmod(4).should == [-4, 3]
    (-13).divmod(-4).should == [3, -1]
    11.5.divmod(4).should == [2, 3.5]
    11.5.divmod(-4).should == [-3, -0.5]
    (-11.5).divmod(4).should == [-3, 0.5]
    (-11.5).divmod(-4).should == [2, -3.5]
  end
end
