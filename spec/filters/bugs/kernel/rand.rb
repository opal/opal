opal_filter "Kernel#rand" do
  fails "Kernel.rand returns a float if no argument is passed"
  fails "Kernel.rand returns an integer for an integer argument"
end
