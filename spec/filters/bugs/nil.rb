opal_filter "nil" do
  fails "NilClass#to_r returns 0/1"
  fails "NilClass#to_c returns Complex(0, 0)"
  fails "NilClass#rationalize raises ArgumentError when passed more than one argument"
  fails "NilClass#rationalize ignores a single argument"
  fails "NilClass#rationalize returns 0/1"
end
