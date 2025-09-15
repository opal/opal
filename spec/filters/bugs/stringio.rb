# NOTE: run bin/format-filters after changing this file
opal_filter "StringIO" do
  fails "StringIO#each_codepoint raises an error if reading invalid sequence" # Expected ArgumentError but no exception was raised (65533 was returned)
  fails "StringIO#external_encoding changes to match string if string's encoding is changed" # Expected #<Encoding:UTF-8> == #<Encoding:EUC-JP> to be truthy but was false
  fails "StringIO#getch StringIO#getch when self is not readable raises an IOError" # Expected IOError but got: NoMethodError (undefined method `getch' for #<StringIO:0x2e8a>)
  fails "StringIO#getch does not increase self's position when called at the end of file" # NoMethodError: undefined method `getch' for #<StringIO:0x2e6c>
  fails "StringIO#getch increases self's position by one" # NoMethodError: undefined method `getch' for #<StringIO:0x2e66>
  fails "StringIO#getch increments #pos by the byte size of the character in multibyte strings" # NoMethodError: undefined method `getch' for #<StringIO:0x2e80>
  fails "StringIO#getch returns nil at the end of the string" # NoMethodError: undefined method `getch' for #<StringIO:0x2e5a>
  fails "StringIO#getch returns nil when called at the end of self" # NoMethodError: undefined method `getch' for #<StringIO:0x2e60>
  fails "StringIO#getch returns the character at the current position" # NoMethodError: undefined method `getch' for #<StringIO:0x2e76>
  fails "StringIO#getpass is defined by io/console" # Expected #<StringIO:0x20e0>.respond_to? "getpass" to be truthy but was false
  fails "StringIO#initialize when passed [Object, mode] allows passing the mode as an Integer" # Expected false to be true
  fails "StringIO#initialize when passed [Object, mode] raises a FrozenError when passed a frozen String in truncate mode as StringIO backend" # Expected FrozenError but no exception was raised ( " " was returned)
  fails "StringIO#initialize when passed [Object, mode] raises an Errno::EACCES error when passed a frozen string with a write-mode" # Expected Errno::EACCES but no exception was raised ( " " was returned)
  fails "StringIO#initialize when passed [Object] automatically sets the mode to read-only when passed a frozen string" # Expected false to be true
  fails "StringIO#initialize when passed no arguments is private" # Expected StringIO to have private instance method 'initialize' but it does not
  fails "StringIO#printf formatting integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "StringIO#printf formatting integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "StringIO#printf formatting integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "StringIO#printf formatting other formats c raises TypeError if argument is nil" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "StringIO#printf formatting other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (can't convert BasicObject to Integer) but got: TypeError (can't convert BasicObject into Integer (BasicObject#to_int gives String))
  fails "StringIO#printf formatting other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (can't convert BasicObject to String) but no exception was raised ("f" was returned)
  fails "StringIO#putc when passed [String] handles concurrent writes correctly" # NotImplementedError: Thread creation not available
  fails "StringIO#puts when passed 1 or more objects handles concurrent writes correctly" # NotImplementedError: Thread creation not available
  fails "StringIO#puts when passed an Array returns general object info if :to_s does not return a string" # TypeError: no implicit conversion of MockObject into String
  fails "StringIO#read when passed length and a buffer reads [length] characters into the buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "StringIO#read when passed length, buffer raises a FrozenError error when passed a frozen String as buffer" # Expected FrozenError but got: NotImplementedError (out_string buffer is currently not supported)
  fails "StringIO#read when passed length, buffer raises a TypeError when the passed buffer Object can't be converted to a String" # Expected TypeError but got: NotImplementedError (out_string buffer is currently not supported)
  fails "StringIO#read when passed length, buffer reads length bytes and writes them to the buffer String" # NotImplementedError: out_string buffer is currently not supported
  fails "StringIO#read when passed length, buffer returns the passed buffer String" # NotImplementedError: out_string buffer is currently not supported
  fails "StringIO#read when passed length, buffer tries to convert the passed buffer Object to a String using #to_str" # Mock 'to_str' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "StringIO#read_nonblock accepts an exception option" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c62>
  fails "StringIO#read_nonblock when exception option is set to false when the end is reached returns nil" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c68>
  fails "StringIO#read_nonblock when passed length accepts :exception option" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122bf0>
  fails "StringIO#read_nonblock when passed length correctly updates the position" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c08>
  fails "StringIO#read_nonblock when passed length raises a TypeError when the passed length can't be converted to an Integer" # Expected TypeError but got: NoMethodError (undefined method `read_nonblock' for #<StringIO:0x122bf6>)
  fails "StringIO#read_nonblock when passed length raises a TypeError when the passed length is negative" # Expected ArgumentError but got: NoMethodError (undefined method `read_nonblock' for #<StringIO:0x122c22>)
  fails "StringIO#read_nonblock when passed length reads at most the whole content" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c02>
  fails "StringIO#read_nonblock when passed length reads length bytes from the current position and returns them" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c2c>
  fails "StringIO#read_nonblock when passed length returns a binary String" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c0e>
  fails "StringIO#read_nonblock when passed length returns an empty String when passed 0 and no data remains" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c52>
  fails "StringIO#read_nonblock when passed length tries to convert the passed length to an Integer using #to_int" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "StringIO#read_nonblock when passed length, buffer accepts :exception option" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122ba4>
  fails "StringIO#read_nonblock when passed length, buffer raises a FrozenError error when passed a frozen String as buffer" # Expected FrozenError but got: NoMethodError (undefined method `read_nonblock' for #<StringIO:0x122bd0>)
  fails "StringIO#read_nonblock when passed length, buffer raises a TypeError when the passed buffer Object can't be converted to a String" # Expected TypeError but got: NoMethodError (undefined method `read_nonblock' for #<StringIO:0x122baa>)
  fails "StringIO#read_nonblock when passed length, buffer reads length bytes and writes them to the buffer String" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122bc4>
  fails "StringIO#read_nonblock when passed length, buffer returns the passed buffer String" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122bca>
  fails "StringIO#read_nonblock when passed length, buffer tries to convert the passed buffer Object to a String using #to_str" # Mock 'to_str' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "StringIO#read_nonblock when passed nil returns the remaining content from the current position" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c3e>
  fails "StringIO#read_nonblock when passed nil updates the current position" # NoMethodError: undefined method `read_nonblock' for #<StringIO:0x122c38>
  fails "StringIO#readpartial discards the existing buffer content upon error" # Expected EOFError but got: NotImplementedError (out_string buffer is currently not supported)
  fails "StringIO#readpartial discards the existing buffer content upon successful read" # NotImplementedError: out_string buffer is currently not supported
  fails "StringIO#readpartial reads after ungetc with data in the buffer" # NotImplementedError: NotImplementedError
  fails "StringIO#readpartial reads after ungetc without data in the buffer" # NotImplementedError: NotImplementedError
  fails "StringIO#reopen does not truncate the content even when the StringIO argument is in the truncate mode" # Expected "BLAHinal StringIO" == "BLAH" to be truthy but was false
  fails "StringIO#reopen truncates the given string, not a copy" # Expected "goodbye" == "" to be truthy but was false
  fails "StringIO#reopen when passed [Object, Integer] does not raise IOError when passed a frozen String in read-mode" # TypeError: no implicit conversion of Number into String
  fails "StringIO#reopen when passed [Object, Integer] raises a FrozenError when trying to reopen self with a frozen String in truncate-mode" # Expected FrozenError but got: TypeError (no implicit conversion of Number into String)
  fails "StringIO#reopen when passed [Object, Integer] raises an Errno::EACCES when trying to reopen self with a frozen String in write-mode" # Expected Errno::EACCES but got: TypeError (no implicit conversion of Number into String)
  fails "StringIO#reopen when passed [Object, Integer] reopens self with the passed Object in the passed mode" # TypeError: no implicit conversion of Number into String
  fails "StringIO#reopen when passed [Object, Integer] tries to convert the passed Object to a String using #to_str" # Mock 'to_str' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "StringIO#reopen when passed [Object, Object] raises an Errno::EACCES error when trying to reopen self with a frozen String in write-mode" # Expected Errno::EACCES but no exception was raised (#<StringIO:0x12375e> was returned)
  fails "StringIO#reopen when passed [Object, Object] reopens self with the passed Object in the passed mode" # Expected true to be false
  fails "StringIO#reopen when passed [Object, Object] truncates the passed String when opened in truncate mode" # Expected "reopened" == "" to be truthy but was false
  fails "StringIO#set_encoding accepts a String" # Expected #<Encoding:US-ASCII> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "StringIO#set_encoding does not set the encoding of the underlying String if the String is frozen" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "StringIO#sysread when passed length, buffer raises a FrozenError error when passed a frozen String as buffer" # Expected FrozenError but got: NotImplementedError (out_string buffer is currently not supported)
  fails "StringIO#sysread when passed length, buffer raises a TypeError when the passed buffer Object can't be converted to a String" # Expected TypeError but got: NotImplementedError (out_string buffer is currently not supported)
  fails "StringIO#sysread when passed length, buffer reads length bytes and writes them to the buffer String" # NotImplementedError: out_string buffer is currently not supported
  fails "StringIO#sysread when passed length, buffer returns the passed buffer String" # NotImplementedError: out_string buffer is currently not supported
  fails "StringIO#sysread when passed length, buffer tries to convert the passed buffer Object to a String using #to_str" # Mock 'to_str' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "StringIO#syswrite when passed [String] does not transcode the given string when the external encoding is set and the string encoding is BINARY" # Expected [195, 169, 116, 195, 255, 253] == [195, 169, 116, 195, 169] to be truthy but was false
  fails "StringIO#syswrite when passed [String] handles concurrent writes correctly" # NotImplementedError: Thread creation not available
  fails "StringIO#truncate when passed [length] does not create a copy of the underlying string" # Expected "1234" to be identical to "123456789"
  fails "StringIO#ungetbyte ungets the bytes of a string if given a string as an argument" # Expected [0, 239, 191, 189] == [198, 169, 169] to be truthy but was false
  fails "StringIO#ungetc when passed [char] decreases the current position by one" # NotImplementedError: NotImplementedError
  fails "StringIO#ungetc when passed [char] pads with \\000 when the current position is after the end" # NotImplementedError: NotImplementedError
  fails "StringIO#ungetc when passed [char] raises a TypeError when the passed length can't be converted to an Integer or String" # Expected TypeError but got: NotImplementedError (NotImplementedError)
  fails "StringIO#ungetc when passed [char] returns nil" # NotImplementedError: NotImplementedError
  fails "StringIO#ungetc when passed [char] tries to convert the passed argument to an String using #to_str" # Mock 'to_str' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "StringIO#ungetc when passed [char] writes the passed char before the current position" # NotImplementedError: NotImplementedError
  fails "StringIO#ungetc when self is not readable raises an IOError" # Expected IOError but got: NotImplementedError (NotImplementedError)
  fails "StringIO#write when passed [String] does not transcode the given string when the external encoding is set and the string encoding is BINARY" # Expected [195, 169, 116, 195, 255, 253] == [195, 169, 116, 195, 169] to be truthy but was false
  fails "StringIO#write when passed [String] handles concurrent writes correctly" # NotImplementedError: Thread creation not available
  fails "StringIO#write_nonblock when in append mode appends the passed argument to the end of self" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1cfa>
  fails "StringIO#write_nonblock when in append mode correctly updates self's position" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1cf4>
  fails "StringIO#write_nonblock when passed [Object] tries to convert the passed Object to a String using #to_s" # Mock 'to_s' expected to receive to_s("any_args") exactly 1 times but received it 0 times
  fails "StringIO#write_nonblock when passed [String] accepts :exception option" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1c82>
  fails "StringIO#write_nonblock when passed [String] does not transcode the given string when the external encoding is set and the string encoding is BINARY" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1cc6>
  fails "StringIO#write_nonblock when passed [String] handles concurrent writes correctly" # NotImplementedError: Thread creation not available
  fails "StringIO#write_nonblock when passed [String] pads self with \\000 when the current position is after the end" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1c88>
  fails "StringIO#write_nonblock when passed [String] returns the number of bytes written" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1c94>
  fails "StringIO#write_nonblock when passed [String] transcodes the given string when the external encoding is set and neither is BINARY" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1cd2>
  fails "StringIO#write_nonblock when passed [String] updates self's position" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1c8e>
  fails "StringIO#write_nonblock when passed [String] writes the passed String at the current buffer position" # NoMethodError: undefined method `write_nonblock' for #<StringIO:0x1cda>
  fails "StringIO#write_nonblock when self is not writable raises an IOError" # Expected IOError but got: NoMethodError (undefined method `write_nonblock' for #<StringIO:0x1ce4>)
  fails "StringIO.new warns when called with a block" # Expected warning to match: /StringIO::new\(\) does not take block; use StringIO::open\(\) instead/ but got: ""
  fails "StringIO.open when passed [Object, mode] allows passing the mode as an Integer" # Expected false to be true
  fails "StringIO.open when passed [Object, mode] raises a FrozenError when passed a frozen String in truncate mode as StringIO backend" # Expected FrozenError but no exception was raised (#<StringIO:0x119d8a> was returned)
  fails "StringIO.open when passed [Object, mode] raises an Errno::EACCES error when passed a frozen string with a write-mode" # Expected Errno::EACCES but no exception was raised (#<StringIO:0x119d68> was returned)
  fails "StringIO.open when passed [Object] automatically sets the mode to read-only when passed a frozen string" # Expected false to be true
end
