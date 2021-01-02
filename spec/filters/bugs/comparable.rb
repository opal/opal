# NOTE: run bin/format-filters after changing this file
opal_filter "Comparable" do
  fails "Comparable#clamp returns self if within the given range parameters" # ArgumentError: [Weird#clamp] wrong number of arguments(1 for 2)
  fails "Comparable#clamp returns the maximum value of the range parameters if greater than it" # ArgumentError: [Weird#clamp] wrong number of arguments(1 for 2)
  fails "Comparable#clamp returns the minimum value of the range parameters if smaller than it" # ArgumentError: [Weird#clamp] wrong number of arguments(1 for 2)
end
