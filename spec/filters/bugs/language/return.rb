opal_filter "return" do
  fails "The return keyword within a begin returns last value returned in nested ensures"
  fails "The return keyword within a begin executes nested ensures before returning"
  fails "The return keyword when passed a splat calls 'to_a' on the splatted value first"
  fails "The return keyword when passed a splat returns an array when used as a splat"
  fails "The return keyword in a Thread raises a LocalJumpError if used to exit a thread"
end
