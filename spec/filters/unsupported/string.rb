# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "String" do
  fails "BasicObject#__id__ returns a different value for two String literals"
  fails "Module#const_defined? returns true when passed a constant name with EUC-JP characters"
  fails "String#% supports negative bignums with %u or %d"
  fails "String#-@ deduplicates frozen strings" # May fail randomly outside of "use strict"
  fails "String#-@ returns a frozen copy if the String is not frozen" # May fail randomly outside of "use strict"
  fails "String#[] with Symbol raises TypeError"
  fails "String#index raises a TypeError if passed a Symbol"
  fails "String#index with Regexp supports \\G which matches at the given start offset"
  fails "String#initialize is a private method"
  fails "String#initialize with an argument carries over the encoding invalidity"
  fails "String#initialize with an argument raises a RuntimeError on a frozen instance that is modified"
  fails "String#initialize with an argument raises a RuntimeError on a frozen instance when self-replacing"
  fails "String#initialize with an argument raises a TypeError if other can't be converted to string"
  fails "String#initialize with an argument replaces the content of self with other"
  fails "String#initialize with an argument replaces the encoding of self with that of other"
  fails "String#initialize with an argument returns self"
  fails "String#initialize with an argument tries to convert other to string using to_str"
  fails "String#lines does not care if the string is modified while substituting"
  fails "String#lines raises a TypeError when the separator is a symbol"
  fails "String#match matches \\G at the start of the string"
  fails "String#next! is equivalent to succ, but modifies self in place (still returns self)"
  fails "String#next! raises a RuntimeError if self is frozen"
  fails "String#rindex with Regexp supports \\G which matches at the given start offset"
  fails "String#scan supports \\G which matches the end of the previous match / string start for first match"
  fails "String#slice with Symbol raises TypeError"
  fails "String#sub with pattern and Hash ignores non-String keys" # Expected "tazoo" == "taboo" to be truthy but was false
  fails "String#sub with pattern and block doesn't raise a RuntimeError if the string is modified while substituting" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#sub with pattern, replacement raises a TypeError when pattern is a Symbol"
  fails "String#to_i with bases parses a String in base 10" # Expected "1.2345678901234567e+99" == "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" to be truthy but was false
  fails "String#to_i with bases parses a String in base 11" # Expected "1234567890a1234720000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890a1234567890a1234567890a1234567890a1234567890a1234567890a1234567890a1234567890a1234567890a" to be truthy but was false
  fails "String#to_i with bases parses a String in base 12" # Expected "1234567890ab121800000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890ab1234567890ab1234567890ab1234567890ab1234567890ab1234567890ab1234567890ab1234567890ab" to be truthy but was false
  fails "String#to_i with bases parses a String in base 13" # Expected "1234567890abc110000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abc1234567890abc1234567890abc1234567890abc1234567890abc1234567890abc1234567890abc" to be truthy but was false
  fails "String#to_i with bases parses a String in base 14" # Expected "1234567890abcdc00000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd" to be truthy but was false
  fails "String#to_i with bases parses a String in base 15" # Expected "1234567890abcd9000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcde1234567890abcde1234567890abcde1234567890abcde1234567890abcde1234567890abcde" to be truthy but was false
  fails "String#to_i with bases parses a String in base 16" # Expected "1234567890abce0000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef" to be truthy but was false
  fails "String#to_i with bases parses a String in base 17" # Expected "1234567890abcg00000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefg1234567890abcdefg1234567890abcdefg1234567890abcdefg1234567890abcdefg" to be truthy but was false
  fails "String#to_i with bases parses a String in base 18" # Expected "1234567890abc40000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefgh1234567890abcdefgh1234567890abcdefgh1234567890abcdefgh1234567890abcdefgh" to be truthy but was false
  fails "String#to_i with bases parses a String in base 19" # Expected "1234567890abcc000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghi1234567890abcdefghi1234567890abcdefghi1234567890abcdefghi1234567890abcdefghi" to be truthy but was false
  fails "String#to_i with bases parses a String in base 2" # Expected "1010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000" == "1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010" to be truthy but was false
  fails "String#to_i with bases parses a String in base 20" # Expected "1234567890abcg00000000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij" to be truthy but was false
  fails "String#to_i with bases parses a String in base 21" # Expected "1234567890abad0000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijk1234567890abcdefghijk1234567890abcdefghijk1234567890abcdefghijk" to be truthy but was false
  fails "String#to_i with bases parses a String in base 22" # Expected "1234567890abg000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijkl1234567890abcdefghijkl1234567890abcdefghijkl1234567890abcdefghijkl" to be truthy but was false
  fails "String#to_i with bases parses a String in base 23" # Expected "1234567890abk0000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklm1234567890abcdefghijklm1234567890abcdefghijklm1234567890abcdefghijklm" to be truthy but was false
  fails "String#to_i with bases parses a String in base 24" # Expected "1234567890acg00000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmn1234567890abcdefghijklmn1234567890abcdefghijklmn1234567890abcdefghijklmn" to be truthy but was false
  fails "String#to_i with bases parses a String in base 25" # Expected "1234567890ae3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmno1234567890abcdefghijklmno1234567890abcdefghijklmno1234567890abcdefghijklmno" to be truthy but was false
  fails "String#to_i with bases parses a String in base 26" # Expected "1234567890aba00000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnop1234567890abcdefghijklmnop1234567890abcdefghijklmnop" to be truthy but was false
  fails "String#to_i with bases parses a String in base 27" # Expected "1234567890aen00000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopq1234567890abcdefghijklmnopq1234567890abcdefghijklmnopq" to be truthy but was false
  fails "String#to_i with bases parses a String in base 28" # Expected "1234567890a6o00000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqr1234567890abcdefghijklmnopqr1234567890abcdefghijklmnopqr" to be truthy but was false
  fails "String#to_i with bases parses a String in base 29" # Expected "1234567890ab000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrs1234567890abcdefghijklmnopqrs1234567890abcdefghijklmnopqrs" to be truthy but was false
  fails "String#to_i with bases parses a String in base 3" # Expected "120120120120120120120120120120121200000000000000000000000000000000000000000000000000000000000000000" == "120120120120120120120120120120120120120120120120120120120120120120120120120120120120120120120120120" to be truthy but was false
  fails "String#to_i with bases parses a String in base 30" # Expected "1234567890a8000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrst1234567890abcdefghijklmnopqrst1234567890abcdefghijklmnopqrst" to be truthy but was false
  fails "String#to_i with bases parses a String in base 31" # Expected "1234567890a7000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstu1234567890abcdefghijklmnopqrstu1234567890abcdefghijklmnopqrstu" to be truthy but was false
  fails "String#to_i with bases parses a String in base 32" # Expected "1234567890a8000000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuv1234567890abcdefghijklmnopqrstuv1234567890abcdefghijklmnopqrstuv" to be truthy but was false
  fails "String#to_i with bases parses a String in base 33" # Expected "1234567890ah000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuvw1234567890abcdefghijklmnopqrstuvw1234567890abcdefghijklmnopqrstuvw" to be truthy but was false
  fails "String#to_i with bases parses a String in base 34" # Expected "1234567890a400000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuvwx1234567890abcdefghijklmnopqrstuvwx" to be truthy but was false
  fails "String#to_i with bases parses a String in base 35" # Expected "12345678908x0000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuvwxy1234567890abcdefghijklmnopqrstuvwxy" to be truthy but was false
  fails "String#to_i with bases parses a String in base 36" # Expected "1234567890ao000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz" to be truthy but was false
  fails "String#to_i with bases parses a String in base 4" # Expected "1230123012301230123012301230000000000000000000000000000000000000000000000000000000000000000000000000" == "1230123012301230123012301230123012301230123012301230123012301230123012301230123012301230123012301230" to be truthy but was false
  fails "String#to_i with bases parses a String in base 5" # Expected "1234012340123401234012100000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234012340123401234012340123401234012340123401234012340123401234012340123401234012340123401234012340" to be truthy but was false
  fails "String#to_i with bases parses a String in base 6" # Expected "123450123450123450122400000000000000000000000000000000000000000000000000000000000000000000000000" == "123450123450123450123450123450123450123450123450123450123450123450123450123450123450123450123450" to be truthy but was false
  fails "String#to_i with bases parses a String in base 7" # Expected "12345601234560123501000000000000000000000000000000000000000000000000000000000000000000000000000000" == "12345601234560123456012345601234560123456012345601234560123456012345601234560123456012345601234560" to be truthy but was false
  fails "String#to_i with bases parses a String in base 8" # Expected "123456701234567012400000000000000000000000000000000000000000000000000000000000000000000000000000" == "123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670" to be truthy but was false
  fails "String#to_i with bases parses a String in base 9" # Expected "123456780123456780000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "123456780123456780123456780123456780123456780123456780123456780123456780123456780123456780123456780" to be truthy but was false  
  fails "String#upto does not work with symbols"
  fails "String.allocate returns a binary String"
  fails "String.allocate returns a fully-formed String"
  fails "String.new returns a binary String"
  fails "String.new returns a fully-formed String"
  fails "String.new returns a new string given a string argument"
end
