# NOTE: run bin/format-filters after changing this file
opal_filter "main" do
  fails "main#include in a file loaded with wrapping includes the given Module in the load wrapper" # ArgumentError: [MSpecEnv#load] wrong number of arguments (given 2, expected 1)
  fails "main.ruby2_keywords is the same as Object.ruby2_keywords" # Expected main to have private method 'ruby2_keywords' but it does not
  fails "main.using does not propagate refinements of new modules added after it is called" # Expected "quux" == "bar" to be truthy but was false
  fails "main.using raises error when called from method in wrapped script" # Expected RuntimeError but got: ArgumentError ([MSpecEnv#load] wrong number of arguments (given 2, expected 1))
  fails "main.using raises error when called on toplevel from module" # Expected RuntimeError but got: ArgumentError ([MSpecEnv#load] wrong number of arguments (given 2, expected 1))
  fails "main.using requires one Module argument" # Expected TypeError but no exception was raised (main was returned)
  fails "main.using uses refinements from the given module for method calls in the target file" # LoadError: cannot load such file -- ruby/core/main/fixtures/string_refinement_user
  fails "main.using uses refinements from the given module only in the target file" # LoadError: cannot load such file -- ruby/core/main/fixtures/string_refinement_user
end
