opal_filter "File" do
  fails "File.join returns a duplicate string when given a single argument"
  fails "File.join raises a TypeError exception when args are nil"
  fails "File.join calls #to_str"
  fails "File.join calls #to_path"
  fails "File.join raises an ArgumentError if passed a recursive array"
  fails "File.join inserts the separator in between empty strings and arrays"
  fails "File.expand_path accepts objects that have a #to_path method" # Mock 'path' expected to receive 'to_path' exactly 1 times but received it 0 times
  fails "File.expand_path accepts objects that have a #to_path method" # NoMethodError: undefined method `split' for #<MockObject:0x4ca>
  fails "File.expand_path expands ~ENV['USER'] to the user's home directory" # Expected "./~elia" to equal "/Users/elia"
  fails "File.expand_path raises a TypeError if not passed a String type" # NoMethodError: undefined method `split' for 1
  fails "File.expand_path raises an ArgumentError if the path is not valid" # Expected ArgumentError but no exception was raised ("./~a_not_existing_user" was returned)
  fails "File.expand_path returns a String when passed a String subclass" # NameError: uninitialized constant FileSpecs
  fails "File.expand_path does not modify the string argument" # Expected "a/c" to equal "/a/c"
  fails "File.expand_path converts a pathname to an absolute pathname" # Expected "" to equal nil
  fails "File.expand_path returns a String in the same encoding as the argument" # NameError: uninitialized constant Encoding::SHIFT_JIS
  fails "File.expand_path converts a pathname to an absolute pathname, Ruby-Talk:18512" # NoMethodError: undefined method `empty?' for nil
  fails "File.expand_path converts a pathname to an absolute pathname, using a complete path" # Expected "." to equal ""
  fails "File.expand_path converts a pathname to an absolute pathname, using a complete path" # Expected "." to equal ""
  fails "File.expand_path expands a path with multi-byte characters" # Expected "Ångström" to equal "/Ångström"
  fails "File.expand_path does not expand ~ENV['USER'] when it's not at the start" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path does not modify a HOME string argument" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path does not replace multiple '/' at the beginning of the path" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path expand path with" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path expand_path for commoms unix path  give a full path" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path expands ../foo with ~/dir as base dir to /path/to/user/home/foo" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path expands /./dir to /dir" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path expands a path when the default external encoding is ASCII-8BIT" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path expands ~ENV['USER']/a to a in the user's home directory" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path keeps trailing dots on absolute pathname" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path raises an Encoding::CompatibilityError if the external encoding is not compatible" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path replaces multiple '/' with a single '/'" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.expand_path when HOME is not set raises an ArgumentError when passed '~' if HOME == ''" # Expected ArgumentError but no exception was raised ("/" was returned)
  fails "File.expand_path with a non-absolute HOME raises an ArgumentError" # Expected ArgumentError (non-absolute home) but no exception was raised ("non-absolute" was returned)
  fails "File.expand_path expand_path for common unix path gives a full path" # ArgumentError: [Dir.home] wrong number of arguments(1 for 0)
  fails "File.absolute_path resolves paths relative to the current working directory" # Expected "./ruby/core/file/hello.txt" to equal "ruby/core/file/hello.txt"
  fails "File.absolute_path accepts a second argument of a directory from which to resolve the path" # Expected "./ruby/core/file/ruby/core/file/absolute_path_spec.rb" to equal "ruby/core/file/absolute_path_spec.rb"
  fails "File.absolute_path does not expand '~user' to a home directory." # Expected "./ruby/core/file/~user" to equal "ruby/core/file/~user"
end
