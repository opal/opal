opal_filter "2.0 behaviour" do
  fails "Enumerator.new ignores block if arg given"
  fails "String#end_with? ignores arguments not convertible to string"
end
