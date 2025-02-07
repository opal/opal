# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File.absolute_path accepts a second argument of a directory from which to resolve the path" # Expected "./ruby/core/file/ruby/core/file/absolute_path_spec.rb" == "ruby/core/file/absolute_path_spec.rb" to be truthy but was false
  fails "File.absolute_path does not expand '~user' to a home directory." # Expected "./ruby/core/file/~user" == "ruby/core/file/~user" to be truthy but was false
  fails "File.absolute_path resolves paths relative to the current working directory" # Expected "./ruby/core/file/hello.txt" == "ruby/core/file/hello.txt" to be truthy but was false
  fails "File.absolute_path? calls #to_path on its argument" # Mock 'path' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "File.absolute_path? does not expand '~' to a home directory." # NoMethodError: undefined method `absolute_path?' for File
  fails "File.absolute_path? does not expand '~user' to a home directory." # NoMethodError: undefined method `absolute_path?' for File
  fails "File.absolute_path? returns false if it's a relative path" # NoMethodError: undefined method `absolute_path?' for File
  fails "File.absolute_path? returns false if it's a tricky relative path" # NoMethodError: undefined method `absolute_path?' for File
  fails "File.absolute_path? returns true if it's an absolute pathname" # NoMethodError: undefined method `absolute_path?' for File
  fails "File.absolute_path? takes into consideration the platform's root" # NoMethodError: undefined method `absolute_path?' for File
  fails "File.dirname when level is passed calls #to_int if passed not numeric value" # NoMethodError: undefined method `<' for #<Object:0x56914>
  fails "File.dirname when level is passed raises ArgumentError if the level is negative" # Expected ArgumentError (negative level: -1) but got: ArgumentError (level can't be negative)
  fails "File.expand_path accepts objects that have a #to_path method" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path converts a pathname to an absolute pathname" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path converts a pathname to an absolute pathname, Ruby-Talk:18512" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path converts a pathname to an absolute pathname, using a complete path" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path does not expand ~ENV['USER'] when it's not at the start" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path does not modify a HOME string argument" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path does not modify the string argument" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path does not replace multiple '/' at the beginning of the path" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expand path with" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expand_path for common unix path gives a full path" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands ../foo with ~/dir as base dir to /path/to/user/home/foo" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands /./dir to /dir" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands a path when the default external encoding is BINARY" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands a path with multi-byte characters" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands ~ENV['USER'] to the user's home directory" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands ~ENV['USER']/a to a in the user's home directory" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path keeps trailing dots on absolute pathname" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path raises a TypeError if not passed a String type" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path raises an ArgumentError if the path is not valid" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path raises an Encoding::CompatibilityError if the external encoding is not compatible" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path replaces multiple '/' with a single '/'" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path returns a String in the same encoding as the argument" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path returns a String when passed a String subclass" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path when HOME is not set raises an ArgumentError when passed '~' if HOME == ''" # Expected ArgumentError but no exception was raised ("/" was returned)
  fails "File.expand_path with a non-absolute HOME raises an ArgumentError" # Expected ArgumentError (non-absolute home) but no exception was raised ("non-absolute" was returned)
  fails "File.extname for a filename ending with a dot returns '.'" # Expected "" == "." to be truthy but was false
  fails "File.join calls #to_path" # Expected TypeError but got: NoMethodError (undefined method `empty?' for #<MockObject:0x32afc @name="x" @null=nil>)
  fails "File.join calls #to_str" # Expected TypeError but got: NoMethodError (undefined method `empty?' for #<MockObject:0x32af2 @name="x" @null=nil>)
  fails "File.join inserts the separator in between empty strings and arrays" # Expected "/" == "" to be truthy but was false
  fails "File.join raises a TypeError exception when args are nil" # Expected TypeError but got: NoMethodError (undefined method `empty?' for nil)
  fails "File.join raises errors for null bytes" # Expected ArgumentError but no exception was raised ("\u0000x/metadata.gz" was returned)
  fails "File.join returns a duplicate string when given a single argument" # Expected "usr" not to be identical to "usr"
end
