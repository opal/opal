# NOTE: run bin/format-filters after changing this file
opal_filter "Marshal" do
  fails "Marshal.dump ignores the recursion limit if the limit is negative" # no support yet
  fails "Marshal.dump raises a TypeError if dumping a Mutex instance" # Expected TypeError but no exception was raised ("\u0004\bo:\nMutex\u0006:\f@lockedF" was returned)
  fails "Marshal.dump when passed a StringIO should raise an error" # Expected TypeError but no exception was raised ("\u0004\bo:\rStringIO\a:\f@string\"\u0000:\u000E@positioni\u0000" was returned)
  fails "Marshal.dump with a Range dumps a Range with extra instance variables" # Expected nil to equal 42
  fails "Marshal.dump with a Regexp dumps a Regexp subclass" # requires Class.new(Regexp).new("").class != Regexp
  fails "Marshal.dump with a Regexp dumps a Regexp with instance variables" # //.source.should == ''
  fails "Marshal.dump with a Time dumps the zone and the offset"
  fails "Marshal.dump with a Time dumps the zone, but not the offset if zone is UTC" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Marshal.dump with an Exception contains the filename in the backtrace"
  fails "Marshal.dump with an Exception dumps an empty Exception"
  fails "Marshal.dump with an Exception dumps instance variables if they exist" # Expected  "\u0004\bo:\u000EException\a: @name\"\u000EException: @ivari\u0006" ==  "\u0004\bo:\u000EException\b:\tmesg\"\bfoo:\abt0: @ivari\u0006" to be truthy but was false
  fails "Marshal.dump with an Exception dumps the cause for the exception" # NoMethodError: undefined method `cause' for #<RuntimeError: the consequence>
  fails "Marshal.dump with an Exception dumps the message for the exception"
  fails "Marshal.dump with an Object dumps a BasicObject subclass if it defines respond_to?"
  fails "Marshal.dump with an Object dumps an Object with a non-US-ASCII instance variable" # NameError: '@Ã©' is not allowed as an instance variable name
  fails "Marshal.dump with an Object raises if an Object has a singleton class and singleton methods" # Expected TypeError (singleton can't be dumped) but no exception was raised ("\u0004\bo:\vObject\u0000" was returned)
  fails "Marshal.dump with an object responding to #_dump dumps the object returned by #marshal_dump"
  fails "Marshal.load for a Module loads an old module"
  fails "Marshal.load for a Regexp loads a extended_user_regexp having ivar"
  fails "Marshal.load for a Regexp loads an extended Regexp" # Expected /[a-z]/ == /(?:)/ to be truthy but was false
  fails "Marshal.load for a String loads a String as BINARY if no encoding is specified at the end" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Marshal.load for a String loads a String subclass with custom constructor"
  fails "Marshal.load for a Struct does not call initialize on the unmarshaled struct"
  fails "Marshal.load for a Symbol loads a Symbol" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Marshal.load for a Symbol loads a binary encoded Symbol" # Expected "â\u0086\u0092" to equal "→"
  fails "Marshal.load for a Symbol loads an encoded Symbol" # Expected "â\u0086\u0092" to equal "→"
  fails "Marshal.load for a Time loads nanoseconds"
  fails "Marshal.load for a Time loads the zone"
  fails "Marshal.load for a Time loads"
  fails "Marshal.load for a user Class raises ArgumentError if the object from an 'o' stream is not dumpable as 'o' type user class"
  fails "Marshal.load for a user Class that extends a core type other than Object or BasicObject raises ArgumentError if the resulting class does not extend the same type"
  fails "Marshal.load for a user object that extends a core type other than Object or BasicObject raises ArgumentError if the resulting class does not extend the same type" # TypeError: no implicit conversion of Hash into Integer
  fails "Marshal.load for an Exception loads a marshalled exception with a backtrace"
  fails "Marshal.load for an Exception loads a marshalled exception with a message"
  fails "Marshal.load for an Exception loads a marshalled exception with no message"
  fails "Marshal.load for an Exception loads an marshalled exception with ivars" # Expected "Exception" == "foo" to be truthy but was false
  fails "Marshal.load for an Integer loads an Integer -2361183241434822606847" # Expected -2 == -2.3611832414348226e+21 to be truthy but was false
  fails "Marshal.load for an Integer loads an Integer 2361183241434822606847" # Expected 2 == 2.3611832414348226e+21 to be truthy but was false
  fails "Marshal.load for an Object loads an Object with a non-US-ASCII instance variable" # NameError: '@Ã©' is not allowed as an instance variable name
  fails "Marshal.load for an Object raises ArgumentError if the object from an 'o' stream is not dumpable as 'o' type user class" # Expected ArgumentError but no exception was raised (#<File:0x3b160> was returned)
  fails "Marshal.load loads a Integer 2**90" # Expected 1 == 1.2379400392853803e+27 to be truthy but was false
  fails "Marshal.load loads a Regexp" # anchors difference
  fails "Marshal.load loads an array containing objects having _dump method, and with proc"
  fails "Marshal.load loads an array containing objects having marshal_dump method, and with proc"
  fails "Marshal.load when a class does not exist in the namespace raises an ArgumentError" # an issue with constant resolving, e.g. String::Array
  fails "Marshal.load when called with a proc calls the proc for recursively visited data"
  fails "Marshal.load when called with a proc loads an Array with proc"
  fails "Marshal.load when called with a proc returns the value of the proc"
  fails "Marshal.load when called with nil for the proc argument behaves as if no proc argument was passed" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
end
