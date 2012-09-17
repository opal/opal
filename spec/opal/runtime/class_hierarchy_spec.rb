describe "Class Hierarchy" do
  it "should have the right superclasses" do
    Object.superclass.should == nil
    Module.superclass.should == Object
    Class.superclass.should == Object
  end

  it "should have the right classes" do
    Object.class.should == Class
    Class.class.should == Class
    Module.class.should == Class
  end

  it "instances should have the right class" do
    Object.new.class.should == Object
    Class.new.class.should == Class
    Module.new.class.should == Module
  end
end