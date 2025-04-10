# NOTE: run bin/format-filters after changing this file
opal_filter "Misc" do
  fails "A method assigns local variables from method parameters for definition \n    def m(a, b = nil, c = nil, d, e: nil, **f)\n          [a, b, c, d, e, f]\n        end" # Expected [1, nil, nil, 2, nil, {"foo"=>"bar"}]  == [1, 2, nil, {"foo"=>"bar"}, nil, {}]  to be truthy but was false
  fails "Date#strftime should be able to show the number of seconds since the unix epoch for a date" # Expected "954972000"  == "954979200"  to be truthy but was false
  fails "DateTime.now grabs the local timezone" # Expected "+02:00"  == "-08:00"  to be truthy but was false
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format parses YYYY-MM-DDTHH:MM:SS into a DateTime object" # Expected #<DateTime:0xa0e0e @date=2012-11-08 15:43:59 +0100, @start=2299161>  == #<DateTime:0xa0e12 @date=2012-11-08 15:43:59 UTC, @start=2299161>  to be truthy but was false
  fails "Enumerator.new when passed a block defines iteration with block, yielder argument and treating it as a proc" # Expected ["a\nb\nc"]  == ["a\n", "b\n", "c"]  to be truthy but was false
  fails "Etc.getgrnam returns a Etc::Group struct instance for the given group" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "Etc.group returns a Etc::Group struct" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "Etc.passwd returns a Etc::Passwd struct" # NotImplementedError: IO for fd > 2 is not available on this platform
  fails "Exception#backtrace contains lines of the same format for each prior position in the stack" # NotImplementedError: File.lstat is not available on this platform
  fails "Exception#backtrace returns an Array that can be updated" # NotImplementedError: File.lstat is not available on this platform
  fails "Exception#backtrace returns an Array" # NotImplementedError: File.lstat is not available on this platform
  fails "Exception#backtrace returns the same array after duping" # NotImplementedError: File.lstat is not available on this platform
  fails "Exception#backtrace sets each element to a String" # NotImplementedError: File.lstat is not available on this platform
  fails "Exception#backtrace_locations returns an Array that can be updated" # NotImplementedError: File.lstat is not available on this platform
  fails "Exception#backtrace_locations returns an Array" # NotImplementedError: File.lstat is not available on this platform
  fails "Exception#backtrace_locations sets each element to a Thread::Backtrace::Location" # NotImplementedError: File.lstat is not available on this platform
  fails "Exception#cause is not set to the exception itself when it is re-raised" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Marshal.load assigns classes to nested subclasses of Array correctly" # NameError: uninitialized constant ArraySub
  fails "Marshal.load loads subclasses of Array with overridden << and push correctly" # NameError: uninitialized constant ArraySubPush
  fails "Module#attr creates a getter and setter for the given attribute name if called with and without writable is true" # NotImplementedError: IO#fsync is not available on this platform
  fails "Module#attr creates a setter for the given attribute name if writable is true" # NotImplementedError: IO#fsync is not available on this platform
  fails "Operators ? : has higher precedence than rescue" # NotImplementedError: File.lstat is not available on this platform
  fails "Operators or/and have higher precedence than if unless while until modifiers" # NotImplementedError: File.lstat is not available on this platform
  fails "Operators rescue has higher precedence than =" # NotImplementedError: File.lstat is not available on this platform
  fails "Predefined global $! in bodies without ensure should be cleared when an exception is rescued even when a non-local return from block" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! in bodies without ensure should be cleared when an exception is rescued even when a non-local return is present" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! in bodies without ensure should be cleared when an exception is rescued" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! in bodies without ensure should not be cleared when an exception is not rescued" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! in bodies without ensure should not be cleared when an exception is rescued and rethrown" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! in ensure-protected bodies should be cleared when an exception is rescued" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! remains nil after a failed core class \"checked\" coercion against a class that defines method_missing" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! should be set to the new exception after a throwing rescue" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! should be set to the value of $! before the begin after a successful rescue within an ensure" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $! should be set to the value of $! before the begin after a successful rescue" # Expected #<NotImplementedError: File.lstat is not available on this platform>  == nil  to be truthy but was false
  fails "Predefined global $_ is set to the last line read by e.g. StringIO#gets" # Expected  "foo bar " ==  "foo " to be truthy but was false
end
