# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO#<< raises an error if the stream is closed" # Errno::ENOENT: No such file or directory
  fails "IO#advise raises a NotImplementedError if advise is not recognized" # Errno::ENOENT: No such file or directory
  fails "IO#advise raises a TypeError if len cannot be coerced to an Integer" # Errno::ENOENT: No such file or directory
  fails "IO#advise raises a TypeError if offset cannot be coerced to an Integer" # Errno::ENOENT: No such file or directory
  fails "IO#advise raises an IOError if the stream is closed" # Errno::ENOENT: No such file or directory
  fails "IO#advise supports the dontneed advice type" # Errno::ENOENT: No such file or directory
  fails "IO#advise supports the noreuse advice type" # Errno::ENOENT: No such file or directory
  fails "IO#advise supports the normal advice type" # Errno::ENOENT: No such file or directory
  fails "IO#advise supports the random advice type" # Errno::ENOENT: No such file or directory
  fails "IO#advise supports the sequential advice type" # Errno::ENOENT: No such file or directory
  fails "IO#advise supports the willneed advice type" # Errno::ENOENT: No such file or directory
  fails "IO#binmode raises an IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#binmode? raises an IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#close on an IO.popen stream clears #pid" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO#close_read allows subsequent invocation of close" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_read closes the read end of a duplex I/O stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_read closes the stream if it is neither writable nor duplexed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_read does nothing on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_read does nothing on subsequent invocations" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_read raises an IOError if the stream is writable and not duplexed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_write allows subsequent invocation of close" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_write closes the stream if it is neither readable nor duplexed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_write closes the write end of a duplex I/O stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_write does nothing on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_write does nothing on subsequent invocations" # NoMethodError: undefined method `closed?' for nil
  fails "IO#closed? returns false on open stream" # Errno::ENOENT: No such file or directory
  fails "IO#closed? returns true on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#dup raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#each uses $/ as the default line separator" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed a String containing one space as a separator does not change $_" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed a String containing one space as a separator tries to convert the passed separator to a String using #to_str" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed a String containing one space as a separator uses the passed argument as the line separator" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed an empty String as a separator discards leading newlines" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed an empty String as a separator yields each paragraph" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed chomp and a separator yields each line without separator to the passed block" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed chomp and empty line as a separator yields each paragraph without trailing new line characters" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed chomp and nil as a separator yields self's content" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed chomp yields each line without trailing newline characters to the passed block" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed chomp, nil as a separator, and a limit yields each line of limit size without truncating trailing new line character" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed nil as a separator yields self's content starting from the current position when the passed separator is nil" # Errno::ENOENT: No such file or directory
  fails "IO#each when passed too many arguments raises ArgumentError" # Errno::ENOENT: No such file or directory
  fails "IO#each with both separator and limit when a block is given accepts an empty block" # Errno::ENOENT: No such file or directory
  fails "IO#each with both separator and limit when a block is given when passed an empty String as a separator discards leading newlines" # Errno::ENOENT: No such file or directory
  fails "IO#each with both separator and limit when a block is given when passed an empty String as a separator yields each paragraph" # Errno::ENOENT: No such file or directory
  fails "IO#each with both separator and limit when a block is given when passed nil as a separator yields self's content starting from the current position when the passed separator is nil" # Errno::ENOENT: No such file or directory
  fails "IO#each with both separator and limit when no block is given returned Enumerator size should return nil" # Errno::ENOENT: No such file or directory
  fails "IO#each with both separator and limit when no block is given returns an Enumerator" # Errno::ENOENT: No such file or directory
  fails "IO#each with limit when limit is 0 raises an ArgumentError" # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator does not change $_" # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator makes line count accessible via $." # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator makes line count accessible via lineno" # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator raises an IOError when self is not readable" # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator returns self" # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator when no block is given returned Enumerator size should return nil" # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator when no block is given returns an Enumerator" # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator yields each line starting from the current position" # Errno::ENOENT: No such file or directory
  fails "IO#each with no separator yields each line to the passed block" # Errno::ENOENT: No such file or directory
  fails "IO#each_byte raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#each_byte returns self on an empty stream" # Errno::ENOENT: No such file or directory
  fails "IO#each_byte when no block is given returned Enumerator size should return nil" # Errno::ENOENT: No such file or directory
  fails "IO#each_byte when no block is given returns an Enumerator" # Errno::ENOENT: No such file or directory
  fails "IO#each_byte yields each byte" # Errno::ENOENT: No such file or directory
  fails "IO#each_char raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#each_char raises an IOError when an enumerator created on a closed stream is accessed" # Errno::ENOENT: No such file or directory
  fails "IO#each_char returns an enumerator for a closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#each_char returns itself" # Errno::ENOENT: No such file or directory
  fails "IO#each_char when no block is given returned Enumerator size should return nil" # Errno::ENOENT: No such file or directory
  fails "IO#each_char when no block is given returns an Enumerator" # Errno::ENOENT: No such file or directory
  fails "IO#each_char yields each character" # Errno::ENOENT: No such file or directory
  fails "IO#each_codepoint calls the given block" # Errno::ENOENT: No such file or directory
  fails "IO#each_codepoint does not change $_" # Errno::ENOENT: No such file or directory
  fails "IO#each_codepoint raises an IOError when self is not readable" # Errno::ENOENT: No such file or directory
  fails "IO#each_codepoint returns self" # Errno::ENOENT: No such file or directory
  fails "IO#each_codepoint when no block is given returned Enumerator size should return nil" # Errno::ENOENT: No such file or directory
  fails "IO#each_codepoint when no block is given returns an Enumerator" # Errno::ENOENT: No such file or directory
  fails "IO#each_codepoint yields each codepoint starting from the current position" # Errno::ENOENT: No such file or directory
  fails "IO#each_codepoint yields each codepoint" # Errno::ENOENT: No such file or directory
  fails "IO#each_line uses $/ as the default line separator" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed a String containing one space as a separator does not change $_" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed a String containing one space as a separator tries to convert the passed separator to a String using #to_str" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed a String containing one space as a separator uses the passed argument as the line separator" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed an empty String as a separator discards leading newlines" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed an empty String as a separator yields each paragraph" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed chomp and a separator yields each line without separator to the passed block" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed chomp and empty line as a separator yields each paragraph without trailing new line characters" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed chomp and nil as a separator yields self's content" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed chomp yields each line without trailing newline characters to the passed block" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed chomp, nil as a separator, and a limit yields each line of limit size without truncating trailing new line character" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed nil as a separator yields self's content starting from the current position when the passed separator is nil" # Errno::ENOENT: No such file or directory
  fails "IO#each_line when passed too many arguments raises ArgumentError" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with both separator and limit when a block is given accepts an empty block" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with both separator and limit when a block is given when passed an empty String as a separator discards leading newlines" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with both separator and limit when a block is given when passed an empty String as a separator yields each paragraph" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with both separator and limit when a block is given when passed nil as a separator yields self's content starting from the current position when the passed separator is nil" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with both separator and limit when no block is given returned Enumerator size should return nil" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with both separator and limit when no block is given returns an Enumerator" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with limit when limit is 0 raises an ArgumentError" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator does not change $_" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator makes line count accessible via $." # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator makes line count accessible via lineno" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator raises an IOError when self is not readable" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator returns self" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator when no block is given returned Enumerator size should return nil" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator when no block is given returns an Enumerator" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator yields each line starting from the current position" # Errno::ENOENT: No such file or directory
  fails "IO#each_line with no separator yields each line to the passed block" # Errno::ENOENT: No such file or directory
  fails "IO#eof? does not consume the data from the stream" # Errno::ENOENT: No such file or directory
  fails "IO#eof? raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#eof? raises IOError on stream closed for reading by close_read" # Errno::ENOENT: No such file or directory
  fails "IO#eof? raises IOError on stream not opened for reading" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns false on just opened non-empty stream" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns false on receiving side of Pipe when writing side wrote some data" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO#eof? returns false when not at end of file" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns true after reading with read with no parameters" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns true after reading with read" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns true after reading with readlines" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns true after reading with sysread" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns true on an empty stream that has just been opened" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns true on one-byte stream after single-byte read" # Errno::ENOENT: No such file or directory
  fails "IO#eof? returns true on receiving side of Pipe when writing side is closed" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO#external_encoding can be retrieved from a closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_internal is nil returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_internal is nil returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'a+' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_internal is nil returns Encoding.default_external if the external encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_internal is nil returns Encoding.default_external when that encoding is changed after the instance is created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_internal is nil returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'r+' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'rb' mode returns Encoding::BINARY" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'rb' mode returns the external encoding specified by the mode argument" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_internal is nil returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_internal is nil returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'w+' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'wb' mode returns Encoding::BINARY" # Errno::ENOENT: No such file or directory
  fails "IO#external_encoding with 'wb' mode returns the external encoding specified by the mode argument" # Errno::ENOENT: No such file or directory
  fails "IO#fcntl raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#fileno raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#flush raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#fsync raises an IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#getbyte raises an IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#getbyte returns nil on empty stream" # Errno::ENOENT: No such file or directory
  fails "IO#getbyte returns nil when invoked at the end of the stream" # Errno::ENOENT: No such file or directory
  fails "IO#getbyte returns the next byte from the stream" # Errno::ENOENT: No such file or directory
  fails "IO#getc raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#getc returns nil on empty stream" # Errno::ENOENT: No such file or directory
  fails "IO#getc returns nil when invoked at the end of the stream" # Errno::ENOENT: No such file or directory
  fails "IO#getc returns the next character from the stream" # Errno::ENOENT: No such file or directory
  fails "IO#gets assigns the returned line to $_" # Errno::ENOENT: No such file or directory
  fails "IO#gets calls #to_int to convert a single object argument to an Integer limit" # Errno::ENOENT: No such file or directory
  fails "IO#gets calls #to_int to convert the second object argument to an Integer limit" # Errno::ENOENT: No such file or directory
  fails "IO#gets calls #to_str to convert the first argument to a String when passed a limit" # Errno::ENOENT: No such file or directory
  fails "IO#gets ignores the internal encoding if the default external encoding is BINARY" # Errno::ENOENT: No such file or directory
  fails "IO#gets overwrites the default external encoding with the IO object's own external encoding" # Errno::ENOENT: No such file or directory
  fails "IO#gets raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#gets reads all bytes when pass a separator and reading more than all bytes" # Errno::ENOENT: No such file or directory
  fails "IO#gets reads all bytes when the limit is higher than the available bytes" # Errno::ENOENT: No such file or directory
  fails "IO#gets reads limit bytes and extra bytes when limit is reached not at character boundary" # Errno::ENOENT: No such file or directory
  fails "IO#gets reads limit bytes when passed '' and a limit less than the next paragraph" # Errno::ENOENT: No such file or directory
  fails "IO#gets reads limit bytes when passed a single argument less than the number of bytes to the default separator" # Errno::ENOENT: No such file or directory
  fails "IO#gets reads limit bytes when passed nil and a limit" # Errno::ENOENT: No such file or directory
  fails "IO#gets reads to the default separator when passed a single argument greater than the number of bytes to the separator" # Errno::ENOENT: No such file or directory
  fails "IO#gets reads until the next paragraph when passed '' and a limit greater than the next paragraph" # Errno::ENOENT: No such file or directory
  fails "IO#gets returns empty string when 0 passed as a limit" # Errno::ENOENT: No such file or directory
  fails "IO#gets returns nil if called at the end of the stream" # Errno::ENOENT: No such file or directory
  fails "IO#gets transcodes into the IO object's internal encoding, when set" # Errno::ENOENT: No such file or directory
  fails "IO#gets transcodes into the default internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#gets transcodes to internal encoding if the IO object's external encoding is BINARY" # Errno::ENOENT: No such file or directory
  fails "IO#gets uses the IO object's external encoding, when set" # Errno::ENOENT: No such file or directory
  fails "IO#gets uses the default external encoding" # Errno::ENOENT: No such file or directory
  fails "IO#gets when passed chomp returns the first line without a trailing newline character" # Errno::ENOENT: No such file or directory
  fails "IO#gets with ASCII separator returns the separator's character representation" # Errno::ENOENT: No such file or directory
  fails "IO#gets with an arbitrary String separator reads up to and including the separator" # Errno::ENOENT: No such file or directory
  fails "IO#gets with an arbitrary String separator updates $. with each invocation" # Errno::ENOENT: No such file or directory
  fails "IO#gets with an arbitrary String separator updates lineno with each invocation" # Errno::ENOENT: No such file or directory
  fails "IO#gets with an empty String separator reads until the beginning of the next paragraph" # Errno::ENOENT: No such file or directory
  fails "IO#gets with an empty String separator returns the next paragraph" # Errno::ENOENT: No such file or directory
  fails "IO#gets with an empty String separator updates $. with each invocation" # Errno::ENOENT: No such file or directory
  fails "IO#gets with an empty String separator updates lineno with each invocation" # Errno::ENOENT: No such file or directory
  fails "IO#gets with nil separator returns the entire contents" # Errno::ENOENT: No such file or directory
  fails "IO#gets with nil separator updates $. with each invocation" # Errno::ENOENT: No such file or directory
  fails "IO#gets with nil separator updates lineno with each invocation" # Errno::ENOENT: No such file or directory
  fails "IO#gets with no separator returns the next line of string that is separated by $/" # Errno::ENOENT: No such file or directory
  fails "IO#gets with no separator updates $. with each invocation" # Errno::ENOENT: No such file or directory
  fails "IO#gets with no separator updates lineno with each invocation" # Errno::ENOENT: No such file or directory
  fails "IO#initialize raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#inspect contains \"(closed)\" if the stream is closed" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO#inspect contains the file descriptor number" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO#internal_encoding can be retrieved from a closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal == Encoding.default_external returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal is not set returns the value set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal == Encoding.default_external returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal is not set returns the value set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal == Encoding.default_external returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal is not set returns the value set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal == Encoding.default_external returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal is not set returns the value set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal == Encoding.default_external returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal is not set returns the value set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal == Encoding.default_external returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # Errno::ENOENT: No such file or directory
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal is not set returns the value set when the instance was created" # Errno::ENOENT: No such file or directory
  fails "IO#ioctl raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#isatty raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#isatty returns false if this stream is not a terminal device (TTY)" # Errno::ENOENT: No such file or directory
  fails "IO#lineno raises an IOError on a closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#lineno raises an IOError on a duplexed stream with the read side closed" # Errno::ENOENT: No such file or directory
  fails "IO#lineno raises an IOError on a write-only stream" # Errno::ENOENT: No such file or directory
  fails "IO#lineno returns the current line number" # Errno::ENOENT: No such file or directory
  fails "IO#lineno= calls #to_int on a non-numeric argument" # Errno::ENOENT: No such file or directory
  fails "IO#lineno= does not change $. until next read" # Errno::ENOENT: No such file or directory
  fails "IO#lineno= does not change $." # Errno::ENOENT: No such file or directory
  fails "IO#lineno= raises an IOError on a closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#lineno= raises an IOError on a duplexed stream with the read side closed" # Errno::ENOENT: No such file or directory
  fails "IO#lineno= raises an IOError on a write-only stream" # Errno::ENOENT: No such file or directory
  fails "IO#lineno= sets the current line number to the given value" # Errno::ENOENT: No such file or directory
  fails "IO#lineno= truncates a Float argument" # Errno::ENOENT: No such file or directory
  fails "IO#nonblock= changes the IO to non-blocking mode" # Errno::ENOENT: No such file or directory
  fails "IO#nonblock? returns false for a file by default" # Errno::ENOENT: No such file or directory
  fails "IO#pid raises an IOError on closed stream" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO#pid returns nil for IO not associated with a process" # Errno::ENOENT: No such file or directory
  fails "IO#pid returns the ID of a process associated with stream" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO#pos gets the offset" # Expected 2  == 3  to be truthy but was false
  fails "IO#pos raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#pos= raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#pread accepts a length, and an offset" # Errno::ENOENT: No such file or directory
  fails "IO#pread does not advance the file pointer" # Errno::ENOENT: No such file or directory
  fails "IO#pread raises EOFError if end-of-file is reached" # Errno::ENOENT: No such file or directory
  fails "IO#pread raises IOError when file is closed" # Errno::ENOENT: No such file or directory
  fails "IO#pread raises IOError when file is not open in read mode" # Errno::ENOENT: No such file or directory
  fails "IO#print calls obj.to_s and not obj.to_str then writes the record separator" # Errno::ENOENT: No such file or directory
  fails "IO#print raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#print returns nil" # Errno::ENOENT: No such file or directory
  fails "IO#print writes $_.to_s followed by $\\ (if any) to the stream if no arguments given" # Errno::ENOENT: No such file or directory
  fails "IO#print writes each obj.to_s to the stream separated by $, (if any) and appends $\\ (if any) given multiple objects" # Errno::ENOENT: No such file or directory
  fails "IO#printf raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#puts raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#pwrite accepts a string and an offset" # EOFError: EOFError
  fails "IO#read can be read from consecutively" # Errno::ENOENT: No such file or directory
  fails "IO#read consumes zero bytes when reading zero bytes" # Errno::ENOENT: No such file or directory
  fails "IO#read ignores unicode encoding" # Errno::ENOENT: No such file or directory
  fails "IO#read in binary mode does not transcode file contents when Encoding.default_internal is set" # Errno::ENOENT: No such file or directory
  fails "IO#read in text mode reads data according to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#read is at end-of-file when everything has been read" # Errno::ENOENT: No such file or directory
  fails "IO#read raises ArgumentError when length is less than 0" # Errno::ENOENT: No such file or directory
  fails "IO#read raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#read raises an ArgumentError when not passed a valid length" # Errno::ENOENT: No such file or directory
  fails "IO#read reads the contents of a file when more bytes are specified" # Errno::ENOENT: No such file or directory
  fails "IO#read reads the contents of a file" # Errno::ENOENT: No such file or directory
  fails "IO#read returns an empty string at end-of-file" # Errno::ENOENT: No such file or directory
  fails "IO#read returns an empty string when the current pos is bigger than the content size" # Errno::ENOENT: No such file or directory
  fails "IO#read returns nil at end-of-file with a length" # Errno::ENOENT: No such file or directory
  fails "IO#read treats first nil argument as no length limit" # Errno::ENOENT: No such file or directory
  fails "IO#read when IO#external_encoding and IO#internal_encoding are nil sets the String encoding to Encoding.default_external" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding not specified does not transcode the String" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding not specified reads bytes when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding not specified returns a String in BINARY when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding not specified sets the String encoding to the external encoding" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by encoding: option reads bytes when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by encoding: option returns a String in BINARY when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by encoding: option returns a transcoded String" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by encoding: option sets the String encoding to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by internal_encoding: option reads bytes when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by internal_encoding: option returns a String in BINARY when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by internal_encoding: option returns a transcoded String" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by internal_encoding: option sets the String encoding to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by mode: option reads bytes when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by mode: option returns a String in BINARY when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by mode: option returns a transcoded String" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by mode: option sets the String encoding to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by open mode reads bytes when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by open mode returns a String in BINARY when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by open mode returns a transcoded String" # Errno::ENOENT: No such file or directory
  fails "IO#read with internal encoding specified by open mode sets the String encoding to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#read with large data reads all the data at once" # Errno::ENOENT: No such file or directory
  fails "IO#read with large data reads only the requested number of bytes" # Errno::ENOENT: No such file or directory
  fails "IO#read with length argument returns nil when the current pos is bigger than the content size" # Errno::ENOENT: No such file or directory
  fails "IO#readbyte raises EOFError on EOF" # Errno::ENOENT: No such file or directory
  fails "IO#readbyte reads one byte from the stream" # Errno::ENOENT: No such file or directory
  fails "IO#readchar raises EOFError on empty stream" # Errno::ENOENT: No such file or directory
  fails "IO#readchar raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#readchar raises an EOFError when invoked at the end of the stream" # Errno::ENOENT: No such file or directory
  fails "IO#readchar returns the next string from the stream" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding not specified does not transcode the String" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding not specified sets the String encoding to the external encoding" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding specified by encoding: option returns a transcoded String" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding specified by encoding: option sets the String encoding to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding specified by internal_encoding: option returns a transcoded String" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding specified by internal_encoding: option sets the String encoding to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding specified by mode: option returns a transcoded String" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding specified by mode: option sets the String encoding to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding specified by open mode returns a transcoded String" # Errno::ENOENT: No such file or directory
  fails "IO#readchar with internal encoding specified by open mode sets the String encoding to the internal encoding" # Errno::ENOENT: No such file or directory
  fails "IO#readline assigns the returned line to $_" # Errno::ENOENT: No such file or directory
  fails "IO#readline goes back to first position after a rewind" # Errno::ENOENT: No such file or directory
  fails "IO#readline raises EOFError on end of stream" # Errno::ENOENT: No such file or directory
  fails "IO#readline raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#readline returns characters after the position set by #seek" # Errno::ENOENT: No such file or directory
  fails "IO#readline returns the next line on the stream" # Errno::ENOENT: No such file or directory
  fails "IO#readline when passed chomp returns the first line without a trailing newline character" # Errno::ENOENT: No such file or directory
  fails "IO#readline when passed limit reads limit bytes" # Errno::ENOENT: No such file or directory
  fails "IO#readline when passed limit returns an empty string when passed 0 as a limit" # Errno::ENOENT: No such file or directory
  fails "IO#readline when passed separator and limit reads limit bytes till the separator" # Errno::ENOENT: No such file or directory
  fails "IO#readlines raises an IOError if the stream is closed" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed a separator does not change $_" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed a separator returns an Array containing lines based on the separator" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed a separator returns an empty Array when self is at the end" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed a separator tries to convert the passed separator to a String using #to_str" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed a separator updates self's lineno based on the number of lines read" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed a separator updates self's position based on the number of characters read" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed an empty String returns an Array containing all paragraphs" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed arbitrary keyword argument tolerates it" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed chomp returns the first line without a trailing newline character" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed limit raises ArgumentError when passed 0 as a limit" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed nil returns the remaining content as one line starting at the current position" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed no arguments does not change $_" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed no arguments returns an Array containing lines based on $/" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed no arguments returns an empty Array when self is at the end" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed no arguments updates self's lineno based on the number of lines read" # Errno::ENOENT: No such file or directory
  fails "IO#readlines when passed no arguments updates self's position" # Errno::ENOENT: No such file or directory
  fails "IO#readpartial immediately returns an empty string if the length argument is 0" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial raises ArgumentError if the negative argument is provided" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial raises EOFError on EOF" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial raises IOError if the stream is closed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial raises IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial reads at most the specified number of bytes" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen raises an IOError if the IO argument is closed" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#reopen raises an IOError if the object returned by #to_io is closed" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with a String calls #to_path on non-String arguments" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with a String does not raise an exception when called on a closed stream with a path" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with a String passes all mode flags through" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with a String positions a newly created instance at the beginning of the new stream" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with a String positions an instance that has been read from at the beginning of the new stream" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with a String raises an Errno::ENOENT if the file does not exist and the IO is not opened in write mode" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with a String returns self" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with an IO at EOF resets the EOF status to false" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with an IO does not change the object_id" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with an IO reads from the beginning if the other IO has not been read from" # Errno::ENOENT: No such file or directory
  fails "IO#reopen with an IO reads from the current position of the other IO's stream" # Errno::ENOENT: No such file or directory
  fails "IO#rewind positions the instance to the beginning of input and clears EOF" # Errno::ENOENT: No such file or directory
  fails "IO#rewind positions the instance to the beginning of input" # Errno::ENOENT: No such file or directory
  fails "IO#rewind positions the instance to the beginning of output for write-only IO" # Errno::ENOENT: No such file or directory
  fails "IO#rewind raises IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#rewind returns 0" # Errno::ENOENT: No such file or directory
  fails "IO#rewind sets lineno to 0" # Errno::ENOENT: No such file or directory
  fails "IO#seek moves the read position and clears EOF with SEEK_CUR" # Errno::ENOENT: No such file or directory
  fails "IO#seek moves the read position and clears EOF with SEEK_END" # Errno::ENOENT: No such file or directory
  fails "IO#seek moves the read position and clears EOF with SEEK_SET" # Errno::ENOENT: No such file or directory
  fails "IO#seek moves the read position relative to the current position with SEEK_CUR" # Errno::ENOENT: No such file or directory
  fails "IO#seek moves the read position relative to the end with SEEK_END" # Errno::ENOENT: No such file or directory
  fails "IO#seek moves the read position relative to the start with SEEK_SET" # Errno::ENOENT: No such file or directory
  fails "IO#seek raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#set_encoding calls #to_str to convert an abject to a String" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding calls #to_str to convert the second argument to a String" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding ignores the internal encoding if the same as external when passed Encoding objects" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding ignores the internal encoding if the same as external when passed encoding names separated by ':'" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding raises ArgumentError when no arguments are given" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding returns self" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding sets the external and internal encoding when passed the names of Encodings separated by ':'" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding sets the external and internal encoding when passed two Encoding arguments" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding sets the external and internal encoding when passed two String arguments" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding sets the external encoding when passed an Encoding argument" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding sets the external encoding when passed the name of an Encoding" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'a' mode prevents the encodings from changing when Encoding defaults are changed" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'a' mode sets the encodings to nil when the IO is built with no explicit encoding" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'a' mode sets the encodings to nil when they were set previously" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'a' mode sets the encodings to the current Encoding defaults" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'a+' mode prevents the encodings from changing when Encoding defaults are changed" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'a+' mode sets the encodings to nil when the IO is built with no explicit encoding" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'a+' mode sets the encodings to nil when they were set previously" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'a+' mode sets the encodings to the current Encoding defaults" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'r' mode allows the #external_encoding to change when Encoding.default_external is changed" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'r' mode prevents the #internal_encoding from changing when Encoding.default_internal is changed" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'r' mode sets the encodings to the current Encoding defaults" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'r+' mode prevents the encodings from changing when Encoding defaults are changed" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'r+' mode sets the encodings to nil when the IO is built with no explicit encoding" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'r+' mode sets the encodings to nil when they were set previously" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'r+' mode sets the encodings to the current Encoding defaults" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'rb' mode returns Encoding.default_external" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'w' mode prevents the encodings from changing when Encoding defaults are changed" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'w' mode sets the encodings to nil when the IO is built with no explicit encoding" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'w' mode sets the encodings to nil when they were set previously" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'w' mode sets the encodings to the current Encoding defaults" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'w+' mode prevents the encodings from changing when Encoding defaults are changed" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'w+' mode sets the encodings to nil when the IO is built with no explicit encoding" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'w+' mode sets the encodings to nil when they were set previously" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding when passed nil, nil with 'w+' mode sets the encodings to the current Encoding defaults" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns exception if encoding conversion is already set" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns exception if io not in binary mode" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns nil if UTF-16BE BOM sequence is incomplete" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns nil if UTF-16LE/UTF-32LE BOM sequence is incomplete" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns nil if UTF-32BE BOM sequence is incomplete" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns nil if UTF-8 BOM sequence is incomplete" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns nil if found BOM sequence not provided" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns nil if io is empty" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns nil if not readable" # Errno::ENOENT: No such file or directory
  fails "IO#set_encoding_by_bom returns the result encoding if found BOM UTF-8 sequence" # Errno::ENOENT: No such file or directory
  fails "IO#stat can stat pipes" # NoMethodError: undefined method `closed?' for nil
  fails "IO#stat raises IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#stat returns a File::Stat object for the stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sync raises an IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#sync returns the current sync mode" # Errno::ENOENT: No such file or directory
  fails "IO#sync= accepts non-boolean arguments" # Errno::ENOENT: No such file or directory
  fails "IO#sync= raises an IOError on closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#sync= sets the sync mode to true or false" # Errno::ENOENT: No such file or directory
  fails "IO#sysread on a file advances the position of the file by the specified number of bytes" # Expected "" == "56789" to be truthy but was false
  fails "IO#sysread on a file raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#sysread on a file reads normally even when called immediately after a buffered IO#read" # Expected "" == "56789" to be truthy but was false
  fails "IO#sysread on a file reads updated content after the flushed buffered IO#write" # Expected "" == "56789" to be truthy but was false
  fails "IO#sysread raises ArgumentError when length is less than 0" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread returns a smaller string if less than size bytes are available" # NoMethodError: undefined method `close' for nil
  fails "IO#sysseek moves the read position relative to the current position with SEEK_CUR" # Errno::ENOENT: No such file or directory
  fails "IO#sysseek moves the read position relative to the end with SEEK_END" # Errno::ENOENT: No such file or directory
  fails "IO#sysseek moves the read position relative to the start with SEEK_SET" # Errno::ENOENT: No such file or directory
  fails "IO#sysseek raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#sysseek seeks normally even when called immediately after a buffered IO#read" # Errno::ENOENT: No such file or directory
  fails "IO#syswrite advances the file position by the count of given bytes" # Expected "56789" == "5678901234" to be truthy but was false
  fails "IO#syswrite on a file does not modify the passed argument" # Expected [198, 32, 25] == [198, 146] to be truthy but was false
  fails "IO#syswrite on a pipe writes the given String to the pipe" # NoMethodError: undefined method `close' for nil
  fails "IO#syswrite raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#tell gets the offset" # Expected 2 == 3 to be truthy but was false
  fails "IO#tell raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#to_i raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#to_io returns self for closed stream" # Errno::ENOENT: No such file or directory
  fails "IO#to_io returns self for open stream" # Errno::ENOENT: No such file or directory
  fails "IO#tty? raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO#tty? returns false if this stream is not a terminal device (TTY)" # Errno::ENOENT: No such file or directory
  fails "IO#write accepts multiple arguments" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO#write advances the file position by the count of given bytes" # Expected "56789"  == "5678901234"  to be truthy but was false
  fails "IO#write on a file writes binary data if no encoding is given and multiple arguments passed" # Expected [32, 33, 196, 32, 38]  == [135, 196, 133]  to be truthy but was false
  fails "IO#write on a pipe writes the given String to the pipe" # NoMethodError: undefined method `close' for nil
  fails "IO#write raises IOError on closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO.binread raises an ArgumentError when not passed a valid length" # Errno::ENOENT: No such file or directory
  fails "IO.binread raises an Errno::EINVAL when not passed a valid offset" # Errno::ENOENT: No such file or directory
  fails "IO.binread reads the contents of a file from an offset of a specific size when specified" # Errno::ENOENT: No such file or directory
  fails "IO.binread reads the contents of a file up to a certain size when specified" # Errno::ENOENT: No such file or directory
  fails "IO.binread reads the contents of a file" # Errno::ENOENT: No such file or directory
  fails "IO.binread returns a String in BINARY encoding regardless of Encoding.default_internal" # Errno::ENOENT: No such file or directory
  fails "IO.binread returns a String in BINARY encoding" # Errno::ENOENT: No such file or directory
  fails "IO.binwrite accepts a :mode option" # Expected "hello, world!34567890123456789"  == "012345678901234567890123456789hello, world!"  to be truthy but was false
  fails "IO.binwrite creates a file if missing" # Expected File .exist? "//tmp/rubyspec_temp/IO_binwrite_filexxx"  to be falsy but was true
  fails "IO.binwrite creates file if missing even if offset given" # Expected File .exist? "//tmp/rubyspec_temp/IO_binwrite_filexxx"  to be falsy but was true
  fails "IO.for_fd raises an IOError if passed a closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO.foreach sets $_ to nil" # Errno::ENOENT: No such file or directory
  fails "IO.foreach updates $. with each yield" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when no block is given returns an Enumerator" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name calls #to_path to convert the name" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name defaults to $/ as the separator" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, keyword arguments uses the keyword arguments as options" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object calls #to_str to convert the object to a separator" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object when the object is a String accepts non-ASCII data as separator" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object when the object is a String uses the value as the separator" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object when the object is an Integer defaults to $/ as the separator" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object when the object is an Integer ignores the object as a limit if it is negative" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object when the object is an Integer uses the object as a limit if it is an Integer" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object, object when the first object is a String calls #to_int to convert the second object" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object, object when the first object is a String uses the second object as a limit if it is an Integer" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object, object when the first object is not a String or Integer calls #to_int to convert the second object" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object, object when the first object is not a String or Integer calls #to_str to convert the object to a String" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, object, object when the first object is not a String or Integer uses the second object as a limit if it is an Integer" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, separator, limit, keyword arguments calls #to_int to convert the limit argument" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, separator, limit, keyword arguments calls #to_path to convert the name object" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, separator, limit, keyword arguments calls #to_str to convert the separator object" # Errno::ENOENT: No such file or directory
  fails "IO.foreach when passed name, separator, limit, keyword arguments when passed chomp, nil as a separator, and a limit yields each line of limit size without truncating trailing new line character" # Errno::ENOENT: No such file or directory
  fails "IO.foreach yields a sequence of lines without trailing newline characters when chomp is passed" # Errno::ENOENT: No such file or directory
  fails "IO.foreach yields a sequence of paragraphs when the separator is an empty string" # Errno::ENOENT: No such file or directory
  fails "IO.foreach yields a single string with entire content when the separator is nil" # Errno::ENOENT: No such file or directory
  fails "IO.new raises an IOError if passed a closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO.open raises an IOError if passed a closed stream" # Expected IOError but got: Errno::ENOENT (No such file or directory)
  fails "IO.pipe accepts 'bom|' prefix for external encoding when specifying 'external:internal'" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe accepts 'bom|' prefix for external encoding" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe accepts an options Hash with one String encoding argument" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe accepts an options Hash with two String encoding arguments" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe calls #to_hash to convert an options argument" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe calls #to_str to convert the first argument to a String" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe calls #to_str to convert the second argument to a String" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe creates a two-ended pipe" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe does not use IO.new method to create pipes and allows its overriding" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe passed a block allows IO objects to be closed within the block" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe passed a block closes both IO objects when the block raises" # Expected RuntimeError but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "IO.pipe passed a block closes both IO objects" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe passed a block returns the result of the block" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe passed a block yields two IO objects" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe returns instances of a subclass when called on a subclass" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe returns two IO objects" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets no external encoding for the write end" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets no internal encoding for the write end" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets the external and internal encoding when passed two String arguments" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets the external and internal encodings of the read end when passed two Encoding arguments" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets the external and internal encodings specified as a String and separated with a colon" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets the external encoding of the read end to the default when passed no arguments" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets the external encoding of the read end when passed an Encoding argument" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets the external encoding of the read end when passed the name of an Encoding" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets the internal encoding of the read end to the default when passed no arguments" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.pipe sets the internal encoding to nil if the same as the external" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen coerces mode argument with #to_str" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen has the given external encoding" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen has the given internal encoding" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen raises IOError when reading a write-only pipe" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen returns an instance of a subclass when called on a subclass" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen returns an open IO" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen sets the internal encoding to nil if it's the same as the external encoding" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen with a block allows the IO to be closed inside the block" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen with a block closes the IO after yielding" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen with a block returns the value of the block" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen with a block yields an instance of a subclass when called on a subclass" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.popen with a block yields an open IO to the block" # TypeError: no implicit conversion of NilClass into Integer
  fails "IO.read accepts a length, and empty options Hash" # Errno::ENOENT: No such file or directory
  fails "IO.read accepts a length, offset, and empty options Hash" # Errno::ENOENT: No such file or directory
  fails "IO.read accepts an empty options Hash" # Errno::ENOENT: No such file or directory
  fails "IO.read calls #to_path on non-String arguments" # Errno::ENOENT: No such file or directory
  fails "IO.read disregards other options if :open_args is given" # Errno::ENOENT: No such file or directory
  fails "IO.read doesn't require mode to be specified in :open_args even if flags option passed" # Errno::ENOENT: No such file or directory
  fails "IO.read doesn't require mode to be specified in :open_args" # Errno::ENOENT: No such file or directory
  fails "IO.read on an empty file returns an empty string when no length is passed" # Errno::ENOENT: No such file or directory
  fails "IO.read on an empty file returns nil when length is passed" # Errno::ENOENT: No such file or directory
  fails "IO.read raises a TypeError when not passed a String type" # Errno::ENOENT: No such file or directory
  fails "IO.read raises an ArgumentError when not passed a valid length" # Errno::ENOENT: No such file or directory
  fails "IO.read raises an Errno::EINVAL when not passed a valid offset" # Errno::ENOENT: No such file or directory
  fails "IO.read raises an Errno::ENOENT when the requested file does not exist" # Errno::ENOENT: No such file or directory
  fails "IO.read raises an IOError if the options Hash specifies append only mode" # Errno::ENOENT: No such file or directory
  fails "IO.read raises an IOError if the options Hash specifies write mode" # Errno::ENOENT: No such file or directory
  fails "IO.read reads the contents of a file from an offset of a specific size when specified" # Errno::ENOENT: No such file or directory
  fails "IO.read reads the contents of a file up to a certain size when specified" # Errno::ENOENT: No such file or directory
  fails "IO.read reads the contents of a file" # Errno::ENOENT: No such file or directory
  fails "IO.read reads the file if the options Hash includes read mode" # Errno::ENOENT: No such file or directory
  fails "IO.read reads the file if the options Hash includes read/write append mode" # Errno::ENOENT: No such file or directory
  fails "IO.read reads the file if the options Hash includes read/write mode" # Errno::ENOENT: No such file or directory
  fails "IO.read returns a String in BINARY when passed a size" # Errno::ENOENT: No such file or directory
  fails "IO.read returns an empty string when reading zero bytes" # Errno::ENOENT: No such file or directory
  fails "IO.read returns nil at end-of-file when length is passed" # Errno::ENOENT: No such file or directory
  fails "IO.read treats second nil argument as no length limit" # Errno::ENOENT: No such file or directory
  fails "IO.read treats third nil argument as 0" # Errno::ENOENT: No such file or directory
  fails "IO.read uses an :open_args option" # Errno::ENOENT: No such file or directory
  fails "IO.read uses the external encoding specified via the :encoding option" # Errno::ENOENT: No such file or directory
  fails "IO.read uses the external encoding specified via the :external_encoding option" # Errno::ENOENT: No such file or directory
  fails "IO.read with BOM reads a file with a utf-8 bom" # Errno::ENOENT: No such file or directory
  fails "IO.read with BOM reads a file without a bom" # Errno::ENOENT: No such file or directory
  fails "IO.readlines does not change $_" # Errno::ENOENT: No such file or directory
  fails "IO.readlines encodes lines using the default external encoding" # Errno::ENOENT: No such file or directory
  fails "IO.readlines encodes lines using the default internal encoding, when set" # NoMethodError: undefined method `encode' for nil
  fails "IO.readlines ignores the default internal encoding if the external encoding is BINARY" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name calls #to_path to convert the name" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name defaults to $/ as the separator" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, keyword arguments uses the keyword arguments as options" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object calls #to_str to convert the object to a separator" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object when the object is a String accepts non-ASCII data as separator" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object when the object is a String uses the value as the separator" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object when the object is an Integer defaults to $/ as the separator" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object when the object is an Integer ignores the object as a limit if it is negative" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object when the object is an Integer uses the object as a limit if it is an Integer" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object, object when the first object is a String calls #to_int to convert the second object" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object, object when the first object is a String uses the second object as a limit if it is an Integer" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object, object when the first object is not a String or Integer calls #to_int to convert the second object" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object, object when the first object is not a String or Integer calls #to_str to convert the object to a String" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, object, object when the first object is not a String or Integer uses the second object as a limit if it is an Integer" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, separator, limit, keyword arguments calls #to_int to convert the limit argument" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, separator, limit, keyword arguments calls #to_path to convert the name object" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, separator, limit, keyword arguments calls #to_str to convert the separator object" # Errno::ENOENT: No such file or directory
  fails "IO.readlines when passed name, separator, limit, keyword arguments when passed chomp, nil as a separator, and a limit yields each line of limit size without truncating trailing new line character" # Errno::ENOENT: No such file or directory
  fails "IO.readlines yields a sequence of lines without trailing newline characters when chomp is passed" # Errno::ENOENT: No such file or directory
  fails "IO.readlines yields a sequence of paragraphs when the separator is an empty string" # Errno::ENOENT: No such file or directory
  fails "IO.readlines yields a single string with entire content when the separator is nil" # Errno::ENOENT: No such file or directory
  fails "IO.sysopen accepts mode & permission that are nil" # Errno::ENOENT: No such file or directory
  fails "IO.sysopen works on directories" # Errno::EISDIR: Is a directory
  fails "IO.write accepts a :mode option" # Expected "hello, world!34567890123456789"  == "012345678901234567890123456789hello, world!"  to be truthy but was false
  fails "IO.write creates a file if missing" # Expected File .exist? "//tmp/rubyspec_temp/IO_binwrite_filexxx"  to be falsy but was true
end
