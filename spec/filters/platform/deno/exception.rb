# NOTE: run bin/format-filters after changing this file
opal_filter "Exception" do
  fails "Invoking a method when the method is not available should omit the method_missing call from the backtrace for NameError" # Expected "file:///var/folders/lj/_64stkl97_x2wy7w567j8m5m0000gn/T/opal-system-runner20241010-53720-6w8bh1.js:1563:35:in `klass.method_missing_stub'" not to include "method_missing"
  fails "Invoking a method when the method is not available should omit the method_missing call from the backtrace for NoMethodError" # Expected "file:///var/folders/lj/_64stkl97_x2wy7w567j8m5m0000gn/T/opal-system-runner20241010-53720-6w8bh1.js:1563:35:in `klass.method_missing_stub'" not to include "method_missing"
end
