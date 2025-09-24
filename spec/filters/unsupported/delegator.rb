# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Delegator" do
  fails "SimpleDelegator.new doesn't forward private method calls even via send or __send__" # Expected NoMethodError but no exception was raised (["priv", 42] was returned)
  fails "SimpleDelegator.new doesn't forward private method calls" # Expected NoMethodError but no exception was raised (["priv", nil] was returned)
  fails "SimpleDelegator.new forwards protected method calls" # Expected NoMethodError but no exception was raised ("protected" was returned)  
end
