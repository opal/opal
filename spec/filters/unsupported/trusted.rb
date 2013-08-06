opal_filter "Object#trusted/untrusted" do
  fails "Array#pop passed a number n as an argument keeps untrusted status"
  fails "Array#pop passed a number n as an argument returns a trusted array even if the array is untrusted"
  fails "Array#pop keeps untrusted status"
  fails "Array#+ does not infected even if an original array is untrusted"
  fails "Array#* with an integer copies the untrusted status of the original array if the passed count is not 0"
  fails "Array#* with an integer copies the untrusted status of the original array even if the array is empty"
  fails "Array#* with an integer copies the untrusted status of the original array even if the passed count is 0"
  fails "Array#delete keeps untrusted status"
  fails "Array#delete_if keeps untrusted status"
end
