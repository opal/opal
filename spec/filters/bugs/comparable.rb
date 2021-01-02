# NOTE: run bin/format-filters after changing this file
opal_filter "Comparable" do
  fails "Comparable#clamp raises an Argument error unless given 2 parameters" # Expected ArgumentError but got: TypeError (wrong argument type ComparableSpecs::Weird (expected Range))
end
