opal_filter "taint" do
  fails "Range#to_s ignores own tainted status"
  fails "Range#inspect ignores own tainted status"

  fails "String#% doesn't taint the result for %e when argument is tainted"
  fails "String#% doesn't taint the result for %E when argument is tainted"
  fails "String#% doesn't taint the result for %f when argument is tainted"
  fails "String#% doesn't taint the result for %g when argument is tainted"
  fails "String#% doesn't taint the result for %G when argument is tainted"
end
