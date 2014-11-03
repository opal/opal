opal_filter "Exception" do
  fails "Exception#message calls #to_s on self"

  fails "Exception.new returns the exception when it has a custom constructor"

  fails "Exception#to_s returns the self's name if no message is set"
  fails "Exception#to_s calls #to_s on the message"

  fails "Exception#inspect returns the class name when #to_s returns an empty string"
  fails "Exception#inspect includes #to_s when the result is non-empty"
  fails "Exception#inspect returns '#<Exception: Exception>' when no message given"
end
