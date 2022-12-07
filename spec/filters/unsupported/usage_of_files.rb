# NOTE: run bin/format-filters after changing this file
opal_filter "Specs that use temporary files" do
  fails "A Symbol literal inherits the encoding of the magic comment and can have a binary encoding" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x94928>
  fails "Kernel.printf formatting io is not specified flags # applies to format o does nothing for negative argument" # Expected "0..7651" == "..7651" to be truthy but was false
  fails "Kernel.printf formatting io is not specified flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # Expected "1.234e+02" == "1.e+02" to be truthy but was false
  fails "Kernel.printf formatting io is not specified flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified flags (digit)$ specifies the absolute argument number for this field" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified flags * left-justifies the result if specified with $ argument is negative" # Expected "1.095200e+2         " == "1.095200e+02        " to be truthy but was false
  fails "Kernel.printf formatting io is not specified flags * left-justifies the result if width is negative" # Expected "1.095200e+2         " == "1.095200e+02        " to be truthy but was false
  fails "Kernel.printf formatting io is not specified flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but no exception was raised ("       112" was returned)
  fails "Kernel.printf formatting io is not specified flags * uses the previous argument as the field width" # Expected "         1.095200e+02" == "        1.095200e+02" to be truthy but was false
  fails "Kernel.printf formatting io is not specified flags * uses the specified argument as the width if * is followed by a number and $" # Expected "         1.095200e+02" == "        1.095200e+02" to be truthy but was false
  fails "Kernel.printf formatting io is not specified flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified flags - left-justifies the result of conversion if width is specified" # Expected "1.095200e+2         " == "1.095200e+02        " to be truthy but was false
  fails "Kernel.printf formatting io is not specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # Expected "0000000001.095200e+02" == "000000001.095200e+02" to be truthy but was false
  fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified float formats A displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified float formats A displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" == "12.1234" to be truthy but was false
  fails "Kernel.printf formatting io is not specified float formats G otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" == "1.12346" to be truthy but was false
  fails "Kernel.printf formatting io is not specified float formats G otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" == "1.55556" to be truthy but was false
  fails "Kernel.printf formatting io is not specified float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567E+06" == "1.23457E+06" to be truthy but was false
  fails "Kernel.printf formatting io is not specified float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified float formats a displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified float formats a displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" == "12.1234" to be truthy but was false
  fails "Kernel.printf formatting io is not specified float formats g otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" == "1.12346" to be truthy but was false
  fails "Kernel.printf formatting io is not specified float formats g otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" == "1.55556" to be truthy but was false
  fails "Kernel.printf formatting io is not specified float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567e+06" == "1.23457e+06" to be truthy but was false
  fails "Kernel.printf formatting io is not specified integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is not specified integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is not specified integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is not specified other formats % alone raises an ArgumentError" # Expected ArgumentError but no exception was raised ("%" was returned)
  fails "Kernel.printf formatting io is not specified precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.printf formatting io is not specified precision float types does not affect G format" # Expected "12.12340000" == "12.1234" to be truthy but was false
  fails "Kernel.printf formatting io is not specified precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" == "[" to be truthy but was false
  fails "Kernel.printf formatting io is not specified width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" == "        1.095200e+02" to be truthy but was false
  fails "Kernel.printf formatting io is specified faulty key raises a KeyError" # Expected KeyError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified faulty key sets the Hash as the receiver of KeyError" # Expected KeyError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified faulty key sets the unmatched key as the key of KeyError" # Expected KeyError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified flags # applies to format o does nothing for negative argument" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags # applies to format o increases the precision until the first digit will be `0' if it is not formatted as complements" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags # applies to formats bBxX does nothing for zero argument" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags # applies to formats bBxX prefixes the result with 0x, 0X, 0b and 0B respectively for non-zero argument" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags # applies to gG does not remove trailing zeros" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags (digit)$ ignores '-' sign" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags (digit)$ raises ArgumentError exception when absolute and relative argument numbers are mixed" # Expected ArgumentError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified flags (digit)$ raises exception if argument number is bigger than actual arguments list" # Expected ArgumentError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified flags (digit)$ specifies the absolute argument number for this field" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags * left-justifies the result if specified with $ argument is negative" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags * left-justifies the result if width is negative" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified flags * uses the previous argument as the field width" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags * uses the specified argument as the width if * is followed by a number and $" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags + applies to numeric formats bBdiouxXaAeEfgG does not use two's complement form for negative numbers for formats bBoxX" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags - left-justifies the result of conversion if width is specified" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified uses radix-1 when displays negative argument as a two's complement" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA prevents converting negative argument to two's complement form" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats A displays Float::INFINITY as Inf" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats A displays Float::NAN as NaN" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats E converts argument into exponential notation [-]d.dddddde[+-]dd" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats E cuts excessive digits and keeps only 6 ones" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats E displays Float::INFINITY as Inf" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats E displays Float::NAN as NaN" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats E rounds the last significant digit to the closest one" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats G displays Float::INFINITY as Inf" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats G displays Float::NAN as NaN" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats G otherwise converts a floating point number in dd.dddd form" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats G otherwise cuts fraction part to have only 6 digits at all" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats G otherwise rounds the last significant digit to the closest one in fractional part" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats G the exponent is less than -4 converts a floating point number using exponential form" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats a displays Float::INFINITY as Inf" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats a displays Float::NAN as NaN" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats converts argument into Float" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats e converts argument into exponential notation [-]d.dddddde[+-]dd" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats e cuts excessive digits and keeps only 6 ones" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats e displays Float::INFINITY as Inf" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats e displays Float::NAN as NaN" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats e rounds the last significant digit to the closest one" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats f converts floating point argument as [-]ddd.dddddd" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats f cuts excessive digits and keeps only 6 ones" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats f displays Float::INFINITY as Inf" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats f displays Float::NAN as NaN" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats f rounds the last significant digit to the closest one" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats g displays Float::INFINITY as Inf" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats g displays Float::NAN as NaN" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats g otherwise converts a floating point number in dd.dddd form" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats g otherwise cuts fraction part to have only 6 digits at all" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats g otherwise rounds the last significant digit to the closest one in fractional part" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats g the exponent is less than -4 converts a floating point number using exponential form" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified float formats raises TypeError exception if cannot convert to Float" # Expected TypeError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified integer formats B collapse negative number representation if it equals 1" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats B converts argument as a binary number" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats B displays negative number as a two's complement prefixed with '..1'" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats X collapse negative number representation if it equals F" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats X converts argument as a hexadecimal number with uppercase letters" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats X displays negative number as a two's complement prefixed with '..f'" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats b collapse negative number representation if it equals 1" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats b converts argument as a binary number" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats b displays negative number as a two's complement prefixed with '..1'" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats converts String argument with Kernel#Integer" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats converts argument into Integer with to_i if to_int isn't available" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats converts argument into Integer with to_int" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats d converts argument as a decimal number" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats d works well with large numbers" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats i converts argument as a decimal number" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats i works well with large numbers" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats o collapse negative number representation if it equals 7" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats o converts argument as an octal number" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats o displays negative number as a two's complement prefixed with '..7'" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats raises TypeError exception if cannot convert to Integer" # Expected TypeError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified integer formats u converts argument as a decimal number" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats u works well with large numbers" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats x collapse negative number representation if it equals f" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats x converts argument as a hexadecimal number" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified integer formats x displays negative number as a two's complement prefixed with '..f'" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats % alone raises an ArgumentError" # Expected ArgumentError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified other formats % is escaped by %" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats c displays character if argument is a numeric code of character" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats c displays character if argument is a single character string" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats c raises ArgumentError if argument is a string of several characters" # Expected ArgumentError (/%c requires a character/) but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified other formats c raises ArgumentError if argument is an empty string" # Expected ArgumentError (/%c requires a character/) but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified other formats p displays argument.inspect value" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s converts argument to string with to_s" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s does not try to convert with to_str" # Expected NoMethodError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified other formats s substitute argument passes as a string" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified precision float types controls the number of decimal places displayed in fraction part" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified precision float types does not affect G format" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified precision integer types controls the number of decimal places displayed" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified precision string formats determines the maximum number of characters to be copied from the string" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified reference by name %<name>s style allows to place name in any position" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified reference by name %<name>s style cannot be mixed with unnamed style" # Expected ArgumentError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified reference by name %<name>s style supports flags, width, precision and type" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified reference by name %<name>s style uses value passed in a hash argument" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified reference by name %{name} style cannot be mixed with unnamed style" # Expected ArgumentError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified reference by name %{name} style converts value to String with to_s" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified reference by name %{name} style does not support type style" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified reference by name %{name} style raises KeyError when there is no matching key" # Expected KeyError but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified reference by name %{name} style supports flags, width and precision" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified reference by name %{name} style uses value passed in a hash argument" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified width is ignored if argument's actual length is greater" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified width specifies the minimum number of characters that will be written to the result" # Exception: format_string.indexOf is not a function
  fails "The BEGIN keyword returns the top-level script's filename for __FILE__" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xab0bc>
  fails "The return keyword at top level file loading stops file loading and execution" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level file requiring stops file loading and execution" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level stops file execution" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8>
  fails "The return keyword at top level within a begin fires ensure block before returning while loads file" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin fires ensure block before returning" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin is allowed in begin block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin is allowed in ensure block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin is allowed in rescue block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin swallows exception if returns in ensure block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a block is allowed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a class raises a SyntaxError" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within if is allowed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within while loop is allowed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
end
