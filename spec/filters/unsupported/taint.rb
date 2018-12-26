opal_unsupported_filter "taint" do
  fails "Hash#reject with extra state does not taint the resulting hash"
  fails "Kernel#inspect returns a tainted string if self is tainted"
  fails "Module#append_features copies own tainted status to the given module"
  fails "Module#append_features copies own untrusted status to the given module"
  fails "Module#extend_object does not copy own tainted status to the given object"
  fails "Module#extend_object does not copy own untrusted status to the given object"
  fails "Module#prepend_features copies own tainted status to the given module"
  fails "Module#prepend_features copies own untrusted status to the given module"
  fails "String#% doesn't taint the result for %E when argument is tainted"
  fails "String#% doesn't taint the result for %G when argument is tainted"
  fails "String#% doesn't taint the result for %e when argument is tainted"
  fails "String#% doesn't taint the result for %f when argument is tainted"
  fails "String#% doesn't taint the result for %g when argument is tainted"
  fails "String#[] with Regexp always taints resulting strings when self or regexp is tainted"
  fails "String#[] with Regexp returns an untrusted string if the regexp is untrusted"
  fails "String#byteslice with Range always taints resulting strings when self is tainted"
  fails "String#byteslice with index, length always taints resulting strings when self is tainted"
  fails "String#dump taints the result if self is tainted"
  fails "String#slice with Regexp always taints resulting strings when self or regexp is tainted"
  fails "String#slice with Regexp returns an untrusted string if the regexp is untrusted"
  fails "StringScanner#getbyte taints the returned String if the input was tainted"
  fails "StringScanner#getch taints the returned String if the input was tainted"
  fails "StringScanner#matched taints the returned String if the input was tainted"
  fails "StringScanner#peek taints the returned String if the input was tainted"
  fails "StringScanner#peep taints the returned String if the input was tainted"
  fails "StringScanner#post_match taints the returned String if the input was tainted"
  fails "StringScanner#pre_match taints the returned String if the input was tainted"
  fails "StringScanner#rest taints the returned String if the input was tainted"
  fails "Array#pack with format 'a' returns a tainted string when a pack argument is tainted"
  fails "Array#pack with format 'a' returns a tainted string when an empty format is tainted"
  fails "Array#pack with format 'a' returns a tainted string when the format is tainted"
  fails "Array#pack with format 'a' returns a trusted string when the array is untrusted"
  fails "Array#pack with format 'a' returns a untrusted string when a pack argument is untrusted"
  fails "Array#pack with format 'a' returns a untrusted string when the empty format is untrusted"
  fails "Array#pack with format 'a' returns a untrusted string when the format is untrusted"
  fails "Array#pack with format 'a' taints the output string if the format string is tainted"
  fails "Array#pack with format 'A' returns a tainted string when a pack argument is tainted"
  fails "Array#pack with format 'A' returns a tainted string when an empty format is tainted"
  fails "Array#pack with format 'A' returns a tainted string when the format is tainted"
  fails "Array#pack with format 'A' returns a trusted string when the array is untrusted"
  fails "Array#pack with format 'A' returns a untrusted string when a pack argument is untrusted"
  fails "Array#pack with format 'A' returns a untrusted string when the empty format is untrusted"
  fails "Array#pack with format 'A' returns a untrusted string when the format is untrusted"
  fails "Array#pack with format 'A' taints the output string if the format string is tainted"
  fails "Array#pack with format 'C' taints the output string if the format string is tainted"
  fails "Array#pack with format 'c' taints the output string if the format string is tainted"
  fails "Array#pack with format 'L' taints the output string if the format string is tainted"
  fails "Array#pack with format 'l' taints the output string if the format string is tainted"
  fails "Array#pack with format 'U' taints the output string if the format string is tainted"
  fails "Array#pack with format 'u' taints the output string if the format string is tainted"
  fails "String#delete_prefix taints resulting strings when other is tainted" # NoMethodError: undefined method `delete_prefix' for "hello":String
  fails "String#delete_suffix taints resulting strings when other is tainted" # NoMethodError: undefined method `delete_suffix' for "hello":String
  fails "Array#pack with format 'u' returns a trusted string when the array is untrusted" # NoMethodError: undefined method `untrust' for ["abcd", 32]
  fails "Array#pack with format 'u' returns a untrusted string when a pack argument is untrusted" # NoMethodError: undefined method `untrust' for "abcd"
  fails "Array#pack with format 'u' returns a untrusted string when the empty format is untrusted" # NoMethodError: undefined method `untrust' for ""
  fails "Array#pack with format 'u' returns a untrusted string when the format is untrusted" # NoMethodError: undefined method `untrust' for "u3C"
  fails "String#unpack with format 'A' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "A2"
  fails "String#unpack with format 'A' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'A' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'A' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'A' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "A2"
  fails "String#unpack with format 'A' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'A' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'A' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'B' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "B2"
  fails "String#unpack with format 'B' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'B' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'B' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'B' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "B2"
  fails "String#unpack with format 'B' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'B' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'B' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'H' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "H2"
  fails "String#unpack with format 'H' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'H' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'H' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'H' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "H2"
  fails "String#unpack with format 'H' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'H' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'H' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'M' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "M2"
  fails "String#unpack with format 'M' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'M' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'M' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'M' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "M2"
  fails "String#unpack with format 'M' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'M' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'M' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'U' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "U2"
  fails "String#unpack with format 'U' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'U' does not untrust returned arrays if given an trusted packed string" # Exception: Cannot read property '$__id__' of undefined
  fails "String#unpack with format 'U' does not untrust returned arrays if given an untrusted format string" # Exception: Cannot read property '$__id__' of undefined
  fails "String#unpack with format 'U' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "U2"
  fails "String#unpack with format 'U' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for nil
  fails "String#unpack with format 'U' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for nil
  fails "String#unpack with format 'U' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'Z' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "Z2"
  fails "String#unpack with format 'Z' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'Z' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'Z' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'Z' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "Z2"
  fails "String#unpack with format 'Z' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'Z' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'Z' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'a' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "a2"
  fails "String#unpack with format 'a' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'a' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'a' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'a' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "a2"
  fails "String#unpack with format 'a' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'a' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'a' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'b' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "b2"
  fails "String#unpack with format 'b' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'b' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'b' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'b' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "b2"
  fails "String#unpack with format 'b' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'b' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'b' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'h' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "h2"
  fails "String#unpack with format 'h' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'h' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'h' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'h' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "h2"
  fails "String#unpack with format 'h' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'h' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'h' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'm' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "m2"
  fails "String#unpack with format 'm' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'm' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'm' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'm' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "m2"
  fails "String#unpack with format 'm' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'm' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'm' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'u' does not untrust returned arrays if given a untrusted format string" # NoMethodError: undefined method `untrust' for "u2"
  fails "String#unpack with format 'u' does not untrust returned arrays if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "String#unpack with format 'u' does not untrust returned arrays if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'u' does not untrust returned arrays if given an untrusted format string" # NoMethodError: undefined method `untrusted?' for [""]
  fails "String#unpack with format 'u' does not untrust returned strings if given a untrusted format string" # NoMethodError: undefined method `untrust' for "u2"
  fails "String#unpack with format 'u' does not untrust returned strings if given an trusted packed string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'u' does not untrust returned strings if given an untainted format string" # NoMethodError: undefined method `untrusted?' for ""
  fails "String#unpack with format 'u' untrusts returned strings if given a untrusted packed string" # NoMethodError: undefined method `untrust' for ""
  fails "Array#pack with format 'u' does not return a tainted string when the array is tainted" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' returns a tainted string when a pack argument is tainted" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' returns a tainted string when an empty format is tainted" # Expected false to be true
  fails "Array#pack with format 'u' returns a tainted string when the format is tainted" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "String#unpack with format 'A' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'B' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'H' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'M' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'U' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'Z' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'a' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'b' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'h' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'm' taints returned strings if given a tainted packed string" # Expected false to be true
  fails "String#unpack with format 'u' taints returned strings if given a tainted packed string" # Expected false to be true
end
