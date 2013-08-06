opal_filter "order" do
  fails "A method call evaluates block pass after arguments"
  fails "A method call evaluates arguments after receiver"
end
