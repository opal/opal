opal_filter "strict" do
  fails "Kernel#public_methods returns public methods for immediates" # Exception: Object.defineProperty called on non-object
end