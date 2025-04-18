# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO#<< calls #to_s on the object to print it" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#<< raises an error if the stream is closed" # NotImplementedError: File.stat is not available on this platform
  fails "IO#advise raises a NotImplementedError if advise is not recognized" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise raises a TypeError if len cannot be coerced to an Integer" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise raises a TypeError if offset cannot be coerced to an Integer" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise raises an IOError if the stream is closed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise supports the dontneed advice type" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise supports the noreuse advice type" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise supports the normal advice type" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise supports the random advice type" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise supports the sequential advice type" # NoMethodError: undefined method `closed?' for nil
  fails "IO#advise supports the willneed advice type" # NoMethodError: undefined method `closed?' for nil
  fails "IO#binmode raises an IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#binmode returns self" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#binmode sets external encoding to binary" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#binmode sets internal encoding to nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#binmode? is true after a call to IO#binmode" # NoMethodError: undefined method `close' for nil
  fails "IO#binmode? propagates to dup'ed IO objects" # NoMethodError: undefined method `close' for nil
  fails "IO#binmode? raises an IOError on closed stream" # NoMethodError: undefined method `close' for nil
  fails "IO#close closes the stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close does not call the #flush method but flushes the stream internally" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close does not close the stream if autoclose is false" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close does nothing if already closed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close on an IO.popen stream clears #pid" # NotImplementedError: File.stat is not available on this platform
  fails "IO#close raises an IOError reading from a closed IO" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close raises an IOError writing to a closed IO" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close returns nil" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec= ensures the IO's file descriptor is closed in exec'ed processes" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec= raises IOError if called on a closed IO" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec= sets the close-on-exec flag if non-false" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec= sets the close-on-exec flag if true" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec= unsets the close-on-exec flag if false" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec= unsets the close-on-exec flag if nil" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec? raises IOError if called on a closed IO" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec? returns true by default" # NoMethodError: undefined method `closed?' for nil
  fails "IO#close_on_exec? returns true if set" # NoMethodError: undefined method `closed?' for nil
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
  fails "IO#closed? returns false on open stream" # NoMethodError: undefined method `close' for nil
  fails "IO#closed? returns true on closed stream" # NoMethodError: undefined method `close' for nil
  fails "IO#dup allows closing the new IO without affecting the original" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#dup allows closing the original IO without affecting the new one" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#dup always sets the autoclose flag for the new IO object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#dup always sets the close-on-exec flag for the new IO object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#dup raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#dup returns a new IO instance" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#dup sets a new descriptor on the returned object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#each uses $/ as the default line separator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed a String containing one space as a separator does not change $_" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed a String containing one space as a separator tries to convert the passed separator to a String using #to_str" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed a String containing one space as a separator uses the passed argument as the line separator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed an empty String as a separator discards leading newlines" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed an empty String as a separator yields each paragraph" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed chomp and a separator yields each line without separator to the passed block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed chomp and empty line as a separator yields each paragraph without trailing new line characters" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed chomp and nil as a separator yields self's content" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed chomp yields each line without trailing newline characters to the passed block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed chomp, nil as a separator, and a limit yields each line of limit size without truncating trailing new line character" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed nil as a separator yields self's content starting from the current position when the passed separator is nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each when passed too many arguments raises ArgumentError" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with both separator and limit when a block is given accepts an empty block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with both separator and limit when a block is given when passed an empty String as a separator discards leading newlines" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with both separator and limit when a block is given when passed an empty String as a separator yields each paragraph" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with both separator and limit when a block is given when passed nil as a separator yields self's content starting from the current position when the passed separator is nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with both separator and limit when no block is given returned Enumerator size should return nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with both separator and limit when no block is given returns an Enumerator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with limit when limit is 0 raises an ArgumentError" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator does not change $_" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator makes line count accessible via $." # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator makes line count accessible via lineno" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator raises an IOError when self is not readable" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator returns self" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator when no block is given returned Enumerator size should return nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator when no block is given returns an Enumerator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator yields each line starting from the current position" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each with no separator yields each line to the passed block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_byte raises IOError on closed stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_byte returns self on an empty stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_byte when no block is given returned Enumerator size should return nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_byte when no block is given returns an Enumerator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_byte yields each byte" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_char does not yield any characters on an empty stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_char raises IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_char raises an IOError when an enumerator created on a closed stream is accessed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_char returns an enumerator for a closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_char returns itself" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_char when no block is given returned Enumerator size should return nil" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_char when no block is given returns an Enumerator" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_char yields each character" # NoMethodError: undefined method `closed?' for nil
  fails "IO#each_codepoint calls the given block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_codepoint does not change $_" # NoMethodError: undefined method `close' for nil
  fails "IO#each_codepoint raises an IOError when self is not readable" # NoMethodError: undefined method `close' for nil
  fails "IO#each_codepoint returns self" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_codepoint when no block is given returned Enumerator size should return nil" # NoMethodError: undefined method `close' for nil
  fails "IO#each_codepoint when no block is given returns an Enumerator" # NoMethodError: undefined method `close' for nil
  fails "IO#each_codepoint yields each codepoint starting from the current position" # NoMethodError: undefined method `close' for nil
  fails "IO#each_codepoint yields each codepoint" # NoMethodError: undefined method `close' for nil
  fails "IO#each_line uses $/ as the default line separator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed a String containing one space as a separator does not change $_" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed a String containing one space as a separator tries to convert the passed separator to a String using #to_str" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed a String containing one space as a separator uses the passed argument as the line separator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed an empty String as a separator discards leading newlines" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed an empty String as a separator yields each paragraph" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed chomp and a separator yields each line without separator to the passed block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed chomp and empty line as a separator yields each paragraph without trailing new line characters" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed chomp and nil as a separator yields self's content" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed chomp yields each line without trailing newline characters to the passed block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed chomp, nil as a separator, and a limit yields each line of limit size without truncating trailing new line character" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed nil as a separator yields self's content starting from the current position when the passed separator is nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line when passed too many arguments raises ArgumentError" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with both separator and limit when a block is given accepts an empty block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with both separator and limit when a block is given when passed an empty String as a separator discards leading newlines" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with both separator and limit when a block is given when passed an empty String as a separator yields each paragraph" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with both separator and limit when a block is given when passed nil as a separator yields self's content starting from the current position when the passed separator is nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with both separator and limit when no block is given returned Enumerator size should return nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with both separator and limit when no block is given returns an Enumerator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with limit when limit is 0 raises an ArgumentError" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator does not change $_" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator makes line count accessible via $." # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator makes line count accessible via lineno" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator raises an IOError when self is not readable" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator returns self" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator when no block is given returned Enumerator size should return nil" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator when no block is given returns an Enumerator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator yields each line starting from the current position" # NotImplementedError: File.stat is not available on this platform
  fails "IO#each_line with no separator yields each line to the passed block" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? does not consume the data from the stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? raises IOError on closed stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? raises IOError on stream closed for reading by close_read" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? raises IOError on stream not opened for reading" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#eof? returns false on just opened non-empty stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? returns false on receiving side of Pipe when writing side wrote some data" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO#eof? returns false when not at end of file" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? returns true after reading with read with no parameters" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? returns true after reading with read" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? returns true after reading with readlines" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? returns true after reading with sysread" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? returns true on an empty stream that has just been opened" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#eof? returns true on one-byte stream after single-byte read" # NotImplementedError: File.stat is not available on this platform
  fails "IO#eof? returns true on receiving side of Pipe when writing side is closed" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO#external_encoding can be retrieved from a closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_internal is nil returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_internal is nil returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'a+' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_internal is nil returns Encoding.default_external if the external encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_internal is nil returns Encoding.default_external when that encoding is changed after the instance is created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_internal is nil returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'r+' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'rb' mode returns Encoding::BINARY" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'rb' mode returns the external encoding specified by the mode argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_internal is nil returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external != Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external != Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external != Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external == Encoding.default_internal returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external == Encoding.default_internal returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_external == Encoding.default_internal returns the value of Encoding.default_external when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_internal is nil returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_internal is nil returns the encoding set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'w+' mode when Encoding.default_internal is nil returns the external encoding specified when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'wb' mode returns Encoding::BINARY" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#external_encoding with 'wb' mode returns the external encoding specified by the mode argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#fcntl raises IOError on closed stream" # Expected IOError but got: NotImplementedError (File.stat is not available on this platform)
  fails "IO#fileno raises IOError on closed stream" # Expected IOError but got: NotImplementedError (File.stat is not available on this platform)
  fails "IO#flush raises IOError on closed stream" # Expected IOError but got: NotImplementedError (File.stat is not available on this platform)
  fails "IO#fsync raises an IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#fsync writes the buffered data to permanent storage" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#getbyte raises an IOError if the stream is not readable" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#getbyte raises an IOError on closed stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#getbyte returns nil on empty stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#getbyte returns nil when invoked at the end of the stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#getbyte returns the next byte from the stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#getc raises IOError on closed stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#getc returns nil on empty stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#getc returns nil when invoked at the end of the stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#getc returns the next character from the stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets assigns the returned line to $_" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets calls #to_int to convert a single object argument to an Integer limit" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets calls #to_int to convert the second object argument to an Integer limit" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets calls #to_str to convert the first argument to a String when passed a limit" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets ignores the internal encoding if the default external encoding is BINARY" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets overwrites the default external encoding with the IO object's own external encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets raises IOError on closed stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets raises an IOError if the stream is opened for append only" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets raises an IOError if the stream is opened for writing only" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets reads all bytes when pass a separator and reading more than all bytes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets reads all bytes when the limit is higher than the available bytes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets reads limit bytes and extra bytes when limit is reached not at character boundary" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets reads limit bytes when passed '' and a limit less than the next paragraph" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets reads limit bytes when passed a single argument less than the number of bytes to the default separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets reads limit bytes when passed nil and a limit" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets reads to the default separator when passed a single argument greater than the number of bytes to the separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets reads until the next paragraph when passed '' and a limit greater than the next paragraph" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets returns empty string when 0 passed as a limit" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets returns nil if called at the end of the stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets transcodes into the IO object's internal encoding, when set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets transcodes into the default internal encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets transcodes to internal encoding if the IO object's external encoding is BINARY" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets uses the IO object's external encoding, when set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets uses the default external encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets when passed chomp returns the first line without a trailing newline character" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with ASCII separator returns the separator's character representation" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#gets with an arbitrary String separator reads up to and including the separator" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with an arbitrary String separator updates $. with each invocation" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with an arbitrary String separator updates lineno with each invocation" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with an empty String separator reads until the beginning of the next paragraph" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with an empty String separator returns the next paragraph" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with an empty String separator updates $. with each invocation" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with an empty String separator updates lineno with each invocation" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with nil separator returns the entire contents" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with nil separator updates $. with each invocation" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with nil separator updates lineno with each invocation" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with no separator returns the next line of string that is separated by $/" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with no separator updates $. with each invocation" # NotImplementedError: File.stat is not available on this platform
  fails "IO#gets with no separator updates lineno with each invocation" # NotImplementedError: File.stat is not available on this platform
  fails "IO#initialize calls #to_int to coerce the object passed as an fd" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#initialize raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#initialize raises a TypeError when passed a String" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#initialize raises a TypeError when passed an IO" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#initialize raises a TypeError when passed nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#initialize raises an Errno::EBADF when given an invalid file descriptor" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#initialize reassociates the IO instance with the new descriptor when passed an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#inspect contains \"(closed)\" if the stream is closed" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO#inspect contains the file descriptor number" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO#internal_encoding can be retrieved from a closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal == Encoding.default_external returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a' mode when Encoding.default_internal is not set returns the value set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal == Encoding.default_external returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'a+' mode when Encoding.default_internal is not set returns the value set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal == Encoding.default_external returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r' mode when Encoding.default_internal is not set returns the value set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal == Encoding.default_external returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'r+' mode when Encoding.default_internal is not set returns the value set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal == Encoding.default_external returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w' mode when Encoding.default_internal is not set returns the value set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external does not change when Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external does not change when set and Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns nil when Encoding.default_external is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns nil when the external encoding is BINARY and the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns the internal encoding set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns the value of Encoding.default_internal when the instance was created if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal != Encoding.default_external returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal == Encoding.default_external returns nil regardless of Encoding.default_internal changes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal == Encoding.default_external returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal is not set returns nil if Encoding.default_internal is changed after the instance is created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal is not set returns nil if the internal encoding is not set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal is not set returns the value set by #set_encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#internal_encoding with 'w+' mode when Encoding.default_internal is not set returns the value set when the instance was created" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#ioctl raises IOError on closed stream" # Expected IOError but got: NotImplementedError (File.stat is not available on this platform)
  fails "IO#isatty raises IOError on closed stream" # Expected IOError but got: NotImplementedError (File.stat is not available on this platform)
  fails "IO#isatty returns false if this stream is not a terminal device (TTY)" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO#lineno raises an IOError on a closed stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno raises an IOError on a duplexed stream with the read side closed" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno raises an IOError on a write-only stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno returns the current line number" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno= calls #to_int on a non-numeric argument" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno= does not change $. until next read" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno= does not change $." # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno= raises an IOError on a closed stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno= raises an IOError on a duplexed stream with the read side closed" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno= raises an IOError on a write-only stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno= sets the current line number to the given value" # NotImplementedError: File.stat is not available on this platform
  fails "IO#lineno= truncates a Float argument" # NotImplementedError: File.stat is not available on this platform
  fails "IO#nonblock= changes the IO to non-blocking mode" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO#nonblock? returns false for a file by default" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO#path returns the path of the file associated with the IO object" # TypeError: no implicit conversion of NilClass into String
  fails "IO#pid raises an IOError on closed stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#pid returns nil for IO not associated with a process" # NotImplementedError: File.stat is not available on this platform
  fails "IO#pid returns the ID of a process associated with stream" # NotImplementedError: File.stat is not available on this platform
  fails "IO#pos gets the offset" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#pos raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#pos resets #eof?" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#pos= converts arguments to Integers" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#pos= raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#pos= raises TypeError when cannot convert implicitly argument to Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#pos= sets the offset" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#pread accepts a length, and an offset" # NoMethodError: undefined method `close' for nil
  fails "IO#pread does not advance the file pointer" # NoMethodError: undefined method `close' for nil
  fails "IO#pread raises EOFError if end-of-file is reached" # NoMethodError: undefined method `close' for nil
  fails "IO#pread raises IOError when file is closed" # NoMethodError: undefined method `close' for nil
  fails "IO#pread raises IOError when file is not open in read mode" # NoMethodError: undefined method `close' for nil
  fails "IO#print calls obj.to_s and not obj.to_str then writes the record separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#print raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#print returns nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#print writes $_.to_s followed by $\\ (if any) to the stream if no arguments given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#print writes each obj.to_s to the stream separated by $, (if any) and appends $\\ (if any) given multiple objects" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#printf calls #to_str to convert the format object to a String" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#printf raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#printf writes the #sprintf formatted string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc calls #to_int to convert an object to an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc raises IOError on a closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc raises a TypeError when passed false" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc raises a TypeError when passed nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc raises a TypeError when passed true" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc with a String argument writes one character" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc with a String argument writes the first character" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc with an Integer argument writes one character as a String" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#putc with an Integer argument writes the low byte as a String" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#puts raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#puts writes cr when IO is opened with newline: :cr" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#puts writes crlf when IO is opened with newline: :crlf" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#puts writes just a newline when given just a newline" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#puts writes lf when IO is opened with newline: :lf" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#puts writes nothing for an empty array" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#pwrite accepts a string and an offset" # NoMethodError: undefined method `close' for nil
  fails "IO#pwrite does not advance the pointer in the file" # NoMethodError: undefined method `close' for nil
  fails "IO#pwrite raises IOError when file is closed" # NoMethodError: undefined method `close' for nil
  fails "IO#pwrite raises IOError when file is not open in write mode" # NoMethodError: undefined method `close' for nil
  fails "IO#pwrite returns the number of bytes written" # NoMethodError: undefined method `close' for nil
  fails "IO#read can be read from consecutively" # NoMethodError: undefined method `close' for nil
  fails "IO#read consumes zero bytes when reading zero bytes" # NoMethodError: undefined method `close' for nil
  fails "IO#read ignores unicode encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read in binary mode does not transcode file contents when Encoding.default_internal is set" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO#read in text mode reads data according to the internal encoding" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO#read is at end-of-file when everything has been read" # NoMethodError: undefined method `close' for nil
  fails "IO#read raises ArgumentError when length is less than 0" # NoMethodError: undefined method `close' for nil
  fails "IO#read raises IOError on closed stream" # NoMethodError: undefined method `close' for nil
  fails "IO#read raises an ArgumentError when not passed a valid length" # NoMethodError: undefined method `close' for nil
  fails "IO#read reads the contents of a file when more bytes are specified" # NoMethodError: undefined method `close' for nil
  fails "IO#read reads the contents of a file" # NoMethodError: undefined method `close' for nil
  fails "IO#read returns an empty string at end-of-file" # NoMethodError: undefined method `close' for nil
  fails "IO#read returns an empty string when the current pos is bigger than the content size" # NoMethodError: undefined method `close' for nil
  fails "IO#read returns nil at end-of-file with a length" # NoMethodError: undefined method `close' for nil
  fails "IO#read treats first nil argument as no length limit" # NoMethodError: undefined method `close' for nil
  fails "IO#read when IO#external_encoding and IO#internal_encoding are nil sets the String encoding to Encoding.default_external" # ArgumentError: ruby/core/io/fixtures/read_text.txt is not prefixed by tmp/rubyspec_temp
  fails "IO#read with internal encoding not specified does not transcode the String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding not specified reads bytes when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding not specified returns a String in BINARY when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding not specified sets the String encoding to the external encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by encoding: option reads bytes when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by encoding: option returns a String in BINARY when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by encoding: option returns a transcoded String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by encoding: option sets the String encoding to the internal encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by internal_encoding: option reads bytes when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by internal_encoding: option returns a String in BINARY when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by internal_encoding: option returns a transcoded String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by internal_encoding: option sets the String encoding to the internal encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by mode: option reads bytes when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by mode: option returns a String in BINARY when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by mode: option returns a transcoded String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by mode: option sets the String encoding to the internal encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by open mode reads bytes when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by open mode returns a String in BINARY when passed a size" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by open mode returns a transcoded String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with internal encoding specified by open mode sets the String encoding to the internal encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#read with large data reads all the data at once" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#read with large data reads only the requested number of bytes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#read with length argument returns nil when the current pos is bigger than the content size" # NoMethodError: undefined method `close' for nil
  fails "IO#readbyte raises EOFError on EOF" # NoMethodError: undefined method `close' for nil
  fails "IO#readbyte reads one byte from the stream" # NoMethodError: undefined method `close' for nil
  fails "IO#readchar raises EOFError on empty stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readchar raises IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readchar raises an EOFError when invoked at the end of the stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readchar returns the next string from the stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readchar with internal encoding not specified does not transcode the String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding not specified sets the String encoding to the external encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding specified by encoding: option returns a transcoded String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding specified by encoding: option sets the String encoding to the internal encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding specified by internal_encoding: option returns a transcoded String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding specified by internal_encoding: option sets the String encoding to the internal encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding specified by mode: option returns a transcoded String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding specified by mode: option sets the String encoding to the internal encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding specified by open mode returns a transcoded String" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readchar with internal encoding specified by open mode sets the String encoding to the internal encoding" # NotImplementedError: File.stat is not available on this platform
  fails "IO#readline assigns the returned line to $_" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline goes back to first position after a rewind" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline raises EOFError on end of stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline raises IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline returns characters after the position set by #seek" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline returns the next line on the stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline when passed chomp returns the first line without a trailing newline character" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline when passed limit reads limit bytes" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline when passed limit returns an empty string when passed 0 as a limit" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readline when passed separator and limit reads limit bytes till the separator" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines raises an IOError if the stream is closed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines raises an IOError if the stream is opened for append only" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#readlines raises an IOError if the stream is opened for write only" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#readlines when passed a separator does not change $_" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed a separator returns an Array containing lines based on the separator" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed a separator returns an empty Array when self is at the end" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed a separator tries to convert the passed separator to a String using #to_str" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed a separator updates self's lineno based on the number of lines read" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed a separator updates self's position based on the number of characters read" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed an empty String returns an Array containing all paragraphs" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed arbitrary keyword argument tolerates it" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed chomp returns the first line without a trailing newline character" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed limit raises ArgumentError when passed 0 as a limit" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed nil returns the remaining content as one line starting at the current position" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed no arguments does not change $_" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed no arguments returns an Array containing lines based on $/" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed no arguments returns an empty Array when self is at the end" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed no arguments updates self's lineno based on the number of lines read" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readlines when passed no arguments updates self's position" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial immediately returns an empty string if the length argument is 0" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial raises ArgumentError if the negative argument is provided" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial raises EOFError on EOF" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial raises IOError if the stream is closed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial raises IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#readpartial reads at most the specified number of bytes" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen calls #to_io to convert an object" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen changes the class of the instance to the class of the object returned by #to_io" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen raises a TypeError if #to_io does not return an IO instance" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen raises an IOError if the IO argument is closed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen raises an IOError if the object returned by #to_io is closed" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen raises an IOError when called on a closed stream with an IO" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen raises an IOError when called on a closed stream with an object" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String always resets the close-on-exec flag to true on non-STDIO objects" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String calls #to_path on non-String arguments" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String creates the file if it doesn't exist if the IO is opened in write mode" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String does not raise an exception when called on a closed stream with a path" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String opens a path after writing to the original file descriptor" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String passes all mode flags through" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String positions a newly created instance at the beginning of the new stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String positions an instance that has been read from at the beginning of the new stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with a String raises an Errno::ENOENT if the file does not exist and the IO is not opened in write mode" # NoMethodError: undefined method `close' for nil
  fails "IO#reopen with a String returns self" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with an IO always resets the close-on-exec flag to true on non-STDIO objects" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with an IO associates the IO instance with the other IO's stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with an IO at EOF resets the EOF status to false" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with an IO does not change the object_id" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with an IO may change the class of the instance" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with an IO reads from the beginning if the other IO has not been read from" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with an IO reads from the current position of the other IO's stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#reopen with an IO sets path equals to the other IO's path if other IO is File" # NoMethodError: undefined method `closed?' for nil
  fails "IO#rewind positions the instance to the beginning of input and clears EOF" # NoMethodError: undefined method `closed?' for nil
  fails "IO#rewind positions the instance to the beginning of input" # NoMethodError: undefined method `closed?' for nil
  fails "IO#rewind positions the instance to the beginning of output for write-only IO" # NoMethodError: undefined method `closed?' for nil
  fails "IO#rewind raises IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#rewind returns 0" # NoMethodError: undefined method `closed?' for nil
  fails "IO#rewind sets lineno to 0" # NoMethodError: undefined method `closed?' for nil
  fails "IO#seek converts arguments to Integers" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#seek moves the read position and clears EOF with SEEK_CUR" # NoMethodError: undefined method `closed?' for nil
  fails "IO#seek moves the read position and clears EOF with SEEK_END" # NoMethodError: undefined method `closed?' for nil
  fails "IO#seek moves the read position and clears EOF with SEEK_SET" # NoMethodError: undefined method `closed?' for nil
  fails "IO#seek moves the read position relative to the current position with SEEK_CUR" # NoMethodError: undefined method `closed?' for nil
  fails "IO#seek moves the read position relative to the end with SEEK_END" # NoMethodError: undefined method `closed?' for nil
  fails "IO#seek moves the read position relative to the start with SEEK_SET" # NoMethodError: undefined method `closed?' for nil
  fails "IO#seek raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#seek raises TypeError when cannot convert implicitly argument to Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#seek sets the offset" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding calls #to_str to convert an abject to a String" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding calls #to_str to convert the second argument to a String" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding ignores the internal encoding if the same as external when passed Encoding objects" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding ignores the internal encoding if the same as external when passed encoding names separated by ':'" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding raises ArgumentError when no arguments are given" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding returns self" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding sets the external and internal encoding when passed the names of Encodings separated by ':'" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding sets the external and internal encoding when passed two Encoding arguments" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding sets the external and internal encoding when passed two String arguments" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding sets the external encoding when passed an Encoding argument" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding sets the external encoding when passed the name of an Encoding" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding when passed nil, nil with 'a' mode prevents the encodings from changing when Encoding defaults are changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'a' mode sets the encodings to nil when the IO is built with no explicit encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'a' mode sets the encodings to nil when they were set previously" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'a' mode sets the encodings to the current Encoding defaults" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'a+' mode prevents the encodings from changing when Encoding defaults are changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'a+' mode sets the encodings to nil when the IO is built with no explicit encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'a+' mode sets the encodings to nil when they were set previously" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'a+' mode sets the encodings to the current Encoding defaults" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'r' mode allows the #external_encoding to change when Encoding.default_external is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'r' mode prevents the #internal_encoding from changing when Encoding.default_internal is changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'r' mode sets the encodings to the current Encoding defaults" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'r+' mode prevents the encodings from changing when Encoding defaults are changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'r+' mode sets the encodings to nil when the IO is built with no explicit encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'r+' mode sets the encodings to nil when they were set previously" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'r+' mode sets the encodings to the current Encoding defaults" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'rb' mode returns Encoding.default_external" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'w' mode prevents the encodings from changing when Encoding defaults are changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'w' mode sets the encodings to nil when the IO is built with no explicit encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'w' mode sets the encodings to nil when they were set previously" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'w' mode sets the encodings to the current Encoding defaults" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'w+' mode prevents the encodings from changing when Encoding defaults are changed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'w+' mode sets the encodings to nil when the IO is built with no explicit encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'w+' mode sets the encodings to nil when they were set previously" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding when passed nil, nil with 'w+' mode sets the encodings to the current Encoding defaults" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#set_encoding_by_bom returns exception if encoding conversion is already set" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns exception if io not in binary mode" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns nil if UTF-16BE BOM sequence is incomplete" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns nil if UTF-16LE/UTF-32LE BOM sequence is incomplete" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns nil if UTF-32BE BOM sequence is incomplete" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns nil if UTF-8 BOM sequence is incomplete" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns nil if found BOM sequence not provided" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns nil if io is empty" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns nil if not readable" # NoMethodError: undefined method `closed?' for nil
  fails "IO#set_encoding_by_bom returns the result encoding if found BOM UTF-8 sequence" # NoMethodError: undefined method `closed?' for nil
  fails "IO#stat can stat pipes" # NoMethodError: undefined method `closed?' for nil
  fails "IO#stat raises IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#stat returns a File::Stat object for the stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sync raises an IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sync returns the current sync mode" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sync= accepts non-boolean arguments" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sync= raises an IOError on closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sync= sets the sync mode to true or false" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sysread on a file advances the position of the file by the specified number of bytes" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread on a file does not raise error if called after IO#read followed by IO#syswrite" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread on a file does not raise error if called after IO#read followed by IO#write" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread on a file immediately returns an empty string if the length argument is 0" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread on a file raises IOError on closed stream" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread on a file reads normally even when called immediately after a buffered IO#read" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread on a file reads the specified number of bytes from the file" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread on a file reads updated content after the flushed buffered IO#write" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread raises ArgumentError when length is less than 0" # NoMethodError: undefined method `close' for nil
  fails "IO#sysread returns a smaller string if less than size bytes are available" # NoMethodError: undefined method `close' for nil
  fails "IO#sysseek converts arguments to Integers" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#sysseek moves the read position relative to the current position with SEEK_CUR" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sysseek moves the read position relative to the end with SEEK_END" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sysseek moves the read position relative to the start with SEEK_SET" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sysseek raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#sysseek raises TypeError when cannot convert implicitly argument to Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#sysseek seeks normally even when called immediately after a buffered IO#read" # NoMethodError: undefined method `closed?' for nil
  fails "IO#sysseek sets the offset" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite advances the file position by the count of given bytes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite checks if the file is writable if writing more than zero bytes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite coerces the argument to a string using to_s" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite does not transcode the given string even when the external encoding is set" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite does not warn if called after IO#read" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite invokes to_s on non-String argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite on a file does not modify the passed argument" # NoMethodError: undefined method `close' for nil
  fails "IO#syswrite on a file does not warn if called after IO#write with intervening IO#sysread" # NoMethodError: undefined method `close' for nil
  fails "IO#syswrite on a file writes all of the string's bytes but does not buffer them" # NoMethodError: undefined method `close' for nil
  fails "IO#syswrite on a file writes to the actual file position when called after buffered IO#read" # NoMethodError: undefined method `close' for nil
  fails "IO#syswrite on a pipe writes the given String to the pipe" # NoMethodError: undefined method `close' for nil
  fails "IO#syswrite raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite returns the number of bytes written" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite writes all of the string's bytes without buffering if mode is sync" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#syswrite writes to the current position after IO#read" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#tell gets the offset" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#tell raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#tell resets #eof?" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#to_i raises IOError on closed stream" # Expected IOError but got: NotImplementedError (File.stat is not available on this platform)
  fails "IO#to_io returns self for closed stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#to_io returns self for open stream" # NoMethodError: undefined method `closed?' for nil
  fails "IO#tty? raises IOError on closed stream" # Expected IOError but got: NotImplementedError (File.stat is not available on this platform)
  fails "IO#tty? returns false if this stream is not a terminal device (TTY)" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO#write accepts multiple arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write advances the file position by the count of given bytes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write checks if the file is writable if writing more than zero bytes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write coerces the argument to a string using to_s" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write does not warn if called after IO#read" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write invokes to_s on non-String argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write on a file does not check if the file is writable if writing zero bytes" # ArgumentError: enc must be given
  fails "IO#write on a file does not modify arguments when passed multiple arguments and external encoding not set" # ArgumentError: enc must be given
  fails "IO#write on a file returns a length of 0 when passed no arguments" # ArgumentError: enc must be given
  fails "IO#write on a file returns a length of 0 when writing a blank string" # ArgumentError: enc must be given
  fails "IO#write on a file returns a length of 0 when writing blank strings" # ArgumentError: enc must be given
  fails "IO#write on a file returns the number of bytes written" # ArgumentError: enc must be given
  fails "IO#write on a file uses the encoding from the given option for non-ascii encoding even if in binary mode" # ArgumentError: enc must be given
  fails "IO#write on a file uses the encoding from the given option for non-ascii encoding when multiple arguments passes" # ArgumentError: enc must be given
  fails "IO#write on a file uses the encoding from the given option for non-ascii encoding" # ArgumentError: enc must be given
  fails "IO#write on a file writes binary data if no encoding is given and multiple arguments passed" # ArgumentError: enc must be given
  fails "IO#write on a file writes binary data if no encoding is given" # ArgumentError: enc must be given
  fails "IO#write on a pipe writes the given String to the pipe" # NoMethodError: undefined method `close' for nil
  fails "IO#write raises IOError on closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write returns the number of bytes written" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write transcodes the given string when the external encoding is set and neither is BINARY" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write writes all of the string's bytes without buffering if mode is sync" # NotImplementedError: File.lstat is not available on this platform
  fails "IO#write writes to the current position after IO#read" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binread raises an ArgumentError when not passed a valid length" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binread raises an Errno::EINVAL when not passed a valid offset" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binread reads the contents of a file from an offset of a specific size when specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binread reads the contents of a file up to a certain size when specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binread reads the contents of a file" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binread returns a String in BINARY encoding regardless of Encoding.default_internal" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binread returns a String in BINARY encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite accepts a :flags option without :mode one" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite accepts a :mode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite coerces the argument to a string using to_s" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite creates a file if missing" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite creates file if missing even if offset given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite doesn't truncate and writes at the given offset after passing empty opts" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite doesn't truncate the file and writes the given string if an offset is given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite raises an error if readonly mode is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite returns the number of bytes written" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite truncates if empty :opts provided and offset skipped" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.binwrite truncates the file and writes the given string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd accepts a :mode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd accepts a mode argument set to nil with a valid :mode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd accepts a mode argument with a :mode option set to nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd accepts an :autoclose option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd accepts any truthy option :autoclose" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd calls #to_int on an object to convert to an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces :encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces :external_encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces :internal_encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces mode with #to_int when passed in options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces mode with #to_int" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces mode with #to_str when passed in options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces mode with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces options as second argument with #to_hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd coerces options as third argument with #to_hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd creates an IO instance from an Integer argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd creates an IO instance when STDERR is closed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd creates an IO instance when STDOUT is closed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd does not set binmode from false :binmode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd does not set binmode without being asked" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd does not use binary encoding when :encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd does not use binary encoding when :external_encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd does not use binary encoding when :internal_encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd does not use binary encoding when mode encoding is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd ignores the :internal_encoding option when the same as the external encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises ArgumentError for nil options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises ArgumentError if not passed a hash or nil for options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises ArgumentError if passed a hash for mode and nil for options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises ArgumentError if passed an empty mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises an Errno::EBADF if the file descriptor is not valid" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises an IOError if passed a closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises an error if passed conflicting binary/text mode two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises an error if passed encodings two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises an error if passed matching binary/text mode two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises an error if passed modes two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd raises an error when trying to set both binmode and textmode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd sets binmode from :binmode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd sets binmode from mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd sets external encoding to binary with :binmode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd sets external encoding to binary with binmode in mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd sets internal encoding to nil when passed '-'" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd uses the :encoding option as the external encoding when only one is given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd uses the :encoding options as the external encoding when it's an Encoding object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd uses the colon-separated encodings specified via the :encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd uses the encoding specified via the :mode option hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd uses the external and the internal encoding specified in the mode argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd uses the external encoding specified in the mode argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd uses the external encoding specified via the :external_encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.for_fd uses the internal encoding specified via the :internal_encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach raises TypeError if the first parameter is nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach raises an Errno::ENOENT if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach sets $_ to nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach updates $. with each yield" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO.foreach when no block is given returned Enumerator size should return nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when no block is given returns an Enumerator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name calls #to_path to convert the name" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name defaults to $/ as the separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, keyword arguments uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object calls #to_str to convert the object to a separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object when the object is a String accepts non-ASCII data as separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object when the object is a String uses the value as the separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object when the object is an Integer defaults to $/ as the separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object when the object is an Integer ignores the object as a limit if it is negative" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object when the object is an Integer uses the object as a limit if it is an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object when the object is an Integer when passed limit raises ArgumentError when passed 0 as a limit" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object when the object is neither Integer nor String raises TypeError exception" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, keyword arguments when the first object is a String uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, keyword arguments when the first object is an Integer uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, keyword arguments when the first object is not a String or Integer uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, object when the first object is a String calls #to_int to convert the second object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, object when the first object is a String uses the second object as a limit if it is an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, object when the first object is not a String or Integer calls #to_int to convert the second object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, object when the first object is not a String or Integer calls #to_str to convert the object to a String" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, object when the first object is not a String or Integer uses the second object as a limit if it is an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, object, object when the second object is neither Integer nor String raises TypeError exception" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, separator, limit, keyword arguments calls #to_int to convert the limit argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, separator, limit, keyword arguments calls #to_path to convert the name object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, separator, limit, keyword arguments calls #to_str to convert the separator object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, separator, limit, keyword arguments uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach when passed name, separator, limit, keyword arguments when passed chomp, nil as a separator, and a limit yields each line of limit size without truncating trailing new line character" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach yields a sequence of lines without trailing newline characters when chomp is passed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach yields a sequence of paragraphs when the separator is an empty string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.foreach yields a single string with entire content when the separator is nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new accepts a :mode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new accepts a mode argument set to nil with a valid :mode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new accepts a mode argument with a :mode option set to nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new accepts an :autoclose option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new accepts any truthy option :autoclose" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new calls #to_int on an object to convert to an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces :encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces :external_encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces :internal_encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces mode with #to_int when passed in options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces mode with #to_int" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces mode with #to_str when passed in options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces mode with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces options as second argument with #to_hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new coerces options as third argument with #to_hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new creates an IO instance from an Integer argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new creates an IO instance when STDERR is closed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new creates an IO instance when STDOUT is closed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new does not set binmode from false :binmode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new does not set binmode without being asked" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new does not use binary encoding when :encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new does not use binary encoding when :external_encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new does not use binary encoding when :internal_encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new does not use binary encoding when mode encoding is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new ignores the :internal_encoding option when the same as the external encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises ArgumentError for nil options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises ArgumentError if not passed a hash or nil for options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises ArgumentError if passed a hash for mode and nil for options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises ArgumentError if passed an empty mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises an Errno::EBADF if the file descriptor is not valid" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises an IOError if passed a closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises an error if passed conflicting binary/text mode two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises an error if passed encodings two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises an error if passed matching binary/text mode two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises an error if passed modes two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new raises an error when trying to set both binmode and textmode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new sets binmode from :binmode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new sets binmode from mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new sets external encoding to binary with :binmode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new sets external encoding to binary with binmode in mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new sets internal encoding to nil when passed '-'" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new uses the :encoding option as the external encoding when only one is given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new uses the :encoding options as the external encoding when it's an Encoding object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new uses the colon-separated encodings specified via the :encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new uses the encoding specified via the :mode option hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new uses the external and the internal encoding specified in the mode argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new uses the external encoding specified in the mode argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new uses the external encoding specified via the :external_encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.new uses the internal encoding specified via the :internal_encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open accepts a :mode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open accepts a mode argument set to nil with a valid :mode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open accepts a mode argument with a :mode option set to nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open accepts an :autoclose option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open accepts any truthy option :autoclose" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open calls #close after yielding to the block" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open calls #to_int on an object to convert to an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces :encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces :external_encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces :internal_encoding option with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces mode with #to_int when passed in options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces mode with #to_int" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces mode with #to_str when passed in options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces mode with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces options as second argument with #to_hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open coerces options as third argument with #to_hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open creates an IO instance from an Integer argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open creates an IO instance when STDERR is closed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open creates an IO instance when STDOUT is closed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open does not propagate an IOError with 'closed stream' message raised by #close" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open does not set binmode from false :binmode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open does not set binmode without being asked" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open does not use binary encoding when :encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open does not use binary encoding when :external_encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open does not use binary encoding when :internal_encoding option is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open does not use binary encoding when mode encoding is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open ignores the :internal_encoding option when the same as the external encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open propagates an exception raised by #close that is a StandardError" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open propagates an exception raised by #close that is not a StandardError" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises ArgumentError for nil options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises ArgumentError if not passed a hash or nil for options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises ArgumentError if passed a hash for mode and nil for options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises ArgumentError if passed an empty mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises an Errno::EBADF if the file descriptor is not valid" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises an IOError if passed a closed stream" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises an error if passed conflicting binary/text mode two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises an error if passed encodings two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises an error if passed matching binary/text mode two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises an error if passed modes two ways" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open raises an error when trying to set both binmode and textmode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open sets binmode from :binmode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open sets binmode from mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open sets external encoding to binary with :binmode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open sets external encoding to binary with binmode in mode string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open sets internal encoding to nil when passed '-'" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open uses the :encoding option as the external encoding when only one is given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open uses the :encoding options as the external encoding when it's an Encoding object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open uses the colon-separated encodings specified via the :encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open uses the encoding specified via the :mode option hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open uses the external and the internal encoding specified in the mode argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open uses the external encoding specified in the mode argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open uses the external encoding specified via the :external_encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.open uses the internal encoding specified via the :internal_encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.pipe accepts 'bom|' prefix for external encoding when specifying 'external:internal'" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe accepts 'bom|' prefix for external encoding" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe accepts an options Hash with one String encoding argument" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe accepts an options Hash with two String encoding arguments" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe calls #to_hash to convert an options argument" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe calls #to_str to convert the first argument to a String" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe calls #to_str to convert the second argument to a String" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe creates a two-ended pipe" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe does not use IO.new method to create pipes and allows its overriding" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe passed a block allows IO objects to be closed within the block" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe passed a block closes both IO objects when the block raises" # Expected RuntimeError but got: NotImplementedError (IO.pipe is not available on this platform)
  fails "IO.pipe passed a block closes both IO objects" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe passed a block returns the result of the block" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe passed a block yields two IO objects" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe returns instances of a subclass when called on a subclass" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe returns two IO objects" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets no external encoding for the write end" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets no internal encoding for the write end" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets the external and internal encoding when passed two String arguments" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets the external and internal encodings of the read end when passed two Encoding arguments" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets the external and internal encodings specified as a String and separated with a colon" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets the external encoding of the read end to the default when passed no arguments" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets the external encoding of the read end when passed an Encoding argument" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets the external encoding of the read end when passed the name of an Encoding" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets the internal encoding of the read end to the default when passed no arguments" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.pipe sets the internal encoding to nil if the same as the external" # NotImplementedError: IO.pipe is not available on this platform
  fails "IO.popen coerces mode argument with #to_str" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen has the given external encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen has the given internal encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen raises IOError when reading a write-only pipe" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen returns an instance of a subclass when called on a subclass" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen returns an open IO" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen sets the internal encoding to nil if it's the same as the external encoding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen with a block allows the IO to be closed inside the block" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen with a block closes the IO after yielding" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen with a block returns the value of the block" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen with a block yields an instance of a subclass when called on a subclass" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.popen with a block yields an open IO to the block" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read accepts a length, and empty options Hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read accepts a length, offset, and empty options Hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read accepts an empty options Hash" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read calls #to_path on non-String arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read disregards other options if :open_args is given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read doesn't require mode to be specified in :open_args even if flags option passed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read doesn't require mode to be specified in :open_args" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read on an empty file returns an empty string when no length is passed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read on an empty file returns nil when length is passed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read raises a TypeError when not passed a String type" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read raises an ArgumentError when not passed a valid length" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read raises an Errno::EINVAL when not passed a valid offset" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read raises an Errno::ENOENT when the requested file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read raises an IOError if the options Hash specifies append only mode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read raises an IOError if the options Hash specifies write mode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read reads the contents of a file from an offset of a specific size when specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read reads the contents of a file up to a certain size when specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read reads the contents of a file" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read reads the file if the options Hash includes read mode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read reads the file if the options Hash includes read/write append mode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read reads the file if the options Hash includes read/write mode" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read returns a String in BINARY when passed a size" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read returns an empty string when reading zero bytes" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read returns nil at end-of-file when length is passed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read treats second nil argument as no length limit" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read treats third nil argument as 0" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read uses an :open_args option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read uses the external encoding specified via the :encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read uses the external encoding specified via the :external_encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.read with BOM reads a file with a utf-8 bom" # NotImplementedError: File.stat is not available on this platform
  fails "IO.read with BOM reads a file without a bom" # NotImplementedError: File.stat is not available on this platform
  fails "IO.readlines does not change $_" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines encodes lines using the default external encoding" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO.readlines encodes lines using the default internal encoding, when set" # NoMethodError: undefined method `encode' for nil
  fails "IO.readlines ignores the default internal encoding if the external encoding is BINARY" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "IO.readlines raises TypeError if the first parameter is nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines raises an Errno::ENOENT if the file does not exist" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name calls #to_path to convert the name" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name defaults to $/ as the separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, keyword arguments uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object calls #to_str to convert the object to a separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object when the object is a String accepts non-ASCII data as separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object when the object is a String uses the value as the separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object when the object is an Integer defaults to $/ as the separator" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object when the object is an Integer ignores the object as a limit if it is negative" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object when the object is an Integer uses the object as a limit if it is an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object when the object is an Integer when passed limit raises ArgumentError when passed 0 as a limit" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object when the object is neither Integer nor String raises TypeError exception" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, keyword arguments when the first object is a String uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, keyword arguments when the first object is an Integer uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, keyword arguments when the first object is not a String or Integer uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, object when the first object is a String calls #to_int to convert the second object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, object when the first object is a String uses the second object as a limit if it is an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, object when the first object is not a String or Integer calls #to_int to convert the second object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, object when the first object is not a String or Integer calls #to_str to convert the object to a String" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, object when the first object is not a String or Integer uses the second object as a limit if it is an Integer" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, object, object when the second object is neither Integer nor String raises TypeError exception" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, separator, limit, keyword arguments calls #to_int to convert the limit argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, separator, limit, keyword arguments calls #to_path to convert the name object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, separator, limit, keyword arguments calls #to_str to convert the separator object" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, separator, limit, keyword arguments uses the keyword arguments as options" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines when passed name, separator, limit, keyword arguments when passed chomp, nil as a separator, and a limit yields each line of limit size without truncating trailing new line character" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines yields a sequence of lines without trailing newline characters when chomp is passed" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines yields a sequence of paragraphs when the separator is an empty string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.readlines yields a single string with entire content when the separator is nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.sysopen accepts a mode as second argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.sysopen accepts mode & permission that are nil" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.sysopen accepts permissions as third argument" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.sysopen calls #to_path to convert an object to a path" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.sysopen returns the file descriptor for a given path" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.sysopen works on directories" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.try_convert calls #to_io to coerce an object" # NoMethodError: undefined method `closed?' for nil
  fails "IO.try_convert does not call #to_io on an IO instance" # NoMethodError: undefined method `closed?' for nil
  fails "IO.try_convert propagates an exception raised by #to_io" # NoMethodError: undefined method `closed?' for nil
  fails "IO.try_convert returns nil when the passed object does not respond to #to_io" # NoMethodError: undefined method `closed?' for nil
  fails "IO.try_convert returns the passed IO object" # NoMethodError: undefined method `closed?' for nil
  fails "IO.write accepts a :mode option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write coerces the argument to a string using to_s" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write creates a file if missing" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write creates file if missing even if offset given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write disregards other options if :open_args is given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write doesn't truncate and writes at the given offset after passing empty opts" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write doesn't truncate the file and writes the given string if an offset is given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write raises ArgumentError if encoding is specified in mode parameter and is given as :encoding option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write raises an error if readonly mode is specified" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write requires mode to be specified in :open_args" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write returns the number of bytes written" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write truncates if empty :opts provided and offset skipped" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write truncates the file and writes the given string" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write uses an :open_args option" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write uses the given encoding and returns the number of bytes written" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write writes binary data if no encoding is given" # NotImplementedError: File.lstat is not available on this platform
  fails "IO.write writes the file with the permissions in the :perm parameter" # NotImplementedError: File.lstat is not available on this platform
end
