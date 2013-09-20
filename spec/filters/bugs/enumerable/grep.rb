opal_filter "Enumerable#grep" do
  fails "Enumerable#grep can use $~ in the block when used with a Regexp"
end
