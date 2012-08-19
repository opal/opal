class StringSubclassSpec < String
  def to_full_name
    self + ' beynon'
  end
end

describe "String subclasses" do
  it "should correctly report the class" do
    StringSubclassSpec.new.class.should == StringSubclassSpec
    String.new.class.should == String
  end

  it "should still set the string's value" do
    s1 = String.new 'foo'
    s1.class.should == String
    s1.should == 'foo'

    s2 = StringSubclassSpec.new 'bar'
    s2.class.should == StringSubclassSpec
    s2.should == 'bar'
  end

  it "should copy the subclasses methods onto instance" do
    StringSubclassSpec.new('adam').to_full_name.should == 'adam beynon'
  end
end