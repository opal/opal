opal_filter "Array#delete_if" do
  fails "Array#delete_if returns an Enumerator if no block given, and the enumerator can modify the original array"
end
