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
end
