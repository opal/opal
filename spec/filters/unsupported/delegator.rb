opal_unsupported_filter "Delegator" do
  fails "SimpleDelegator.new doesn't forward private method calls even via send or __send__"
  fails "SimpleDelegator.new doesn't forward private method calls"
  fails "SimpleDelegator.new forwards protected method calls"
end
