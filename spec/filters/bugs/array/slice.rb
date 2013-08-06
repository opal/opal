opal_filter "Array#slice!" do
  fails "Array#slice! does not expand array with negative indices out of bounds"
  fails "Array#slice! does not expand array with indices out of bounds"
  fails "Array#slice! calls to_int on range arguments"
  fails "Array#slice! removes and return elements in range"
  fails "Array#slice! calls to_int on start and length arguments"
end
