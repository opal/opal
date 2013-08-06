opal_filter "array" do
  fails "The unpacking splat operator (*) when applied to a non-Array value attempts to coerce it to Array if the object respond_to?(:to_a)"
end
