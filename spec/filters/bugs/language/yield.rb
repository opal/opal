opal_filter "yield" do
  fails "The yield call taking no arguments ignores assignment to the explicit block argument and calls the passed block"
  fails "The yield call taking a single splatted argument passes no values when give nil as an argument"
  fails "The yield call taking multiple arguments with a splat does not pass an argument value if the splatted argument is nil"
end
