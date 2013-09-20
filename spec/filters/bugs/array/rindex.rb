opal_filter "Array#rindex" do
  fails "Array#rindex rechecks the array size during iteration"
  fails "Array#rindex returns the first index backwards from the end where element == to object"
end
