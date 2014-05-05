opal_filter "StringScanner" do
  fails "StringScanner#[] calls to_int on the given index"
  fails "StringScanner#[] raises a TypeError if the given index is nil"
  fails "StringScanner#[] raises a TypeError when a Range is as argument"
  fails "StringScanner#[] raises a TypeError when a String is as argument"

  fails "StringScanner#get_byte is not multi-byte character sensitive"

  fails "StringScanner#pos returns the position of the scan pointer"
  fails "StringScanner#pos returns the position of the scan pointer for multibyte string"
  fails "StringScanner#pos returns 0 in the reset position"
  fails "StringScanner#pos returns the length of the string in the terminate position"
  fails "StringScanner#pos returns the `bytesize` for multibyte string in the terminate position"
  fails "StringScanner#pos= raises a RangeError if position too far backward"
  fails "StringScanner#pos= raises a RangeError when the passed argument is out of range"

  fails "StringScanner#scan returns the matched string for a multi byte string"
  fails "StringScanner#scan raises a TypeError if pattern isn't a Regexp"

  fails "StringScanner#pos= can poin position that greater than string length for multibyte string"
  fails "StringScanner#pos= positions from the end if the argument is negative for multibyte string"
end
