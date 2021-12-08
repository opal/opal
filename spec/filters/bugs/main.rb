# NOTE: run bin/format-filters after changing this file
opal_filter "main" do
  fails "main#include in a file loaded with wrapping includes the given Module in the load wrapper" # ArgumentError: [MSpecEnv#load] wrong number of arguments(2 for 1)
  fails "main#private raises a NameError when at least one of given method names is undefined" # Expected NameError but no exception was raised (nil was returned)
  fails "main#private when multiple arguments are passed sets the visibility of the given methods to private" # Expected Object to have private method 'main_public_method' but it does not
  fails "main#private when single argument is passed and is an array sets the visibility of the given methods to private" # Expected Object to have private method 'main_public_method' but it does not
  fails "main#private when single argument is passed and it is not an array sets the visibility of the given methods to private" # Expected Object to have private method 'main_public_method' but it does not
  fails "main#public raises a NameError when given an undefined name" # Expected NameError but no exception was raised (nil was returned)
  fails "main.ruby2_keywords is the same as Object.ruby2_keywords" # Expected main to have private method 'ruby2_keywords' but it does not
  fails "main.using does not propagate refinements of new modules added after it is called" # Expected "quux" == "bar" to be truthy but was false
  fails "main.using requires one Module argument" # Expected TypeError but no exception was raised (main was returned)
  fails "main.using uses refinements from the given module for method calls in the target file" # LoadError: cannot load such file -- ruby/core/main/fixtures/string_refinement_user
  fails "main.using uses refinements from the given module only in the target file" # LoadError: cannot load such file -- ruby/core/main/fixtures/string_refinement_user
end
