describe "Range#===" do
  it "returns true if other is an element of self" do
    ((0..5) === 2).should == true
    ((-5..5) === 0).should == true
    ((-1...1) === 10.5).should == false
    ((-10..-2) === -2.5).should == true
    (('C'..'X') === 'M').should == true
    (('C'..'X') === 'A').should == false
    (('B'...'W') === 'W').should == false
    (('B'...'W') === 'Q').should == true
    ((0.5..2.4) === 2).should == true
    ((0.5..2.4) === 2.5).should == false
    ((0.5...2.4) === 2.4).should == true
    ((0.5...2.4) === 2.4).should == false
  end
end