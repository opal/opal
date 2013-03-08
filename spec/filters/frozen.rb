opal_filter "frozen" do
  fails "Array#frozen? returns true if array is frozen"
  fails "Array#frozen? returns false for an array being sorted by #sort"
end
