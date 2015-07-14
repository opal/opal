describe "Array#-" do
  it "relies on Ruby's #hash (not JavaScript's #toString) for identifying array items" do
    a1 = [ 123 ]
    a2 = ['123']
    (a1 - a2).should == a1
    (a2 - a1).should == a2

    a1 = [ Time.at(1429521600.1) ]
    a2 = [ Time.at(1429521600.9) ]
    (a1 - a2).should == a1
    (a2 - a1).should == a2

    a1 = [ Object.new ]
    a2 = [ Object.new ]
    (a1 - a2).should == a1
    (a2 - a1).should == a2

    a1 = [ 1, 2, 3 ]
    a2 = ['1', '2', '3']
    (a1 - a2).should == a1
    (a2 - a1).should == a2

    a1 = [ 1, 2, 3 ]
    a2 = ['1,2,3']
    (a1 - a2).should == a1
    (a2 - a1).should == a2

    a1 = [ true ]
    a2 = ['true']
    (a1 - a2).should == a1
    (a2 - a1).should == a2

    a1 = [ false ]
    a2 = ['false']
    (a1 - a2).should == a1
    (a2 - a1).should == a2
  end
end
