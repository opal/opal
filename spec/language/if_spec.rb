# 
# describe "The if expression" do
#   it "evaluates body if expression is true" do
#     a = []
#     if true
#       a << 123
#     end
#     a.should == [123]
#   end
#   
#   it "does not evaluate body if expression is false" do
#     a = []
#     if false
#       a << 123
#     end
#     a.should == []
#   end
#   
#   it "does not evaluate body if expression is empty" do
#     a = []
#     if ()
#       a << 123
#     end
#     a.should == []
#   end
#   
#   it "does not evaluate else body if expression is true" do
#     a = []
#     if true
#       a << 123
#     else
#       a << 456
#     end
#     a.should == [123]
#   end
#   
#   it "evaluates only else-body if expression is false" do
#     a = []
#     if false
#       a << 123
#     else
#       a << 456
#     end
#     a.should == [456]
#   end
#   
#   it "returns result of then-body evaluation if expression is true" do
#     # raise "this causes error: return is injected before if = javascript error"
#     # if true
#       # 123
#     # end.should == 456
#   end
# end

