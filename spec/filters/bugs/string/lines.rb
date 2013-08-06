opal_filter "String#lines" do
  fails "String#lines should split on the default record separator and return enumerator if not block is given"
end
