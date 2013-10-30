require File.expand_path('../fixtures/classes', __FILE__)

describe "Struct.new" do
  it "creates a constant in Struct namespace with string as first argument" do
    struct = Struct.new('Animal', :name, :legs, :eyeballs)
    struct.should == Struct::Animal
    struct.name.should == "Struct::Animal"
  end

  it "creates an instance" do
    StructClasses::Ruby.new.kind_of?(StructClasses::Ruby).should == true
  end

  it "creates reader methods" do
    StructClasses::Ruby.new.should have_method(:version)
    StructClasses::Ruby.new.should have_method(:platform)
  end

  it "creates writer methods" do
    StructClasses::Ruby.new.should have_method(:version=)
    StructClasses::Ruby.new.should have_method(:platform=)
  end
end
