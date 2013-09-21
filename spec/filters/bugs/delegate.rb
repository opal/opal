opal_filter "Delegate" do
  fails "SimpleDelegator.new forwards protected method calls"
  fails "SimpleDelegator.new doesn't forward private method calls"
  fails "SimpleDelegator.new doesn't forward private method calls even via send or __send__"
end