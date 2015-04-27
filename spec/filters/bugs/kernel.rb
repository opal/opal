opal_filter "Kernel" do
  fails "Kernel.Array does not call #to_a on an Array" #something funky with the spec itself
  fails "Kernel#Array does not call #to_a on an Array" #something funky with the spec itself
end
