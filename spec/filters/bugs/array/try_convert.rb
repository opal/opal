opal_filter "Array.try_convert" do
  fails "Array.try_convert does not rescue exceptions raised by #to_ary"
  fails "Array.try_convert sends #to_ary to the argument and raises TypeError if it's not a kind of Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's a kind of Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's an Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's nil"
end
