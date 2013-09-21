opal_filter "Kernel" do
  fails "A class definition allows the definition of class-level instance variables in a class method"

  fails "Kernel.rand returns a float if no argument is passed"
  fails "Kernel.rand returns an integer for an integer argument"
end
