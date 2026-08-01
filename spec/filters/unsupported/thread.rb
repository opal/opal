# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Thread" do
  fails "The return keyword in a Thread raises a LocalJumpError if used to exit a thread" # NotImplementedError: Thread creation not available
end
