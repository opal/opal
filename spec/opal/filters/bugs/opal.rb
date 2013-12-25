opal_filter "Opal bugs" do
  fails "Array#join raises a NoMethodError if an element does not respond to #to_str, #to_ary, or #to_s"
end
