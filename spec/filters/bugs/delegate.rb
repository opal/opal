# NOTE: run bin/format-filters after changing this file
opal_filter "Delegate" do
  fails "Delegator#!= is delegated in general" # Exception: Maximum call stack size exceeded
  fails "Delegator#== is delegated in general" # Exception: Maximum call stack size exceeded
  fails "Delegator#method raises a NameError if method is no longer valid because object has changed" # Expected NameError but no exception was raised ("foo" was returned)
  fails "Delegator#method returns a method object for public methods of the delegate object" # NameError: undefined method `pub' for class `DelegateSpecs::Delegator'
  fails "Delegator#method returns a method that respond_to_missing?" # NameError: undefined method `pub_too' for class `DelegateSpecs::Simple'
end
