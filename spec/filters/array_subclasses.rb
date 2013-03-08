opal_filter "Array subclasses" do
  fails "Array.[] returns a new array populated with the given elements"
  fails "Array[] is a synonym for .[]"
end
