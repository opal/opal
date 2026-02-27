# NOTE: run bin/format-filters after changing this file
opal_filter "Delegate" do
  fails "Delegator#!= is delegated in general" # Exception: Maximum call stack size exceeded
  fails "Delegator#== is delegated in general" # Exception: Maximum call stack size exceeded
end
