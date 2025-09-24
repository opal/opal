# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Symbol" do
  fails "A Symbol literal can be an empty string" # Expected "\"\"" == ":\"\"" to be truthy but was false
  fails "A Symbol literal can be created by the %s-delimited expression" # Expected "\"foo bar\"" == ":\"foo bar\"" to be truthy but was false
  fails "A Symbol literal can contain null in the string" # Expected "\"\\u0000\"" == ":\"\\x00\"" to be truthy but was false
  fails "A Symbol literal is a ':' followed by a single- or double-quoted string that may contain otherwise invalid characters" # Expected "\"foo bar\"" == ":\"foo bar\"" to be truthy but was false
  fails "A Symbol literal is a ':' followed by any number of valid characters" # Expected "\"foo\"" == ":foo" to be truthy but was false
  fails "A Symbol literal is converted to a literal, unquoted representation if the symbol contains only valid characters" # Expected "\"foo\"" == ":foo" to be truthy but was false
  fails "Marshal.dump with a Symbol dumps a Symbol" # Expected "\x04\b\"\vsymbol" == "\x04\b:\vsymbol" to be truthy but was false
  fails "Marshal.dump with a Symbol dumps a big Symbol" # Expected "\x04\b\"\x02,\x01bigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbig" == "\u0004\b:\u0002,\u0001bigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbig" to be truthy but was false
  fails "Marshal.dump with a Symbol dumps a binary encoded Symbol" # Expected "\x04\b\"\x06→" == "\x04\b:\bâ\x86\x92" to be truthy but was false
  fails "Marshal.dump with a Symbol dumps an encoded Symbol" # ArgumentError: unknown encoding name - utf-16
  fails "Marshal.dump with an Array dumps a non-empty Array" # Expected "\x04\b[\b\"\x06ai\x06i\a" == "\x04\b[\b:\x06ai\x06i\a" to be truthy but was false
  fails "Module#const_get raises a NameError if a Symbol has a toplevel scope qualifier" # Expected NameError but no exception was raised ("const1" was returned)
  fails "Module#const_get raises a NameError if a Symbol is a scoped constant name" # Expected NameError but no exception was raised ("const10_10" was returned)
  fails "Numeric#coerce raises a TypeError when passed a Symbol" # Expected TypeError but got: ArgumentError (invalid value for Float(): "symbol")
  fails "The throw keyword does not convert strings to a symbol" # Expected ArgumentError but no exception was raised (nil was returned)
end
