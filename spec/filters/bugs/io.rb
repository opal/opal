# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO#<< writes an object to the IO stream" # Expected (STDERR): "Oh noes, an error!"           but got: "" Backtrace
  fails "IO#advise raises a RangeError if len is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "IO#advise raises a RangeError if offset is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "IO#advise raises a TypeError if advise is not a Symbol" # Expected TypeError but no exception was raised (nil was returned)
  fails "IO#close on an IO.popen stream sets $?" # NoMethodError: undefined method `exitstatus' for nil
  fails "IO#close on an IO.popen stream waits for the child to exit" # NoMethodError: undefined method `exitstatus' for nil
  fails "IO#close raises an IOError with a clear message" # Expected IOError (stream closed in another thread) but got: NotImplementedError (Thread creation not available)
  fails "IO#close_write flushes and closes the write stream" # Expected "" ==  "12345 " to be truthy but was false
  fails "IO#close_write raises an IOError if the stream is readable and not duplexed" # Expected IOError but no exception was raised (nil was returned)
  fails "IO#each when passed chomp raises exception when options passed as Hash" # Expected TypeError but no exception was raised (<File:fd 42> was returned)
  fails "IO#each with limit does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised (<File:fd 42> was returned)
  fails "IO#each_codepoint raises an error if reading invalid sequence" # Expected ArgumentError but no exception was raised (65533 was returned)
  fails "IO#each_codepoint raises an exception at incomplete character before EOF when conversion takes place" # Expected ArgumentError but no exception was raised (<File:fd 26> was returned)
  fails "IO#each_line when passed chomp raises exception when options passed as Hash" # Expected TypeError but no exception was raised (<File:fd 35> was returned)
  fails "IO#each_line with limit does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised (<File:fd 35> was returned)
  fails "IO#flush on a pipe raises Errno::EPIPE if sync=false and the read end is closed" # Expected Errno::EPIPE (Broken pipe) but no exception was raised (<IO:fd 36> was returned)
  fails "IO#gets does not accept limit that doesn't fit in a C off_t" # Expected RangeError but no exception was raised ( "one " was returned)
  fails "IO#gets read limit bytes and extra bytes with maximum of 16" # Expected "朝日ã" == "朝日ã\u0081ã\u0081ã\u0081ã\u0081ã\u0081ã\u0081ã\u0081ã\u0081ã" to be truthy but was false
  fails "IO#gets when passed chomp raises exception when options passed as Hash" # Expected TypeError but no exception was raised ("Voici la ligne une." was returned)
  fails "IO#gets with an arbitrary String separator that consists of multiple bytes should match the separator even if the buffer is filled over successive reads" # NotImplementedError: Thread creation not available
  fails "IO#initialize accepts options as keyword arguments" # Expected ArgumentError (wrong number of arguments (given 3, expected 1..2)) but no exception was raised (#IO::Buffer 00 00 00 00 00 00 00 00 INTERNAL  was returned)
  fails "IO#ioctl raises a system call error when ioctl fails" # Expected SystemCallError but got: NotImplementedError (IO.ioctl is not available on nodejs and compatible platforms)
  fails "IO#isatty returns true if this stream is a terminal device (TTY)" # Expected false == true to be truthy but was false
  fails "IO#lineno= does not accept Integers that don't fit in a C int" # Expected RangeError but no exception was raised (4294967296 was returned)
  fails "IO#lineno= raises TypeError if cannot convert argument to Integer implicitly" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "IO#nonblock? returns true for pipe by default" # Expected false == true to be truthy but was false
  fails "IO#nonblock? returns true for socket by default" # NameError: uninitialized constant TCPServer
  fails "IO#pos= does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised (3.402823669209385e+38 was returned)
  fails "IO#pread accepts a length, an offset, and an output buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#puts calls :to_ary before writing non-string objects" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts calls :to_ary before writing non-string objects, regardless of it being implemented in the receiver" # Mock 'hola' expected to receive method_missing("to_ary") exactly 1 times but received it 0 times
  fails "IO#puts calls :to_s before writing non-string objects that don't respond to :to_ary" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts does not write a newline after objects that end in newlines" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts flattens a nested array before writing it" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts ignores the $/ separator global" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts returns general object info if :to_s does not return a string" # TypeError: no implicit conversion of MockObject into String
  fails "IO#puts writes [...] for a recursive array arg" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts writes a newline after objects that do not end in newlines" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts writes each arg if given several" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts writes empty string with a newline when given nil as an arg" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts writes empty string with a newline when when given nil as multiple args" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#puts writes just a newline when given no args" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "IO#read clears the output buffer if there is nothing to read" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read coerces the second argument to string and uses it as a buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read expands the buffer when too small" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read on Windows normalizes line endings in text mode" # Expected  "a\r b\r c" ==  "a b c" to be truthy but was false
  fails "IO#read overwrites the buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read places the specified number of bytes in the buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read raises IOError when stream is closed by another thread" # NotImplementedError: Thread creation not available
  fails "IO#read returns the given buffer when there is nothing to read" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read returns the given buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read truncates the buffer when too big" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding not specified does not change the buffer's encoding when passed a limit" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding not specified truncates the buffer but does not change the buffer's encoding when no data remains" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by encoding: option does not change the buffer's encoding when passed a limit" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by encoding: option truncates the buffer but does not change the buffer's encoding when no data remains" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by encoding: option when passed nil for limit sets the buffer to a transcoded String" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by encoding: option when passed nil for limit sets the buffer's encoding to the internal encoding" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by internal_encoding: option does not change the buffer's encoding when passed a limit" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by internal_encoding: option truncates the buffer but does not change the buffer's encoding when no data remains" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by internal_encoding: option when passed nil for limit sets the buffer to a transcoded String" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by internal_encoding: option when passed nil for limit sets the buffer's encoding to the internal encoding" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by mode: option does not change the buffer's encoding when passed a limit" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by mode: option truncates the buffer but does not change the buffer's encoding when no data remains" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by mode: option when passed nil for limit sets the buffer to a transcoded String" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by mode: option when passed nil for limit sets the buffer's encoding to the internal encoding" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by open mode does not change the buffer's encoding when passed a limit" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by open mode truncates the buffer but does not change the buffer's encoding when no data remains" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by open mode when passed nil for limit sets the buffer to a transcoded String" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read with internal encoding specified by open mode when passed nil for limit sets the buffer's encoding to the internal encoding" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read_nonblock allows for reading 0 bytes after a write" # NoMethodError: undefined method `read_nonblock' for <IO:fd 26>
  fails "IO#read_nonblock allows for reading 0 bytes before any write" # Expected nil == "" to be truthy but was false
  fails "IO#read_nonblock discards the existing buffer content upon error" # Expected EOFError but got: NotImplementedError (out_string buffer is currently not supported)
  fails "IO#read_nonblock discards the existing buffer content upon successful read" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read_nonblock preserves the encoding of the given buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read_nonblock raises ArgumentError when length is less than 0" # Expected ArgumentError but got: NoMethodError (undefined method `read_nonblock' for <IO:fd 26>)
  fails "IO#read_nonblock raises EOFError when the end is reached" # Expected EOFError but no exception was raised (nil was returned)
  fails "IO#read_nonblock raises IOError on closed stream" # Expected IOError but got: NoMethodError (undefined method `read_nonblock' for <File:fd 28 (closed)>)
  fails "IO#read_nonblock raises an exception after ungetc with data in the buffer and character conversion enabled" # NotImplementedError: NotImplementedError
  fails "IO#read_nonblock raises an exception extending IO::WaitReadable when there is no data" # NameError: uninitialized constant IO::WaitReadable
  fails "IO#read_nonblock reads after ungetc with data in the buffer" # NotImplementedError: NotImplementedError
  fails "IO#read_nonblock reads into the passed buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read_nonblock returns at most the number of bytes requested" # NoMethodError: undefined method `read_nonblock' for <IO:fd 26>
  fails "IO#read_nonblock returns less data if that is all that is available" # NoMethodError: undefined method `read_nonblock' for <IO:fd 26>
  fails "IO#read_nonblock returns the passed buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read_nonblock sets the IO in nonblock mode" # Expected <IO:fd 25>.nonblock? to be truthy but was false
  fails "IO#read_nonblock when exception option is set to false when the end is reached returns nil" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#read_nonblock when exception option is set to false when there is no data returns :wait_readable" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#readline when passed chomp raises exception when options passed as Hash" # Expected TypeError but no exception was raised ("Voici la ligne une." was returned)
  fails "IO#readline when passed limit does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised ( "Voici la ligne une. " was returned)
  fails "IO#readlines when passed chomp raises exception when options passed as Hash" # Expected TypeError but no exception was raised (["Voici la ligne une.",  "Qui è la linea due.",  "",  "",  "Aquí está la línea tres.",  "Hier ist Zeile vier.",  "",  "Está aqui a linha cinco.",  "Here is line six."] was returned)
  fails "IO#readlines when passed limit does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised (["Voici la ligne une.\n",  "Qui è la linea due.\n",  "\n",  "\n",  "Aquí está la línea tres.\n",  "Hier ist Zeile vier.\n",  "\n",  "Está aqui a linha cinco.\n",  "Here is line six.\n"] was returned)
  fails "IO#readpartial clears and returns the given buffer if the length argument is 0" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#readpartial discards the existing buffer content upon error" # Expected EOFError but got: NotImplementedError (out_string buffer is currently not supported)
  fails "IO#readpartial discards the existing buffer content upon successful read" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#readpartial preserves the encoding of the given buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#readpartial reads after ungetc with data in the buffer" # NotImplementedError: NotImplementedError
  fails "IO#readpartial reads after ungetc with multibyte characters in the buffer" # NotImplementedError: NotImplementedError
  fails "IO#readpartial reads after ungetc without data in the buffer" # NotImplementedError: NotImplementedError
  fails "IO#reopen with a String affects exec/system/fork performed after it" # NotImplementedError: NotImplementedError
  fails "IO#reopen with an IO does not call #to_io" # Expected <File:fd 21> (File) to be an instance of IO
  fails "IO#seek does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised (0 was returned)
  fails "IO#set_encoding raises ArgumentError when too many arguments are given" # Expected ArgumentError but got: TypeError (no implicit conversion of Number into String)
  fails "IO#set_encoding saves encoding options passed as a hash in the last argument" # Expected "\uFFFD" == "." to be truthy but was false
  fails "IO#set_encoding when passed nil, nil with standard IOs correctly resets them" # Expected #<Encoding:ASCII-8BIT> == nil to be truthy but was false
  fails "IO#set_encoding_by_bom returns UTF-16LE if UTF-32LE BOM sequence is incomplete" # Expected "\uFFFD" == "\x00" to be truthy but was false
  fails "IO#set_encoding_by_bom returns exception if encoding already set" # Expected ArgumentError (encoding is set to UTF-8 already) but no exception was raised (nil was returned)
  fails "IO#set_encoding_by_bom returns the result encoding if found BOM UTF_16BE sequence" # Expected "慢\uFFFD" == "abc" to be truthy but was false
  fails "IO#set_encoding_by_bom returns the result encoding if found BOM UTF_16LE sequence" # Expected "扡\uFFFD" == "abc" to be truthy but was false
  fails "IO#set_encoding_by_bom returns the result encoding if found BOM UTF_32BE sequence" # Expected "\uFFFD" == "abc" to be truthy but was false
  fails "IO#set_encoding_by_bom returns the result encoding if found BOM UTF_32LE sequence" # Expected "扡" == "abc" to be truthy but was false
  fails "IO#sysread on a file coerces the second argument to string and uses it as a buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#sysread on a file discards the existing buffer content upon error" # Expected EOFError but got: NotImplementedError (out_string buffer is currently not supported)
  fails "IO#sysread on a file discards the existing buffer content upon successful read" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#sysread on a file immediately returns the given buffer if the length argument is 0" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#sysread on a file raises an error when called after buffered reads" # Expected IOError but no exception was raised ("abcde" was returned)
  fails "IO#sysread on a file reads the specified number of bytes from the file to the buffer" # NotImplementedError: out_string buffer is currently not supported
  fails "IO#sysseek does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised (3.402823669209385e+38 was returned)
  fails "IO#sysseek raises an error when called after buffered reads" # Expected IOError but no exception was raised (15 was returned)
  fails "IO#syswrite on a file warns if called immediately after a buffered IO#write" # Expected warning to match: /syswrite/ but got: ""
  fails "IO#syswrite on a pipe raises Errno::EPIPE if the read end is closed and does not die from SIGPIPE" # Expected Errno::EPIPE (Broken pipe) but no exception was raised (3 was returned)
  fails "IO#syswrite on a pipe returns the written bytes if the fd is in nonblock mode and write would block" # Expected 2097152 < 2097152 to be truthy but was false
  fails "IO#tty? returns true if this stream is a terminal device (TTY)" # Expected false == true to be truthy but was false
  fails "IO#ungetbyte calls #to_str to convert the argument" # Mock 'io ungetbyte' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "IO#ungetbyte does nothing when passed nil" # NotImplementedError: NotImplementedError
  fails "IO#ungetbyte never raises RangeError" # NotImplementedError: NotImplementedError
  fails "IO#ungetbyte puts back each byte in a String argument" # NotImplementedError: NotImplementedError
  fails "IO#ungetbyte raises IOError on stream not opened for reading" # Expected IOError (not opened for reading) but got: NotImplementedError (NotImplementedError)
  fails "IO#ungetbyte raises an IOError if the IO is closed" # Expected IOError but got: NotImplementedError (NotImplementedError)
  fails "IO#ungetc adjusts the stream position" # NotImplementedError: NotImplementedError
  fails "IO#ungetc affects EOF state" # NotImplementedError: NotImplementedError
  fails "IO#ungetc calls #to_str to convert the argument if it is not an Integer" # Mock 'io ungetc' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "IO#ungetc interprets the codepoint in the external encoding" # NotImplementedError: NotImplementedError
  fails "IO#ungetc makes subsequent unbuffered operations to raise IOError" # NotImplementedError: NotImplementedError
  fails "IO#ungetc pushes back one character onto stream" # NotImplementedError: NotImplementedError
  fails "IO#ungetc pushes back one character when invoked at the end of the stream" # NotImplementedError: NotImplementedError
  fails "IO#ungetc pushes back one character when invoked at the start of the stream" # NotImplementedError: NotImplementedError
  fails "IO#ungetc pushes back one character when invoked on empty stream" # NotImplementedError: NotImplementedError
  fails "IO#ungetc puts one or more characters back in the stream" # NotImplementedError: NotImplementedError
  fails "IO#ungetc raises IOError on closed stream" # Expected IOError but got: NotImplementedError (NotImplementedError)
  fails "IO#ungetc raises IOError on stream not opened for reading" # Expected IOError (not opened for reading) but got: NotImplementedError (NotImplementedError)
  fails "IO#ungetc raises TypeError if passed nil" # Expected TypeError but got: NotImplementedError (NotImplementedError)
  fails "IO#ungetc returns nil when invoked on stream that was not yet read" # NotImplementedError: NotImplementedError
  fails "IO#write on STDOUT raises SignalException SIGPIPE if the stream is closed instead of Errno::EPIPE like other IOs" # Expected nil ==  "ok " to be truthy but was false
  fails "IO#write on Windows normalizes line endings in text mode" # Expected  "a b c" ==  "a\r b\r c" to be truthy but was false
  fails "IO#write on a file does not modify the passed argument" # Expected [146, 1] == [159] to be truthy but was false
  fails "IO#write on a file raises a invalid byte sequence error if invalid bytes are being written" # Expected Encoding::InvalidByteSequenceError but no exception was raised (3 was returned)
  fails "IO#write on a pipe raises Errno::EPIPE if the read end is closed and does not die from SIGPIPE" # Expected Errno::EPIPE (Broken pipe) but no exception was raised (3 was returned)
  fails "IO#write transcodes the given string when the external encoding is set and the string encoding is BINARY" # Expected Encoding::UndefinedConversionError but no exception was raised (6 was returned)
  fails "IO#write_nonblock advances the file position by the count of given bytes" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock checks if the file is writable if writing more than zero bytes" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock coerces the argument to a string using to_s" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock does not transcode the given string even when the external encoding is set" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock does not warn if called after IO#read" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock invokes to_s on non-String argument" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock on a file checks if the file is writable if writing zero bytes" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock on a file does not modify the passed argument" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock on a file writes all of the string's bytes but does not buffer them" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock on a pipe raises Errno::EPIPE if the read end is closed and does not die from SIGPIPE" # NoMethodError: undefined method `close' for nil
  fails "IO#write_nonblock on a pipe writes the given String to the pipe" # NoMethodError: undefined method `close' for nil
  fails "IO#write_nonblock raises IOError on closed stream" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock raises an exception extending IO::WaitWritable when the write would block" # NameError: uninitialized constant IO::WaitWritable
  fails "IO#write_nonblock returns the number of bytes written" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock sets the IO in nonblock mode" # Expected <IO:fd 30>.nonblock? to be truthy but was false
  fails "IO#write_nonblock when exception option is set to false returns :wait_writable when the operation would block" # ArgumentError: [IO#write_nonblock] wrong number of arguments (given 2, expected 1)
  fails "IO#write_nonblock writes all of the string's bytes without buffering if mode is sync" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO#write_nonblock writes to the current position after IO#read" # NoMethodError: undefined method `write_nonblock' for <File:fd 28>
  fails "IO.binwrite accepts options as a keyword argument" # Expected ArgumentError (wrong number of arguments (given 4, expected 2..3)) but no exception was raised (2 was returned)
  fails "IO.copy_stream does not use buffering when writing to STDOUT" # Expected nil == "bar" to be truthy but was false
  fails "IO.copy_stream from a file name calls #to_path to convert on object to a file name" # Mock 'io_copy_stream_from' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "IO.copy_stream from a file name raises a TypeError if #to_path does not return a String" # Expected TypeError but got: NoMethodError (undefined method `close' for #<MockObject:0x2298 @name="io_copy_stream_from" @null=nil>)
  fails "IO.copy_stream from a file name to a file name calls #to_path to convert on object to a file name" # Mock 'io_copy_stream_to' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "IO.copy_stream from a file name to a file name copies only length bytes from the offset" # Expected 0 == 8 to be truthy but was false
  fails "IO.copy_stream from a file name to a file name copies only length bytes when specified" # Expected 0 == 8 to be truthy but was false
  fails "IO.copy_stream from a file name to a file name copies the entire IO contents to the file" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\tmp\rubyspec_temp\io_copy_stream_io_name'
  fails "IO.copy_stream from a file name to a file name raises a TypeError if #to_path does not return a String" # Expected TypeError but got: NoMethodError (undefined method `close' for #<MockObject:0x235e @name="io_copy_stream_to" @null=nil>)
  fails "IO.copy_stream from a file name to a file name returns the number of bytes copied" # Expected 0 == 17000 to be truthy but was false
  fails "IO.copy_stream from a file name to an IO copies only length bytes from the offset" # Expected 0 == 8 to be truthy but was false
  fails "IO.copy_stream from a file name to an IO copies only length bytes when specified" # Expected 0 == 8 to be truthy but was false
  fails "IO.copy_stream from a file name to an IO copies the entire IO contents to the IO" # IOError: not opened for writing
  fails "IO.copy_stream from a file name to an IO does not close the destination IO" # Expected true to be false
  fails "IO.copy_stream from a file name to an IO leaves the destination IO position at the last write" # IOError: closed stream
  fails "IO.copy_stream from a file name to an IO raises an IOError if the destination IO is not open for writing" # Expected IOError but no exception was raised (0 was returned)
  fails "IO.copy_stream from a file name to an IO returns the number of bytes copied" # IOError: not opened for writing
  fails "IO.copy_stream from a file name to an IO starts writing at the destination IO's current position" # Expected "" ==  "prelude Line one  Line three Line four  Line last " to be truthy but was false
  fails "IO.copy_stream from a pipe IO does not close the source IO" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<IO:0x288c>'
  fails "IO.copy_stream from a pipe IO raises an error when an offset is specified" # Expected Errno::ESPIPE but no exception was raised (0 was returned)
  fails "IO.copy_stream from a pipe IO to a file name calls #to_path to convert on object to a file name" # Mock 'io_copy_stream_to' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "IO.copy_stream from a pipe IO to a file name copies only length bytes when specified" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<IO:0x2950>'
  fails "IO.copy_stream from a pipe IO to a file name copies the entire IO contents to the file" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<IO:0x29ae>'
  fails "IO.copy_stream from a pipe IO to a file name raises a TypeError if #to_path does not return a String" # Expected TypeError but got: NoMethodError (undefined method `close' for #<MockObject:0x28ee @name="io_copy_stream_to" @null=nil>)
  fails "IO.copy_stream from a pipe IO to a file name returns the number of bytes copied" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<IO:0x2a0c>'
  fails "IO.copy_stream from a pipe IO to an IO copies only length bytes when specified" # Expected 0 == 8 to be truthy but was false
  fails "IO.copy_stream from a pipe IO to an IO copies the entire IO contents to the IO" # IOError: not opened for writing
  fails "IO.copy_stream from a pipe IO to an IO does not close the destination IO" # Expected true to be false
  fails "IO.copy_stream from a pipe IO to an IO leaves the destination IO position at the last write" # IOError: closed stream
  fails "IO.copy_stream from a pipe IO to an IO raises an IOError if the destination IO is not open for writing" # Expected IOError but no exception was raised (0 was returned)
  fails "IO.copy_stream from a pipe IO to an IO returns the number of bytes copied" # IOError: not opened for writing
  fails "IO.copy_stream from an IO does change the IO offset when an offset is not specified" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<File:0x1d12>'
  fails "IO.copy_stream from an IO does not change the IO offset when an offset is specified" # IOError: closed stream
  fails "IO.copy_stream from an IO does not close the source IO" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<File:0x1d70>'
  fails "IO.copy_stream from an IO raises an IOError if the source IO is not open for reading" # Expected IOError but got: Errno::ENOENT (No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<File:0x1dd0>')
  fails "IO.copy_stream from an IO to a file name calls #to_path to convert on object to a file name" # Mock 'io_copy_stream_to' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "IO.copy_stream from an IO to a file name copies only length bytes from the offset" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open '/home/jan/workspace/opal/tmp/rubyspec_temp/io_copy_stream_io_name'
  fails "IO.copy_stream from an IO to a file name copies only length bytes when specified" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<File:0x1ef6>'
  fails "IO.copy_stream from an IO to a file name copies the entire IO contents to the file" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<File:0x1fb6>'
  fails "IO.copy_stream from an IO to a file name raises a TypeError if #to_path does not return a String" # Expected TypeError but got: NoMethodError (undefined method `close' for #<MockObject:0x1e34 @name="io_copy_stream_to" @null=nil>)
  fails "IO.copy_stream from an IO to a file name returns the number of bytes copied" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<File:0x1e9a>'
  fails "IO.copy_stream from an IO to an IO copies only length bytes from the offset" # Expected 0 == 8 to be truthy but was false
  fails "IO.copy_stream from an IO to an IO copies only length bytes when specified" # Expected 0 == 8 to be truthy but was false
  fails "IO.copy_stream from an IO to an IO copies the entire IO contents to the IO" # IOError: not opened for writing
  fails "IO.copy_stream from an IO to an IO does not close the destination IO" # Expected true to be false
  fails "IO.copy_stream from an IO to an IO leaves the destination IO position at the last write" # IOError: closed stream
  fails "IO.copy_stream from an IO to an IO raises an IOError if the destination IO is not open for writing" # Expected IOError but no exception was raised (0 was returned)
  fails "IO.copy_stream from an IO to an IO returns the number of bytes copied" # IOError: not opened for writing
  fails "IO.copy_stream with a destination that does partial reads calls #write repeatedly on the destination Object" # NotImplementedError: Thread creation not available
  fails "IO.copy_stream with non-IO Objects calls #read on the source Object" # NoMethodError: undefined method `close' for #<IOSpecs::CopyStreamRead:0x2dee @io=<File:fd 26>>
  fails "IO.copy_stream with non-IO Objects calls #readpartial on the source Object if defined" # NoMethodError: undefined method `close' for #<IOSpecs::CopyStreamReadPartial:0x2eb0 @io=<File:fd 26>>
  fails "IO.copy_stream with non-IO Objects calls #write on the destination Object" # NoMethodError: undefined method `close' for #<MockObject:0x2e4a @name="io_copy_stream_to_object" @null=nil>
  fails "IO.copy_stream with non-IO Objects does not call #pos on the source if no offset is given" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\#<File:0x2d8c>'
  fails "IO.for_fd accepts options as keyword arguments" # Expected ArgumentError (wrong number of arguments (given 3, expected 1..2)) but no exception was raised (<IO:fd 35> was returned)
  fails "IO.for_fd ignores the :encoding option when the :external_encoding option is present" # Expected warning to match: /Ignoring encoding parameter/ but got: ""
  fails "IO.for_fd ignores the :encoding option when the :internal_encoding option is present" # Expected warning to match: /Ignoring encoding parameter/ but got: ""
  fails "IO.for_fd raises an Errno::EINVAL if the new mode is not compatible with the descriptor's current mode" # Expected Errno::EINVAL but no exception was raised (<IO:fd 25> was returned)
  fails "IO.foreach when passed name, object when the object is an Integer does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised (nil was returned)
  fails "IO.foreach when passed name, object when the object is an options Hash raises TypeError exception" # Expected TypeError but no exception was raised (nil was returned)
  fails "IO.foreach when passed name, object, object when the second object is an options Hash raises TypeError exception" # Expected TypeError but no exception was raised (nil was returned)
  fails "IO.foreach when the filename starts with | gets data from a fork when passed -" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open '|-'
  fails "IO.foreach when the filename starts with | gets data from the standard out of the subprocess" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\|cmd.exe \C echo hello&echo line2'
  fails "IO.new accepts options as keyword arguments" # Expected ArgumentError (wrong number of arguments (given 3, expected 1..2)) but no exception was raised (<IO:fd 35> was returned)
  fails "IO.new ignores the :encoding option when the :external_encoding option is present" # Expected warning to match: /Ignoring encoding parameter/ but got: ""
  fails "IO.new ignores the :encoding option when the :internal_encoding option is present" # Expected warning to match: /Ignoring encoding parameter/ but got: ""
  fails "IO.new raises an Errno::EINVAL if the new mode is not compatible with the descriptor's current mode" # Expected Errno::EINVAL but no exception was raised (<IO:fd 25> was returned)
  fails "IO.open accepts options as keyword arguments" # Expected ArgumentError (wrong number of arguments (given 3, expected 1..2)) but no exception was raised (<IO:fd 35> was returned)
  fails "IO.open ignores the :encoding option when the :external_encoding option is present" # Expected warning to match: /Ignoring encoding parameter/ but got: ""
  fails "IO.open ignores the :encoding option when the :internal_encoding option is present" # Expected warning to match: /Ignoring encoding parameter/ but got: ""
  fails "IO.open raises an Errno::EINVAL if the new mode is not compatible with the descriptor's current mode" # Expected Errno::EINVAL but no exception was raised (<IO:fd 2> was returned)
  fails "IO.popen does not throw an exception if child exited and has been waited for" # NoMethodError: undefined method `exited?' for #<Process::Status: pid 10824 exit 0>
  fails "IO.popen raises IOError when writing a read-only pipe" # Expected "" ==  "foo " to be truthy but was false
  fails "IO.popen reads a read-only pipe" # Expected "" ==  "foo " to be truthy but was false
  fails "IO.popen reads and writes a read/write pipe" # Expected nil == "bar" to be truthy but was false
  fails "IO.popen sees an infinitely looping subprocess exit when read pipe is closed" # NoMethodError: undefined method `exitstatus' for nil
  fails "IO.popen starts returns a forked process if the command is -" # Expected nil ==  "hello from child " to be truthy but was false
  fails "IO.popen waits for the child to finish" # NoMethodError: undefined method `exitstatus' for nil
  fails "IO.popen with a leading Array argument accepts '[env, command, arg1, arg2, ..., exec options], mode'" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading Array argument accepts '[env, command, arg1, arg2, ..., exec options], mode, IO options'" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading Array argument accepts '[env, command, arg1, arg2, ...], mode, IO + exec options'" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading Array argument accepts [env, command, arg1, arg2, ..., exec options]" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading Array argument accepts a leading ENV Hash" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading Array argument accepts a trailing Hash of Process.exec options" # Expected "" =~ /LoadError/ to be truthy but was nil
  fails "IO.popen with a leading Array argument accepts an IO mode argument following the Array" # Expected "" =~ /LoadError/ to be truthy but was nil
  fails "IO.popen with a leading Array argument uses the Array as command plus args for the child process" # Expected "" ==  "hello " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts a single String command with a trailing Hash of Process.exec options" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts a single String command with a trailing Hash of Process.exec options, and an IO mode" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts a single String command" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts a single String command, and an IO mode" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts an Array command with a separate trailing Hash of Process.exec options" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts an Array command with a separate trailing Hash of Process.exec options, and an IO mode" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts an Array of command and arguments" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts an Array of command and arguments, and an IO mode" # Expected "" ==  "bar " to be truthy but was false
  fails "IO.popen writes to a write-only pipe" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\tmp\rubyspec_temp\IO_popen_spec'
  fails "IO.read accepts options as keyword arguments" # Expected ArgumentError (wrong number of arguments) but no exception was raised ("123" was returned)
  fails "IO.read from a pipe opens a pipe to a fork if the rest is -" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open '|-'
  fails "IO.read from a pipe raises Errno::ESPIPE if passed an offset" # Expected Errno::ESPIPE but got: Errno::ENOENT (No such file or directory - ENOENT: no such file or directory, open '|sh -c 'echo hello'')
  fails "IO.read from a pipe reads only the specified number of bytes requested" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\|cmd.exe \C echo hello'
  fails "IO.read from a pipe runs the rest as a subprocess and returns the standard output" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\|cmd.exe \C echo hello'
  fails "IO.read reads the file in text mode" # Expected "\u001Abbb".empty? to be truthy but was false
  fails "IO.read with BOM reads a file with a utf-16be bom" # Expected  "UTF-16BE " ==  "\u0000U\u0000T\u0000F\u0000-\u00001\u00006\u0000B\u0000E\u0000 " to be truthy but was false
  fails "IO.read with BOM reads a file with a utf-16le bom" # Expected  "UTF-16LE " ==  "U\u0000T\u0000F\u0000-\u00001\u00006\u0000L\u0000E\u0000 \u0000" to be truthy but was false
  fails "IO.read with BOM reads a file with a utf-32be bom" # Expected "\uFFFE唀吀䘀ⴀ㌀㈀䈀䔀਀" ==  "\u0000\u0000\u0000U\u0000\u0000\u0000T\u0000\u0000\u0000F\u0000\u0000\u0000-\u0000\u0000\u00003\u0000\u0000\u00002\u0000\u0000\u0000B\u0000\u0000\u0000E\u0000\u0000\u0000 " to be truthy but was false
  fails "IO.read with BOM reads a file with a utf-32le bom" # Expected  "UTF-32LE " ==  "U\u0000\u0000\u0000T\u0000\u0000\u0000F\u0000\u0000\u0000-\u0000\u0000\u00003\u0000\u0000\u00002\u0000\u0000\u0000L\u0000\u0000\u0000E\u0000\u0000\u0000 \u0000\u0000\u0000" to be truthy but was false
  fails "IO.readlines when passed a string that starts with a | gets data from a fork when passed -" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open '|-'
  fails "IO.readlines when passed a string that starts with a | gets data from the standard out of the subprocess" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open 'C:\Users\jan\workspace\opal\spec\|cmd.exe \C echo hello&echo line2'
  fails "IO.readlines when passed name, object when the object is an Integer does not accept Integers that don't fit in a C off_t" # Expected RangeError but no exception was raised (["Voici la ligne une.\n",  "Qui è la linea due.\n",  "\n",  "\n",  "Aquí está la línea tres.\n",  "Hier ist Zeile vier.\n",  "\n",  "Está aqui a linha cinco.\n",  "Here is line six.\n"] was returned)
  fails "IO.readlines when passed name, object when the object is an options Hash raises TypeError exception" # Expected TypeError but no exception was raised (["Voici la ligne une.",  "Qui è la linea due.",  "",  "",  "Aquí está la línea tres.",  "Hier ist Zeile vier.",  "",  "Está aqui a linha cinco.",  "Here is line six."] was returned)
  fails "IO.readlines when passed name, object, object when the second object is an options Hash raises TypeError exception" # Expected TypeError but no exception was raised (["Voici la ligne une.\n" + "Qui è la linea due.",  "Aquí está la línea tres.\n" + "Hier ist Zeile vier.",  "Está aqui a linha cinco.\n" + "Here is line six.\n"] was returned)
  fails "IO.select blocks for duration of timeout and returns nil if there are no objects ready for I/O" # NotImplementedError: NotImplementedError
  fails "IO.select invokes to_io on supplied objects that are not IO and returns the supplied objects" # Mock 'read_io' expected to receive to_io("any_args") at least 1 times but received it 0 times
  fails "IO.select leaves out IO objects for which there is no I/O ready" # NotImplementedError: NotImplementedError
  fails "IO.select raises TypeError if supplied objects are not IO" # Expected TypeError but got: NotImplementedError (NotImplementedError)
  fails "IO.select raises TypeError if the first three arguments are not Arrays" # Expected TypeError but got: NotImplementedError (NotImplementedError)
  fails "IO.select raises a TypeError if the specified timeout value is not Numeric" # Expected TypeError but got: NotImplementedError (NotImplementedError)
  fails "IO.select raises an ArgumentError when passed a negative timeout" # Expected ArgumentError but got: NotImplementedError (NotImplementedError)
  fails "IO.select returns immediately all objects that are ready for I/O when timeout is 0" # NotImplementedError: NotImplementedError
  fails "IO.select returns nil after timeout if there are no objects ready for I/O" # NotImplementedError: NotImplementedError
  fails "IO.select returns supplied objects correctly when monitoring the same object in different arrays" # NotImplementedError: NotImplementedError
  fails "IO.select returns supplied objects when they are ready for I/O" # NotImplementedError: Thread creation not available
  fails "IO.select returns the pipe read end in read set if the pipe write end is closed concurrently" # NoMethodError: undefined method `join' for nil
  fails "IO.select when passed nil for timeout sleeps forever and sets the thread status to 'sleep'" # NotImplementedError: Thread creation not available
  fails "IO.try_convert raises a TypeError if the object does not return an IO from #to_io" # Expected TypeError (can't convert MockObject to IO (MockObject#to_io gives String)) but got: TypeError (can't convert MockObject into IO (MockObject#to_io gives String))
  fails "IO.try_convert return nil when BasicObject is passed" # NoMethodError: undefined method `is_a?' for #<BasicObject:0xe88e>
  fails "IO.write accepts options as a keyword argument" # Expected ArgumentError (wrong number of arguments (given 4, expected 2..3)) but no exception was raised (2 was returned)
  fails "IO::EAGAINWaitReadable combines Errno::EAGAIN and IO::WaitReadable" # NameError: uninitialized constant IO::EAGAINWaitReadable
  fails "IO::EAGAINWaitReadable is the same as IO::EWOULDBLOCKWaitReadable if Errno::EAGAIN is the same as Errno::EWOULDBLOCK" # NameError: uninitialized constant Errno::EAGAIN
  fails "IO::EAGAINWaitWritable combines Errno::EAGAIN and IO::WaitWritable" # NameError: uninitialized constant IO::EAGAINWaitWritable
  fails "IO::EAGAINWaitWritable is the same as IO::EWOULDBLOCKWaitWritable if Errno::EAGAIN is the same as Errno::EWOULDBLOCK" # NameError: uninitialized constant Errno::EAGAIN
  fails "IO::EWOULDBLOCKWaitReadable combines Errno::EWOULDBLOCK and IO::WaitReadable" # NameError: uninitialized constant IO::EWOULDBLOCKWaitReadable
  fails "IO::EWOULDBLOCKWaitWritable combines Errno::EWOULDBLOCK and IO::WaitWritable" # NameError: uninitialized constant IO::EWOULDBLOCKWaitWritable
end
