describe "Array#uniq" do
  it "relies on Ruby's #hash (not JavaScript's #toString) for identifying array items" do
    a = [ 123, '123']
    a.uniq.should == a

    a = [ Time.at(1429521600.1), Time.at(1429521600.9) ]
    a.uniq.should == a

    a = [ Object.new, Object.new ]
    a.uniq.should == a

    a = [ 1, 2, 3, '1', '2', '3']
    a.uniq.should == a

    a = [ [1, 2, 3], '1,2,3']
    a.uniq.should == a

    a = [ true, 'true']
    a.uniq.should == a

    a = [ false, 'false']
    a.uniq.should == a
  end
end

describe "Array#uniq!" do
  it "relies on Ruby's #hash (not JavaScript's #toString) for identifying array items" do
    a = [ 123, '123']
    a.uniq!.should == nil

    a = [ Time.at(1429521600.1), Time.at(1429521600.9) ]
    a.uniq!.should == nil

    a = [ Object.new, Object.new ]
    a.uniq!.should == nil

    a = [ 1, 2, 3, '1', '2', '3']
    a.uniq!.should == nil

    a = [ [1, 2, 3], '1,2,3']
    a.uniq!.should == nil

    a = [ true, 'true']
    a.uniq!.should == nil

    a = [ false, 'false']
    a.uniq!.should == nil
  end
end
