opal_filter "Language" do
  fails "The unpacking splat operator (*) when applied to a non-Array value attempts to coerce it to Array if the object respond_to?(:to_ary)"
  fails "The defined? keyword for literals for a literal Array returns nil if one element is not defined"
  fails "The defined? keyword for literals for a literal Array returns nil if all elements are not defined"
  fails "The defined? keyword for pseudo-variables returns 'expression' for __ENCODING__"
  fails "The defined? keyword for loop expressions returns 'expression' for a 'for' expression"
  fails "The defined? keyword for loop expressions returns 'expression' for a 'retry' expression"
  fails "The redo statement raises a LocalJumpError if used not within block or while/for loop"
  fails "The retry statement raises a LocalJumpError if used outside of a block"
  fails "The retry statement re-executes the entire enumeration"
  fails "not() returns false if the argument is true"
  fails "not() returns true if the argument is false"
  fails "not() returns true if the argument is nil"
end
