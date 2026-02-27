# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Set" do
  fails "Set#eql? returns true when the passed argument is a Set and contains the same elements" # Expected #<Set: {1,2,3}> not to have same value or type as #<Set: {1,2,3}>
  fails "Set#initialize is private" # Expected Set to have private instance method 'initialize' but it does not  
end
