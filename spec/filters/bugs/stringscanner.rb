opal_filter "StringScanner" do
  fails "StringScanner#[] calls to_int on the given index"
  fails "StringScanner#[] raises a TypeError if the given index is nil"
  fails "StringScanner#[] raises a TypeError when a Range is as argument"

  fails "StringScanner#pos returns the position of the scan pointer"
  fails "StringScanner#pos= raises a RangeError if position too far backward"
  fails "StringScanner#pos= raises a RangeError when the passed argument is out of range"

  fails "StringScanner#scan raises a TypeError if pattern isn't a Regexp"

  fails "StringScanner#peek taints the returned String if the input was tainted"
  fails "StringScanner#peek returns an instance of String when passed a String subclass"
  fails "StringScanner#peek raises a RangeError when the passed argument is a Bignum"
  fails "StringScanner#peek raises a ArgumentError when the passed argument is negative"

  fails "StringScanner#rest taints the returned String if the input was tainted"
  fails "StringScanner#rest returns an instance of String when passed a String subclass"

  fails "StringScanner#[] raises a IndexError when there's no named capture"
  fails "StringScanner#[] returns named capture"
end
