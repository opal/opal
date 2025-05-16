# NOTE: run bin/format-filters after changing this file
opal_filter "StringIO" do
  fails "StringIO#initialize sets the #external_encoding to the encoding of the String when passed a String" # FrozenError: can't modify frozen String
  fails "StringIO#initialize sets the encoding to the encoding of the String when passed a String" # FrozenError: can't modify frozen String
end
