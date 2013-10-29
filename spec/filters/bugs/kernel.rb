opal_filter "Kernel" do
  fails "Kernel.rand returns a float if no argument is passed"
  fails "Kernel.rand returns an integer for an integer argument"

  fails "Kernel#<=> returns 0 if self is == to the argument"
  fails "Kernel#<=> returns nil if self is eql? but not == to the argument"
  fails "Kernel#<=> returns nil if self.==(arg) returns nil"

  fails "Kernel#equal? returns true only if obj and other are the same object"
end
