opal_filter "Kernel" do
  fails "Kernel.Array does not call #to_a on an Array" #something funky with the spec itself
  fails "Kernel#Array does not call #to_a on an Array" #something funky with the spec itself

  fails "Kernel.String raises a TypeError if #to_s does not exist"
  fails "Kernel.String raises a TypeError if respond_to? returns false for #to_s"
  fails "Kernel.String raises a TypeError if #to_s is not defined, even though #respond_to?(:to_s) returns true"
  fails "Kernel.String calls #to_s if #respond_to?(:to_s) returns true"
  fails "Kernel#String raises a TypeError if #to_s does not exist"
  fails "Kernel#String raises a TypeError if respond_to? returns false for #to_s"
  fails "Kernel#String raises a TypeError if #to_s is not defined, even though #respond_to?(:to_s) returns true"
  fails "Kernel#String calls #to_s if #respond_to?(:to_s) returns true"
end
