opal_filter "Array#[]=" do
  fails "Array#[]= does not call to_ary on rhs array subclasses for multi-element sets"
  fails "Array#[]= calls to_ary on its rhs argument for multi-element sets"
  fails "Array#[]= raises an IndexError when passed indexes out of bounds"
  fails "Array#[]= tries to convert Range elements to Integers using #to_int with [m..n] and [m...n]"

  fails "Array#[]= with [m..n] accepts Range subclasses"
  fails "Array#[]= with [m..n] inserts the other section at m if m > n"
  fails "Array#[]= with [m..n] replaces the section if m < 0 and n > 0"
  fails "Array#[]= with [m..n] replaces the section if m and n < 0"
  fails "Array#[]= with [m..n] just sets the section defined by range to nil if m and n < 0 and the rhs is nil"

  fails "Array#[]= sets elements in the range arguments when passed ranges"
  fails "Array#[]= checks frozen before attempting to coerce arguments"
  fails "Array#[]= calls to_int on its start and length arguments"
  fails "Array#[]= does nothing if the section defined by range has negative width and the rhs is an empty array"
end
