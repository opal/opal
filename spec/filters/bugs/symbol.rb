# NOTE: run bin/format-filters after changing this file
opal_filter "Symbol" do
  fails "Symbol#to_proc produces a Proc that always returns [[:req], [:rest]] for #parameters" # Expected [["rest", "args"], ["block", "block"]] == [["req"], ["rest"]] to be truthy but was false
  fails "Symbol#to_proc produces a Proc with arity -2" # Expected -1 == -2 to be truthy but was false
  fails "Symbol#to_proc returns a Proc with #lambda? true" # Expected #<Proc:0xd6f0>.lambda? to be truthy but was false
end
