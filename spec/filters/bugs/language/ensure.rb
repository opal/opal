opal_filter "ensure" do
  fails "An ensure block inside a begin block is executed even when a symbol is thrown in it's corresponding begin block"
  fails "An ensure block inside a method is executed even when a symbol is thrown in the method"
end
