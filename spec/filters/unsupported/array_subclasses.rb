opal_filter "Array subclasses" do
  fails "Array.[] returns a new array populated with the given elements"
  fails "Array[] is a synonym for .[]"
  fails "Array.new returns an instance of a subclass"
  fails "Array#values_at does not return subclass instance on Array subclasses"
end
