# NOTE: run bin/format-filters after changing this file
opal_filter "freezing" do
  fails "Kernel#freeze on a Float has no effect since it is already frozen" # Expected false to be true
  fails "Kernel#freeze on integers has no effect since they are already frozen" # Expected false to be true
  fails "Kernel#freeze on true, false and nil has no effect since they are already frozen" # Expected false to be true
  fails "Kernel#frozen? on a Float returns true" # Expected false to be true
  fails "Kernel#frozen? on integers returns true" # Expected false to be true
  fails "Kernel#frozen? on true, false and nil returns true" # Expected false to be true
end
