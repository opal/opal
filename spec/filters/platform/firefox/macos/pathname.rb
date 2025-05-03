# NOTE: run bin/format-filters after changing this file
opal_filter "Pathname" do
  fails "Pathname#glob returns matching file paths when a flag is provided" # Expected [] == [#<Pathname://tmp/rubyspec_temp/pathname_glob/lib/.hidden.rb>,  #<Pathname://tmp/rubyspec_temp/pathname_glob/lib/ipaddr.rb>,  #<Pathname://tmp/rubyspec_temp/pathname_glob/lib/irb.rb>] to be truthy but was false
  fails "Pathname#glob returns matching file paths" # Expected [] == [#<Pathname://tmp/rubyspec_temp/pathname_glob/lib/ipaddr.rb>,  #<Pathname://tmp/rubyspec_temp/pathname_glob/lib/irb.rb>] to be truthy but was false
  fails "Pathname#glob yields matching file paths to block" # Expected [] to be nil
  fails "Pathname.glob does not raise an ArgumentError when supplied a flag and :base keyword argument" # Expected [] == [#<Pathname:.hidden.rb>, #<Pathname:ipaddr.rb>, #<Pathname:irb.rb>] to be truthy but was false
  fails "Pathname.glob returns matching file paths when a flag is provided" # Expected [] == [#<Pathname://tmp/rubyspec_temp/pathname_glob/lib/.hidden.rb>,  #<Pathname://tmp/rubyspec_temp/pathname_glob/lib/ipaddr.rb>,  #<Pathname://tmp/rubyspec_temp/pathname_glob/lib/irb.rb>] to be truthy but was false
  fails "Pathname.glob returns matching file paths when supplied :base keyword argument" # Expected [] == [#<Pathname:ipaddr.rb>, #<Pathname:irb.rb>] to be truthy but was false
  fails "Pathname.glob returns matching file paths" # Expected [] == [#<Pathname://tmp/rubyspec_temp/pathname_glob/lib/ipaddr.rb>,  #<Pathname://tmp/rubyspec_temp/pathname_glob/lib/irb.rb>] to be truthy but was false
end
