
# class SpecificExampleException < StandardError; end

# class OtherCustomException < StandardError; end

# def exception_list
#   [SpecificExampleException, OtherCustomException]
# end

# describe "The rescue keyword" do
#   it "can be used to handle a specific exception"
  
#   it "can capture the raised exception in a local variable" do
#     begin
#       raise SpecificExampleException, "some text"
#     rescue SpecificExampleException => e
#       e.message.should == "some text"
#     end
#   end
# end
