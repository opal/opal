# NOTE: run bin/format-filters after changing this file
opal_filter "Encoding" do
  fails "Source files encoded in UTF-16 BE without a BOM are parsed as empty because they contain a NUL byte before the encoding comment" # NotImplementedError: NotImplementedError
  fails "Source files encoded in UTF-8 with a BOM can be parsed" # NotImplementedError: NotImplementedError
  fails "Source files encoded in UTF-8 without a BOM can be parsed" # NotImplementedError: NotImplementedError
end
