# NOTE: run bin/format-filters after changing this file
opal_filter "freezing" do
  fails "FalseClass#to_s returns a frozen string" # Expected "false".frozen? to be truthy but was false
  fails "Kernel#freeze on a Float has no effect since it is already frozen" # Expected false to be true
  fails "Kernel#freeze on a Symbol has no effect since it is already frozen" # Expected false to be true
  fails "Kernel#freeze on integers has no effect since they are already frozen" # Expected false to be true
  fails "Kernel#freeze on true, false and nil has no effect since they are already frozen" # Expected false to be true
  fails "Kernel#frozen? on a Float returns true" # Expected false to be true
  fails "Kernel#frozen? on a Symbol returns true" # Expected false to be true
  fails "Kernel#frozen? on integers returns true" # Expected false to be true
  fails "Kernel#frozen? on true, false and nil returns true" # Expected false to be true
  fails "MatchData#string returns a frozen copy of the match string" # Expected "THX1138.".frozen? to be truthy but was false
  fails "Module#name returns a frozen String" # Expected "ModuleSpecs".frozen? to be truthy but was false
  fails "NilClass#to_s returns a frozen string" # Expected "".frozen? to be truthy but was false
  fails "Numeric#clone does not change frozen status" # Expected false == true to be truthy but was false
  fails "Numeric#dup does not change frozen status" # Expected false == true to be truthy but was false
  fails "TrueClass#to_s returns a frozen string" # Expected "true".frozen? to be truthy but was false
end
