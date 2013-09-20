opal_filter "Array#reject" do
  fails "Array#reject! returns an Enumerator if no block given, and the array is frozen"
end
