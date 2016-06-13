# Currently opal uses Parser22 which == ruby2.2
# No support for squiggly heredoc yet.
# TODO: enable this specs after full migration to 2.3
# describe "'Squiggly' heredoc" do
#   context "when heredoc is blank" do
#     it "returns a blank string" do
#       heredoc = <<~HERE
#       HERE

#       heredoc.should == ""
#     end
#   end

#   context "when heredoc contains multiple lines" do
#     it "selects a least-indented line and removes its indentation from all the lines" do
#       heredoc = <<~HERE
#         a
#           b
#            c
#       HERE

#       heredoc.should == "a\n  b\n   c\n"
#     end
#   end

#   it "supports escaped heredoc identifier" do
#     <<~"HERE".should == ""
#     HERE

#     <<~'HERE'.should == ""
#     HERE
#   end

#   it "doesn't allow <<-~ syntax" do
#     lambda {
#       eval("<<-~HERE\nHERE")
#     }.should raise_error
#   end

#   it "doesn't allow <<~- syntax" do
#     lambda {
#       eval("<<~-HERE\nHERE")
#     }.should raise_error
#   end
# end
