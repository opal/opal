# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Class" do
  fails "Class#initialize is private"
  fails "Class.inherited is called when marked as a public class method"
end
