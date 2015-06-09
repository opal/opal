opal_filter "Integer" do
  fails "Integer#downto [stop] when self and stop are Fixnums when no block is given returned Enumerator size raises an ArgumentError for invalid endpoints"
  fails "Integer#downto [stop] when self and stop are Fixnums when no block is given returned Enumerator size returns self - stop + 1"
  fails "Integer#downto [stop] when self and stop are Fixnums when no block is given returned Enumerator size returns 0 when stop > self"
  fails "Integer#even? returns true for a Bignum when it is an even number"
  fails "Integer#upto [stop] when self and stop are Fixnums when no block is given returned Enumerator size raises an ArgumentError for non-numeric endpoints"
  fails "Integer#upto [stop] when self and stop are Fixnums when no block is given returned Enumerator size returns stop - self + 1"
  fails "Integer#upto [stop] when self and stop are Fixnums when no block is given returned Enumerator size returns 0 when stop < self"
end
