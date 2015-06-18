opal_filter "thread" do
  fails "Kernel#sleep pauses execution indefinitely if not given a duration"
end
