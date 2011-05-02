require File.expand_path('../../spec_helper', __FILE__)

describe "self in an eigenclass body (class << obj)" do
  it "is TrueClass for true" do
    class << true; self; end.should == TrueClass
  end

  it "is FalseClass for false" do
    class << false; self; end.should == FalseClass
  end

  it "is NilClass for nil" do
    class << nil; self; end.should == NilClass
  end

  it "raises a TypeError for Fixnum's" do
    lambda { class << 1; self; end }.should raise_error(TypeError)
  end

  it "raises a TypeError for symbols" do
    lambda { class << :symbol; self; end }.should raise_error(TypeError)
  end

  it "is a singleton Class instance" do
    mock = Object.new
    cls = class << mock; self; end
    cls.is_a?(Class).should == true
    (cls == Object).should == false
    mock.is_a?(cls).should == true
  end
#   
#   it "is a Class for classes"
#   
#   it "inherits from Class for classes" do
#     temp = []
#     cls = class << Object; self; end
#     sc = cls
#     until sc.nil? || sc.superclass == sc
#       temp << sc
#       sc = sc.superclass
#     end
#     temp.should include(Class)
#   end
end


# puts "testing eigenclass etc"
# 
# class EigenclassSpecTest
#   
#   def something=(something)
#     puts "setting something to #{something}"
#   end
# end
# 
# a = EigenclassSpecTest.new
# a.something = 100
# 
# a_class = class << a; self; end
# 
# a_class.define_method(:something=) do |value|
#   puts "setting something.."
#   super value
#   puts "did set something"
# end
# 
# # `console.log(#{a}['$something=']);`
# 
# a.something = 200
