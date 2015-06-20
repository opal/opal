opal_filter "Class" do
  fails "Class#initialize is private"
  fails "Class.inherited is called when marked as a public class method"
end
