opal_filter "Thread" do
  fails "StandardError is a superclass of ThreadError"
  fails "The throw keyword raises an ArgumentError if used to exit a thread"
  fails "The throw keyword clears the current exception"
end
