
# describe "Module#attr_accessor" do
#   it "creates a getter and setter for each given attribute name" do
#     class AttrAccessorSpec
#       attr_accessor :a, 'b'
#     end
#     
#     o = AttrAccessorSpec.new
#     
#     ['a', 'b'].each do |x|
#       o.respond_to?(x).should == true
#       o.respond_to?("#{x}=").should == true
#     end
#     
#     o.a = "a"
#     o.a.should == "a"
#     
#     o.b = "b"
#     o.b.should == "b"
#     o.a = o.b = nil
#     
#     o.__send__(:a=, "a")
#     o.__send__(:a).should == "a"
#     
#     o.__send__(:b=, "b")
#     o.__send__(:b).should == "b"
#   end
# end
