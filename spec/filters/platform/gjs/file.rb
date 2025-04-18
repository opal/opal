# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#atime returns the last access time to self" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "File#chmod invokes to_int on non-integer argument" # NoMethodError: undefined method `close' for nil
  fails "File#chmod modifies the permission bits of the files specified" # NoMethodError: undefined method `close' for nil
  fails "File#chmod raises RangeError with too large values" # NoMethodError: undefined method `close' for nil
  fails "File#chmod returns 0 if successful" # NoMethodError: undefined method `close' for nil
  fails "File#chmod with '0111' makes file executable but not readable or writable" # NoMethodError: undefined method `close' for nil
  fails "File#chmod with '0222' makes file writable but not readable or executable" # NoMethodError: undefined method `close' for nil
  fails "File#chmod with '0444' makes file readable but not writable or executable" # NoMethodError: undefined method `close' for nil
  fails "File#chmod with '0666' makes file readable and writable but not executable" # NoMethodError: undefined method `close' for nil
  fails "File#chown returns 0" # NoMethodError: undefined method `closed?' for nil
  fails "File#ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself)." # NoMethodError: undefined method `close' for nil
  fails "File#initialize accepts encoding options as a hash parameter" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "File#initialize accepts encoding options in mode parameter" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "File#inspect returns a String" # NoMethodError: undefined method `closed?' for nil
  fails "File#mtime returns the modification Time of the file" # NoMethodError: undefined method `close' for nil
  fails "File#path calls to_str on argument and returns exact value" # NotImplementedError: File.lstat is not available on this platform
  fails "File#path does not absolute-ise the path it returns" # NotImplementedError: File.lstat is not available on this platform
  fails "File#path does not canonicalize the path it returns" # NotImplementedError: File.lstat is not available on this platform
  fails "File#path does not normalise the path it returns" # NotImplementedError: File.lstat is not available on this platform
  fails "File#path preserves the encoding of the path" # NotImplementedError: File.lstat is not available on this platform
  fails "File#path returns a String" # NotImplementedError: File.lstat is not available on this platform
  fails "File#printf faulty key raises a KeyError" # Expected KeyError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf faulty key sets the Hash as the receiver of KeyError" # Expected KeyError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf faulty key sets the unmatched key as the key of KeyError" # Expected KeyError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf flags # applies to format o does nothing for negative argument" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags # applies to format o increases the precision until the first digit will be `0' if it is not formatted as complements" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags # applies to formats bBxX does nothing for zero argument" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags # applies to formats bBxX prefixes the result with 0x, 0X, 0b and 0B respectively for non-zero argument" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags # applies to gG does not remove trailing zeros" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags (digit)$ ignores '-' sign" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags (digit)$ raises ArgumentError exception when absolute and relative argument numbers are mixed" # Expected ArgumentError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf flags (digit)$ raises exception if argument number is bigger than actual arguments list" # Expected ArgumentError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf flags (digit)$ specifies the absolute argument number for this field" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags * left-justifies the result if specified with $ argument is negative" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags * left-justifies the result if width is negative" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf flags * uses the previous argument as the field width" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags * uses the specified argument as the width if * is followed by a number and $" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags + applies to numeric formats bBdiouxXaAeEfgG does not use two's complement form for negative numbers for formats bBoxX" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags - left-justifies the result of conversion if width is specified" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified uses radix-1 when displays negative argument as a two's complement" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags space applies to numeric formats bBdiouxXeEfgGaA prevents converting negative argument to two's complement form" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats A displays Float::INFINITY as Inf" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats A displays Float::NAN as NaN" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats E converts argument into exponential notation [-]d.dddddde[+-]dd" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats E cuts excessive digits and keeps only 6 ones" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats E displays Float::INFINITY as Inf" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats E displays Float::NAN as NaN" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats E rounds the last significant digit to the closest one" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats G displays Float::INFINITY as Inf" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats G displays Float::NAN as NaN" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats G otherwise converts a floating point number in dd.dddd form" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats G otherwise cuts fraction part to have only 6 digits at all" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats G otherwise rounds the last significant digit to the closest one in fractional part" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats G the exponent is less than -4 converts a floating point number using exponential form" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats a displays Float::INFINITY as Inf" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats a displays Float::NAN as NaN" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats converts argument into Float" # Mock 'float' expected to receive to_f("any_args") exactly 1 times but received it 0 times
  fails "File#printf float formats e converts argument into exponential notation [-]d.dddddde[+-]dd" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats e cuts excessive digits and keeps only 6 ones" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats e displays Float::INFINITY as Inf" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats e displays Float::NAN as NaN" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats e rounds the last significant digit to the closest one" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats f converts floating point argument as [-]ddd.dddddd" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats f cuts excessive digits and keeps only 6 ones" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats f displays Float::INFINITY as Inf" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats f displays Float::NAN as NaN" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats f rounds the last significant digit to the closest one" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats g displays Float::INFINITY as Inf" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats g displays Float::NAN as NaN" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats g otherwise converts a floating point number in dd.dddd form" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats g otherwise cuts fraction part to have only 6 digits at all" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats g otherwise rounds the last significant digit to the closest one in fractional part" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf float formats g the exponent is less than -4 converts a floating point number using exponential form" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats B collapse negative number representation if it equals 1" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats B converts argument as a binary number" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats B displays negative number as a two's complement prefixed with '..1'" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats X collapse negative number representation if it equals F" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats X converts argument as a hexadecimal number with uppercase letters" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats X displays negative number as a two's complement prefixed with '..f'" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats b collapse negative number representation if it equals 1" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats b converts argument as a binary number" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats b displays negative number as a two's complement prefixed with '..1'" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats converts String argument with Kernel#Integer" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats converts argument into Integer with to_i if to_int isn't available" # Mock '#<Object:0x5979a>' expected to receive to_i("any_args") exactly 1 times but received it 0 times
  fails "File#printf integer formats converts argument into Integer with to_int" # Mock '#<Object:0x59790>' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "File#printf integer formats d converts argument as a decimal number" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats i converts argument as a decimal number" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats o collapse negative number representation if it equals 7" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats o converts argument as an octal number" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats o displays negative number as a two's complement prefixed with '..7'" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats u converts argument as a decimal number" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats x collapse negative number representation if it equals f" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats x converts argument as a hexadecimal number" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf integer formats x displays negative number as a two's complement prefixed with '..f'" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats % alone raises an ArgumentError" # Expected ArgumentError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf other formats % is escaped by %" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats c displays character if argument is a numeric code of character" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats c displays character if argument is a single character string" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats c displays no characters if argument is an empty string" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats c displays only the first character if argument is a string of several characters" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats c raises TypeError if argument is not String or Integer and cannot be converted to them" # Expected TypeError (no implicit conversion of Array into Integer) but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf other formats c tries to convert argument to Integer with to_int" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats c tries to convert argument to String with to_str" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats p displays argument.inspect value" # Mock 'object' expected to receive inspect("any_args") exactly 1 times but received it 0 times
  fails "File#printf other formats s converts argument to string with to_s" # Mock 'string' expected to receive to_s("any_args") exactly 1 times but received it 0 times
  fails "File#printf other formats s does not try to convert with to_str" # Expected NoMethodError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf other formats s formats nil with precision" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats s formats nil with width and precision" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats s formats nil with width" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats s formats string with width and precision" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats s formats string with width" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats s substitute argument passes as a string" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf other formats s substitutes '' for nil" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf precision float types controls the number of decimal places displayed in fraction part" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf precision float types does not affect G format" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf precision integer types controls the number of decimal places displayed" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf precision string formats determines the maximum number of characters to be copied from the string" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf reference by name %<name>s style allows to place name in any position" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf reference by name %<name>s style cannot be mixed with unnamed style" # Expected ArgumentError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf reference by name %<name>s style supports flags, width, precision and type" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf reference by name %<name>s style uses value passed in a hash argument" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf reference by name %{name} style cannot be mixed with unnamed style" # Expected ArgumentError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf reference by name %{name} style converts value to String with to_s" # Mock '#<Object:0x598cc>' expected to receive to_s("any_args") exactly 1 times but received it 0 times
  fails "File#printf reference by name %{name} style does not support type style" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf reference by name %{name} style raises KeyError when there is no matching key" # Expected KeyError but got: TypeError (no implicit conversion of NilClass into String)
  fails "File#printf reference by name %{name} style supports flags, width and precision" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf reference by name %{name} style uses value passed in a hash argument" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf width is ignored if argument's actual length is greater" # TypeError: no implicit conversion of NilClass into String
  fails "File#printf width specifies the minimum number of characters that will be written to the result" # TypeError: no implicit conversion of NilClass into String
  fails "File#reopen calls #to_path to convert an Object" # NotImplementedError: File.lstat is not available on this platform
  fails "File#reopen resets the stream to a new file path" # NotImplementedError: File.lstat is not available on this platform
  fails "File#size follows symlinks if necessary" # NoMethodError: undefined method `closed?' for nil
  fails "File#size for an empty file returns 0" # NoMethodError: undefined method `closed?' for nil
  fails "File#size is an instance method" # NoMethodError: undefined method `closed?' for nil
  fails "File#size raises an IOError on a closed file" # NoMethodError: undefined method `closed?' for nil
  fails "File#size returns the cached size of the file if subsequently deleted" # NoMethodError: undefined method `closed?' for nil
  fails "File#size returns the file's current size even if modified" # NoMethodError: undefined method `closed?' for nil
  fails "File#size returns the file's size as an Integer" # NoMethodError: undefined method `closed?' for nil
  fails "File#size returns the file's size in bytes" # NoMethodError: undefined method `closed?' for nil
  fails "File#to_path calls to_str on argument and returns exact value" # NotImplementedError: File.lstat is not available on this platform
  fails "File#to_path does not absolute-ise the path it returns" # NotImplementedError: File.lstat is not available on this platform
  fails "File#to_path does not canonicalize the path it returns" # NotImplementedError: File.lstat is not available on this platform
  fails "File#to_path does not normalise the path it returns" # NotImplementedError: File.lstat is not available on this platform
  fails "File#to_path preserves the encoding of the path" # NotImplementedError: File.lstat is not available on this platform
  fails "File#to_path returns a String" # NotImplementedError: File.lstat is not available on this platform
  fails "File#truncate does not move the file read pointer to the specified byte offset" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate does not move the file write pointer to the specified byte offset" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate raises a TypeError if not passed an Integer type for the for the argument" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate raises an ArgumentError if not passed one argument" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate raises an Errno::EINVAL if the length argument is not valid" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate raises an IOError if file is closed" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate raises an IOError if file is not opened for writing" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate truncates a file size to 0" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate truncates a file size to 5" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate truncates a file to a larger size than the original file" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate truncates a file to the same size as the original file" # NoMethodError: undefined method `closed?' for nil
  fails "File#truncate truncates a file" # NoMethodError: undefined method `closed?' for nil
  fails "File.absolute_path? does not expand '~user' to a home directory." # NotImplementedError: Dir.chdir is not available on this platform
  fails "File.absolute_path? returns true if it's an absolute pathname" # Expected false to be true
  fails "File.atime accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.atime raises an Errno::ENOENT exception if the file is not found" # NotImplementedError: File.lstat is not available on this platform
  fails "File.atime returns the last access time for the named file as a Time object" # NotImplementedError: File.lstat is not available on this platform
  fails "File.blockdev? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.blockdev? returns true/false depending if the named file is a block device" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chardev? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chardev? returns true/false depending if the named file is a char device" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod invokes to_int on non-integer argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod invokes to_str on non-string file names" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod modifies the permission bits of the files specified" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod raises RangeError with too large values" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod raises an error for a non existent path" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod returns the number of files modified" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod throws a TypeError if the given path is not coercible into a string" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod with '0111' makes file executable but not readable or writable" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod with '0222' makes file writable but not readable or executable" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod with '0444' makes file readable but not writable or executable" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chmod with '0666' makes file readable and writable but not executable" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chown accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chown raises an error for a non existent path" # NotImplementedError: File.lstat is not available on this platform
  fails "File.chown returns the number of files processed" # NotImplementedError: File.lstat is not available on this platform
  fails "File.ctime accepts an object that has a #to_path method" # NotImplementedError: File.stat is not available on this platform
  fails "File.ctime raises an Errno::ENOENT exception if the file is not found" # Expected Errno::ENOENT but got: NotImplementedError (File.stat is not available on this platform)
  fails "File.ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself)." # NotImplementedError: File.stat is not available on this platform
  fails "File.delete accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.delete coerces a given parameter into a string if possible" # NotImplementedError: File.lstat is not available on this platform
  fails "File.delete deletes a single file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.delete deletes multiple files" # NotImplementedError: File.lstat is not available on this platform
  fails "File.delete raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File.delete raises an Errno::ENOENT when the given file doesn't exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.delete returns 0 when called without arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.directory? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.directory? raises a TypeError when passed an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "File.directory? raises a TypeError when passed nil" # NotImplementedError: File.lstat is not available on this platform
  fails "File.directory? returns false if the argument is not a directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File.directory? returns true if the argument is a directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File.directory? returns true if the argument is an IO that is a directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? returns false if the file is not empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? returns true for /dev/null" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? returns true if the file is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? returns true inside a block opening a file if it is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.empty? returns true or false for a directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable? returns true if named file is executable by the effective user id of the process, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable? returns true if the argument is an executable file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable_real? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable_real? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable_real? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable_real? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.executable_real? returns true if the file its an executable" # NotImplementedError: File.lstat is not available on this platform
  fails "File.exist? accepts an object that has a #to_path method" # NotImplementedError: File.stat is not available on this platform
  fails "File.exist? returns true if the file exist" # NotImplementedError: File.stat is not available on this platform
  fails "File.file? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.file? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File.file? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.file? returns true if the named file exists and is a regular file." # NotImplementedError: File.lstat is not available on this platform
  fails "File.file? returns true if the null device exists and is a regular file." # NotImplementedError: File.lstat is not available on this platform
  fails "File.grpowned? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.grpowned? returns false if file the does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.grpowned? returns true if the file exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.grpowned? takes non primary groups into account" # NotImplementedError: File.lstat is not available on this platform
  fails "File.identical? raises a TypeError if not passed String types" # NotImplementedError: File.lstat is not available on this platform
  fails "File.identical? raises an ArgumentError if not passed two arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.identical? returns false if any of the files doesn't exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.identical? returns true if both named files are identical" # NotImplementedError: File.lstat is not available on this platform
  fails "File.link link a file with another" # NotImplementedError: File.lstat is not available on this platform
  fails "File.link raises a TypeError if not passed String types" # NotImplementedError: File.lstat is not available on this platform
  fails "File.link raises an ArgumentError if not passed two arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.link raises an Errno::EEXIST if the target already exists" # NotImplementedError: File.lstat is not available on this platform
  fails "File.lstat accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.lstat raises an Errno::ENOENT if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.lstat returns a File::Stat object if the given file exists" # NotImplementedError: File.lstat is not available on this platform
  fails "File.lstat returns a File::Stat object when called on an instance of File" # NotImplementedError: File.lstat is not available on this platform
  fails "File.lstat returns a File::Stat object with symlink properties for a symlink" # NotImplementedError: File.lstat is not available on this platform
  fails "File.lutime sets the access and modification time for a regular file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.lutime sets the access and modification time for a symlink" # NotImplementedError: File.lstat is not available on this platform
  fails "File.mkfifo creates a FIFO file at the passed path" # NotImplementedError: File.lstat is not available on this platform
  fails "File.mkfifo creates a FIFO file with a default mode of 0666 & ~umask" # NotImplementedError: File.lstat is not available on this platform
  fails "File.mkfifo creates a FIFO file with passed mode & ~umask" # NotImplementedError: File.lstat is not available on this platform
  fails "File.mkfifo returns 0 after creating the FIFO file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.mkfifo when path does not exist raises an Errno::ENOENT exception" # NotImplementedError: File.lstat is not available on this platform
  fails "File.mkfifo when path passed responds to :to_path creates a FIFO file at the path specified" # NotImplementedError: File.lstat is not available on this platform
  fails "File.mtime raises an Errno::ENOENT exception if the file is not found" # NotImplementedError: File.lstat is not available on this platform
  fails "File.mtime returns the modification Time of the file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new bitwise-ORs mode and flags option" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new coerces filename using #to_path" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new coerces filename using to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new creates a new file when use File::EXCL mode" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new creates a new file when use File::WRONLY|File::APPEND mode" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new creates a new file when use File::WRONLY|File::TRUNC mode" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new creates the file and returns writable descriptor when called with 'w' mode and r-o permissions" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new opens directories" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new opens the existing file, does not change permissions even when they are specified" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new raises a TypeError if the first parameter can't be coerced to a string" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new raises a TypeError if the first parameter is nil" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new raises an Errno::EBADF if the first parameter is an invalid file descriptor" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new raises an Errorno::EEXIST if the file exists when create a new file with File::CREAT|File::EXCL" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new File when use File::APPEND mode" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new File when use File::RDONLY|File::APPEND mode" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new File when use File::RDONLY|File::WRONLY mode" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new File with mode num" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new File with mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new File with modus fd" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new File with modus num and permissions" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new read-only File when mode is not specified but flags option is present" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new read-only File when mode is not specified" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new read-only File when use File::CREAT mode" # NotImplementedError: File.lstat is not available on this platform
  fails "File.new returns a new read-only File when use File::RDONLY|File::CREAT mode" # NotImplementedError: File.lstat is not available on this platform
  fails "File.open opens directories" # NotImplementedError: File.lstat is not available on this platform
  fails "File.open when passed a file descriptor opens a file when passed a block" # NotImplementedError: File.lstat is not available on this platform
  fails "File.open when passed a file descriptor opens a file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.owned? returns false if file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.owned? returns false when the file is not owned by the user" # NotImplementedError: File.lstat is not available on this platform
  fails "File.owned? returns true if the file exist and is owned by the user" # NotImplementedError: File.lstat is not available on this platform
  fails "File.path calls #to_path for non-string argument and returns result" # ArgumentError: file_to_path is not prefixed by tmp/rubyspec_temp
  fails "File.path returns path for File argument" # ArgumentError: file_to_path is not prefixed by tmp/rubyspec_temp
  fails "File.path returns path for Pathname argument" # ArgumentError: file_to_path is not prefixed by tmp/rubyspec_temp
  fails "File.path returns the string argument without any change" # ArgumentError: file_to_path is not prefixed by tmp/rubyspec_temp
  fails "File.pipe? returns false if file does not exist" # NotImplementedError: File.stat is not available on this platform
  fails "File.pipe? returns false if the file is not a pipe" # NotImplementedError: File.lstat is not available on this platform
  fails "File.pipe? returns true if the file is a pipe" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readable? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readable_real? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readable_real? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readable_real? returns true if named file is readable by the real user id of the process, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readlink when changing the working directory returns the name of the file referenced by the given link when the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readlink when changing the working directory returns the name of the file referenced by the given link" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readlink with absolute paths raises an Errno::EINVAL if called with a normal file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readlink with absolute paths raises an Errno::ENOENT if there is no such file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readlink with absolute paths returns the name of the file referenced by the given link when the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readlink with absolute paths returns the name of the file referenced by the given link" # NotImplementedError: File.lstat is not available on this platform
  fails "File.readlink with paths containing unicode characters returns the name of the file referenced by the given link" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath raises Errno::ENOENT if the directory is absent" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath raises Errno::ENOENT if the symlink points to an absent directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath raises an Errno::ELOOP if the symlink points to itself" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath returns '/' when passed '/'" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath returns the real (absolute) pathname if the file is absent" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath returns the real (absolute) pathname if the symlink points to an absent file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath returns the real (absolute) pathname not containing symlinks" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath uses base directory for interpreting relative pathname" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath uses current directory for interpreting relative pathname" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realdirpath uses link directory for expanding relative links" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath converts the argument with #to_path" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath raises Errno::ENOENT if the file is absent" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath raises Errno::ENOENT if the symlink points to an absent file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath raises an Errno::ELOOP if the symlink points to itself" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath removes the file element when going one level up" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath returns '/' when passed '/'" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath returns the real (absolute) pathname not containing symlinks" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath uses base directory for interpreting relative pathname" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath uses current directory for interpreting relative pathname" # NotImplementedError: File.lstat is not available on this platform
  fails "File.realpath uses link directory for expanding relative links" # NotImplementedError: File.lstat is not available on this platform
  fails "File.rename raises a TypeError if not passed String types" # NotImplementedError: File.lstat is not available on this platform
  fails "File.rename raises an ArgumentError if not passed two arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.rename raises an Errno::ENOENT if the source does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.rename renames a file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.setgid? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.setgid? returns false if the file was just made" # NotImplementedError: File.lstat is not available on this platform
  fails "File.setuid? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.setuid? returns false if the file was just made" # NotImplementedError: File.lstat is not available on this platform
  fails "File.setuid? returns true when the gid bit is set" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size accepts a File argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size accepts a String-like (to_str) parameter" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size calls #to_io to convert the argument to an IO" # NoMethodError: undefined method `closed?' for nil
  fails "File.size raises an error if file_name doesn't exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size returns 0 if the file is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size returns the size of the file if it exists and is not empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size? accepts a File argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size? accepts a String-like (to_str) parameter" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size? calls #to_io to convert the argument to an IO" # NoMethodError: undefined method `closed?' for nil
  fails "File.size? returns nil if file_name doesn't exist or has 0 size" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size? returns nil if file_name is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.size? returns the size of the file if it exists and is not empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.socket? returns false if file does not exist" # NotImplementedError: File.stat is not available on this platform
  fails "File.socket? returns false if the file is not a socket" # NotImplementedError: File.lstat is not available on this platform
  fails "File.stat accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.stat raises an Errno::ENOENT if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.stat returns a File::Stat object if the given file exists" # NotImplementedError: File.lstat is not available on this platform
  fails "File.stat returns a File::Stat object when called on an instance of File" # NotImplementedError: File.lstat is not available on this platform
  fails "File.stat returns a File::Stat object with file properties for a symlink" # NotImplementedError: File.lstat is not available on this platform
  fails "File.stat returns an error when given missing non-ASCII path" # NotImplementedError: File.lstat is not available on this platform
  fails "File.stat returns information for a file that has been deleted but is still open" # NotImplementedError: File.lstat is not available on this platform
  fails "File.sticky? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.sticky? returns false if file does not exist" # NotImplementedError: File.stat is not available on this platform
  fails "File.sticky? returns false if the file dies not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.sticky? returns false if the file has not sticky bit set" # NotImplementedError: File.lstat is not available on this platform
  fails "File.sticky? returns true if the named file has the sticky bit, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink accepts args that have #to_path methods" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink creates a symbolic link" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink creates a symlink between a source and target file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink raises a TypeError if not called with String types" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink raises an ArgumentError if not called with two arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink raises an Errno::EEXIST if the target already exists" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.symlink? returns true if the file is a link" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate raises a TypeError if not passed a String type for the first argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate raises a TypeError if not passed an Integer type for the second argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate raises an ArgumentError if not passed two arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate raises an Errno::EINVAL if the length argument is not valid" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate raises an Errno::ENOENT if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate truncate a file size to 0" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate truncate a file size to 5" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate truncates a file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate truncates to a larger file size than the original file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.truncate truncates to the same size as the original file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.umask invokes to_int on non-integer argument" # NotImplementedError: File.umask is not available on this platform
  fails "File.umask raises ArgumentError when more than one argument is provided" # NotImplementedError: File.umask is not available on this platform
  fails "File.umask raises RangeError with too large values" # NotImplementedError: File.umask is not available on this platform
  fails "File.umask returns an Integer" # NotImplementedError: File.umask is not available on this platform
  fails "File.umask returns the current umask value for the process" # NotImplementedError: File.umask is not available on this platform
  fails "File.unlink accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.unlink coerces a given parameter into a string if possible" # NotImplementedError: File.lstat is not available on this platform
  fails "File.unlink deletes a single file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.unlink deletes multiple files" # NotImplementedError: File.lstat is not available on this platform
  fails "File.unlink raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File.unlink raises an Errno::ENOENT when the given file doesn't exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.unlink returns 0 when called without arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.utime accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.utime accepts numeric atime and mtime arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.utime returns the number of filenames in the arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File.utime sets the access and modification time of each file" # NotImplementedError: File.lstat is not available on this platform
  fails "File.utime uses the current times if two nil values are passed" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_readable? coerces the argument with #to_path" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_readable? returns an Integer if the file is a directory and chmod 644" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_readable? returns an Integer if the file is chmod 644" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_readable? returns nil if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_readable? returns nil if the file is chmod 000" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_readable? returns nil if the file is chmod 600" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_readable? returns nil if the file is chmod 700" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_writable? coerces the argument with #to_path" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_writable? returns an Integer if the file is a directory and chmod 777" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_writable? returns an Integer if the file is chmod 777" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_writable? returns nil if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_writable? returns nil if the file is chmod 000" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_writable? returns nil if the file is chmod 600" # NotImplementedError: File.lstat is not available on this platform
  fails "File.world_writable? returns nil if the file is chmod 700" # NotImplementedError: File.lstat is not available on this platform
  fails "File.writable? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.writable_real? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File.writable_real? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.writable_real? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? returns false if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? returns false if the file is not empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? returns true for /dev/null" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? returns true if the file is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? returns true inside a block opening a file if it is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File.zero? returns true or false for a directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#<=> includes Comparable and #== shows mtime equality between two File::Stat objects" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#<=> is able to compare files by different modification times" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#<=> is able to compare files by the same modification times" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#atime returns the atime of a File::Stat object" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#blksize returns the blksize of a File::Stat object" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#blockdev? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#blockdev? returns true/false depending if the named file is a block device" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#blocks returns a non-negative integer" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#chardev? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#chardev? returns true/false depending if the named file is a char device" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#ctime returns the ctime of a File::Stat object" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#dev returns the number of the device on which the file exists" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#dev_major returns the major part of File::Stat#dev" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#dev_minor returns the minor part of File::Stat#dev" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#directory? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#directory? raises a TypeError when passed an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#directory? raises a TypeError when passed nil" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#directory? returns false if the argument is not a directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#directory? returns true if the argument is a directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable? returns true if named file is executable by the effective user id of the process, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable? returns true if the argument is an executable file" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable_real? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable_real? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable_real? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#executable_real? returns true if the file its an executable" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#file? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#file? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#file? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#file? returns true if the named file exists and is a regular file." # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#file? returns true if the null device exists and is a regular file." # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#grpowned? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#grpowned? returns true if the file exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#grpowned? takes non primary groups into account" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#initialize calls #to_path on non-String arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#initialize creates a File::Stat object for the given file" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#initialize raises an exception if the file doesn't exist" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#ino returns the ino of a File::Stat object" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#mtime returns the mtime of a File::Stat object" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#nlink returns the number of links to a file" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#owned? returns false if the file is not owned by the user" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#pipe? returns false if the file is not a pipe" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#pipe? returns true if the file is a pipe" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#rdev returns the number of the device this file represents which the file exists" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#rdev_major returns the major part of File::Stat#rdev" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#rdev_minor returns the minor part of File::Stat#rdev" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#readable? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#readable? returns true if named file is readable by the effective user id of the process, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#readable_real? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#readable_real? returns true if named file is readable by the real user id of the process, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#sticky? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#sticky? returns true if the named file has the sticky bit, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#symlink? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#symlink? returns true if the file is a link" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#writable? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#writable? returns true if named file is writable by the effective user id of the process, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#writable_real? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#writable_real? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#writable_real? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#writable_real? returns true if named file is writable by the real user id of the process, otherwise false" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#zero? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#zero? raises a TypeError if not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#zero? raises an ArgumentError if not passed one argument" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#zero? returns false if the file is not empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#zero? returns true for /dev/null" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#zero? returns true if the file is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#zero? returns true inside a block opening a file if it is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat#zero? returns true or false for a directory" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.size accepts a String-like (to_str) parameter" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.size accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.size returns 0 if the file is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.size returns the size of the file if it exists and is not empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.size? accepts a String-like (to_str) parameter" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.size? accepts an object that has a #to_path method" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.size? returns nil if file_name is empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.size? returns the size of the file if it exists and is not empty" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_readable? coerces the argument with #to_path" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_readable? returns an Integer if the file is a directory and chmod 644" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_readable? returns an Integer if the file is chmod 644" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_readable? returns nil if the file is chmod 000" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_readable? returns nil if the file is chmod 600" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_readable? returns nil if the file is chmod 700" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_writable? coerces the argument with #to_path" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_writable? returns an Integer if the file is a directory and chmod 777" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_writable? returns an Integer if the file is chmod 777" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_writable? returns nil if the file is chmod 000" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_writable? returns nil if the file is chmod 600" # NotImplementedError: File.lstat is not available on this platform
  fails "File::Stat.world_writable? returns nil if the file is chmod 700" # NotImplementedError: File.lstat is not available on this platform
end
