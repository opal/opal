# NOTE: run bin/format-filters after changing this file
opal_filter "Binding" do
  fails "Binding#local_variable_get reads variables added later to the binding" # Exception: a is not defined
  fails "Binding#local_variable_set overwrites a local variable defined using eval()" # Exception: number is not defined
  fails "Binding#local_variable_set scopes new local variables to the receiving Binding" # Exception: number is not defined
  fails "Binding#local_variable_set sets a local variable using a String as the variable name" # Exception: number is not defined
  fails "Binding#local_variable_set sets a new local variable" # Exception: number is not defined
end
