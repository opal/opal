opal_filter "block" do
  fails "A block arguments with _ assigns the first variable named"
  fails "A block arguments with _ extracts arguments with _"
  fails "A block taking |*a| arguments does not call #to_ary to convert a single yielded object to an Array"
  fails "A block taking |*| arguments does not call #to_ary to convert a single yielded object to an Array"
end
