opal_filter "Kernel#Integer() fix broke mspec" do
  fails "Array#shuffle calls #to_f on the Object returned by #rand"
  fails "Array#shuffle raises a RangeError if the random generator returns a value less than 0.0"
  fails "Array#shuffle raises a RangeError if the random generator returns a value equal to 1.0"
  fails "Array#shuffle raises a RangeError if the random generator returns a value greater than 1.0"
  fails "A singleton class has class Bignum as the superclass of a Bignum instance"
  fails "Hash.[] ignores elements that are arrays of more than 2 elements"
  fails "Hash.[] creates a Hash; values can be provided as a list of value-invalid-pairs in an array"
  fails "Hash#default_proc= raises an error if passed nil"
  fails "ERB::Util.html_escape not escape characters except '& < > \"'"
end
