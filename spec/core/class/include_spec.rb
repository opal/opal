require File.expand_path('../fixtures/classes', __FILE__)
describe "Class#include" do 
  it "should have own method" do 
    Include::AClass.new.a.should == 'A:a'
  end

  it "should have included method" do 
    Include::BClass.new.a.should == "M:a"
  end

  it "should return own methods with inheritance" do 
    Include::CClass.new.a.should == "A:a"
  end
end