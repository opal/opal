# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "String#chomp removes the final carriage return, newline from a multibyte String" # Expected  "あれ\r " == "あれ"  to be truthy but was false
  fails "String#chomp removes the final carriage return, newline from a non-ASCII String" # Expected  "abc\r " == "abc"  to be truthy but was false
  fails "String#each_line splits strings containing multibyte characters" # Expected ["foo\n🤡🤡🤡🤡🤡🤡🤡\nbar\nbaz\n"]  == ["foo\n", "🤡🤡🤡🤡🤡🤡🤡\n", "bar\n", "baz\n"]  to be truthy but was false
  fails "String#each_line splits using default newline separator when none is specified" # Expected ["one\ntwo\r\nthree"]  == ["one\n", "two\r\n", "three"]  to be truthy but was false
  fails "String#each_line when `chomp` keyword argument is passed removes new line characters when separator is not specified" # Expected ["hello \nworld\n"]  == ["hello ", "world"]  to be truthy but was false
  fails "String#each_line yields String instances for subclasses" # Expected [StringSpecs::MyString]  == [String, String]  to be truthy but was false
  fails "String#lines splits strings containing multibyte characters" # Expected ["foo\n🤡🤡🤡🤡🤡🤡🤡\nbar\nbaz\n"]  == ["foo\n", "🤡🤡🤡🤡🤡🤡🤡\n", "bar\n", "baz\n"]  to be truthy but was false
  fails "String#lines splits using default newline separator when none is specified" # Expected ["one\ntwo\r\nthree"]  == ["one\n", "two\r\n", "three"]  to be truthy but was false
  fails "String#lines when `chomp` keyword argument is passed removes new line characters when separator is not specified" # Expected ["hello \nworld\n"]  == ["hello ", "world"]  to be truthy but was false
  fails "String#lines when `chomp` keyword argument is passed removes new line characters" # Expected ["hello \nworld\n"]  == ["hello ", "world"]  to be truthy but was false
  fails "String#lines yields String instances for subclasses" # Expected [StringSpecs::MyString]  == [String, String]  to be truthy but was false
end
