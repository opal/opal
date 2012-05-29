describe "Class Hierarchy" do
  it "should have the right superclasses" do
    BasicObject.superclass.should == nil
    Object.superclass.should == BasicObject
    Module.superclass.should == Object
    Class.superclass.should == Module
  end

  it "should have the right classes" do
    BasicObject.class.should == Class
    Object.class.should == Class
    Class.class.should == Class
    Module.class.should == Class
  end

  it "instances should have the right class" do
    (BasicObject === BasicObject.new).should == true
    Object.new.class.should == Object
    Class.new.class.should == Class
    Module.new.class.should == Module
  end
end