opal_filter "fixnum and array size" do
  fails "Array#slice raises a RangeError when the length is out of range of Fixnum"
  fails "Array#slice raises a RangeError when the start index is out of range of Fixnum"
  fails "Array#fill with (filler, index, length) raises an ArgumentError or RangeError for too-large sizes"
  fails "Array#[] raises a RangeError when the length is out of range of Fixnum"
  fails "Array#[] raises a RangeError when the start index is out of range of Fixnum"
end
