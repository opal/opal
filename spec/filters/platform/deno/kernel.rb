# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#Float converts Strings to floats without calling #to_f" # Exception: Cannot create property '$$meta' on string '10'
  fails "Kernel#String returns the same object if it is already a String" # Exception: Cannot create property '$$meta' on string 'Hello'
  fails "Kernel#caller includes core library methods defined in Ruby" # Expected "file:///var/folders/lj/_64stkl97_x2wy7w567j8m5m0000gn/T/opal-system-runner20241010-53720-6w8bh1.js:1715:14:in `Object.Opal.yield1'".end_with? "in `tap'" to be truthy but was false
  fails "Kernel#clone with freeze: nil copies frozen?" # Expected false to be true
  fails "Kernel#clone with no arguments copies frozen?" # Expected false to be true
  fails "Kernel.Float converts Strings to floats without calling #to_f" # Exception: Cannot create property '$$meta' on string '10'
  fails "Kernel.String returns the same object if it is already a String" # Exception: Cannot create property '$$meta' on string 'Hello'
end
