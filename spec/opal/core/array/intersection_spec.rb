describe "Array#&" do
  it "relies on Ruby's #hash (not JavaScript's #toString) for identifying array items" do
    a1 = [ 123, '123']
    a2 = ['123', 123 ]
    (a1 & a2).should == a1
    (a2 & a1).should == a2

    a1 = [ Time.at(1429521600.1), Time.at(1429521600.9) ]
    a2 = [ Time.at(1429521600.9), Time.at(1429521600.1) ]
    (a1 & a2).should == a1
    (a2 & a1).should == a2

    a1 = [ Object.new, Object.new ]
    a2 = [ Object.new, Object.new ]
    (a1 & a2).should == []
    (a2 & a1).should == []

    a1 = [ 1, 2, 3, '1', '2', '3']
    a2 = ['1', '2', '3', 1, 2, 3 ]
    (a1 & a2).should == a1
    (a2 & a1).should == a2

    a1 = [ [1, 2, 3], '1,2,3']
    a2 = ['1,2,3', [1, 2, 3] ]
    (a1 & a2).should == a1
    (a2 & a1).should == a2

    a1 = [ true, 'true']
    a2 = ['true', true ]
    (a1 & a2).should == a1
    (a2 & a1).should == a2

    a1 = [ false, 'false']
    a2 = ['false', false ]
    (a1 & a2).should == a1
    (a2 & a1).should == a2
  end
end
