# NOTE: run bin/format-filters after changing this file
opal_filter "BigDecimal" do
  fails "BigDecimal#** 0 to power of 0 is 1" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#** 0 to powers < 0 is Infinity" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#** other powers of 0 are 0" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#** powers of 1 equal 1" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#** returns 0.0 if self is infinite and argument is negative" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#** returns NaN if self is NaN" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#** returns infinite if self is infinite and argument is positive" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#fix correctly handles special values" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#fix returns 0 if the absolute value is < 1" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#fix returns a BigDecimal" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#fix returns the integer part of the absolute value" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#power 0 to power of 0 is 1" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#power 0 to powers < 0 is Infinity" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#power other powers of 0 are 0" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#power powers of 1 equal 1" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#power returns 0.0 if self is infinite and argument is negative" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#power returns NaN if self is NaN" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#power returns infinite if self is infinite and argument is positive" # NotImplementedError: IO#fsync is not available on this platform
  fails "BigDecimal#truncate returns the integer part as a BigDecimal if no precision given" # NotImplementedError: IO#fsync is not available on this platform
end
