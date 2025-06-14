# NOTE: run bin/format-filters after changing this file
opal_filter "ENV" do
  fails "ENV.[] uses the locale encoding if Encoding.default_internal is nil" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "ENV.shift uses the locale encoding if Encoding.default_internal is nil" # Expected #<Encoding:UTF-8> to be identical to #<Encoding:ASCII-8BIT>
end
