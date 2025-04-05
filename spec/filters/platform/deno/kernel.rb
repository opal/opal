# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#Float converts Strings to floats without calling #to_f" # FrozenError: can't modify frozen String: '10'
  fails "Kernel#String returns the same object if it is already a String" # FrozenError: can't modify frozen String: 'Hello'
  fails "Kernel#sprintf returns a String in the argument's encoding if format encoding is more restrictive" # FrozenError: can't modify frozen String
  fails "Kernel.Float converts Strings to floats without calling #to_f" # FrozenError: can't modify frozen String: '10'
  fails "Kernel.String returns the same object if it is already a String" # FrozenError: can't modify frozen String: 'Hello'
  fails "Kernel.sprintf returns a String in the argument's encoding if format encoding is more restrictive" # FrozenError: can't modify frozen String
end
