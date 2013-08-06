opal_filter "Array#to_a" do
  fails "Array#to_a does not return subclass instance on Array subclasses"
end
