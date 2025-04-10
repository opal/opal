# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "freezing" do
  fails "FalseClass#to_s returns a frozen string" # Expected "false".frozen? to be truthy but was false
  fails "Frozen properties is frozen if the object it is created from is frozen" # Expected false == true to be truthy but was false
  fails "Frozen properties will be frozen if the object it is created from becomes frozen" # Expected false == true to be truthy but was false
  fails "FrozenError#receiver should return frozen object that modification was attempted on" # Expected #<Class:#<Object:0x19db4>> to be identical to #<Object:0x19db4>
  fails "Hash literal freezes string keys on initialization" # NotImplementedError: String#reverse! not supported. Mutable String methods are not supported in Opal.
  fails "Kernel#freeze causes mutative calls to raise RuntimeError" # Expected RuntimeError but no exception was raised (1 was returned)
  fails "Kernel#freeze on a Symbol has no effect since it is already frozen" # Expected false to be true
  fails "Kernel#frozen? on a Symbol returns true" # Expected false to be true
  fails "MatchData#string returns a frozen copy of the match string" # Expected "THX1138.".frozen? to be truthy but was false
  fails "Module#name returns a frozen String" # Expected "ModuleSpecs".frozen? to be truthy but was false
  fails "NilClass#to_s returns a frozen string" # Expected "".frozen? to be truthy but was false
  fails "Proc#[] with frozen_string_literals doesn't duplicate frozen strings" # Expected false to be true
  fails "TrueClass#to_s returns a frozen string" # Expected "true".frozen? to be truthy but was false
end
