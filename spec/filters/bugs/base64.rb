# NOTE: run bin/format-filters after changing this file
opal_filter "Base64" do
  fails "Base64#decode64 returns a binary encoded string" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
  fails "Base64#decode64 returns the Base64-decoded version of the given string with wrong padding" # Expected "]M\u0095¹\u0090\u0081É\u0095¥¹\u0099½É\u008D\u0095µ\u0095¹ÑÌ" == "]M\u0095¹\u0090\u0081ɕ¥¹\u0099½ɍ\u0095µ\u0095¹ÑÌ" to be truthy but was false
  fails "Base64#encode64 returns a US_ASCII encoded string" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
  fails "Base64#strict_decode64 raises ArgumentError when the given string contains an invalid character" # Expected ArgumentError but no exception was raised ("Ü" was returned)
  fails "Base64#strict_decode64 raises ArgumentError when the given string has wrong padding" # Expected ArgumentError but no exception was raised ("\u0001M\u0095¹\u0090\u0081É\u0095¥¹\u0099½É\u008D\u0095µ\u0095¹ÑÌ" was returned)
  fails "Base64#strict_decode64 returns a binary encoded string" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
  fails "Base64#strict_encode64 returns a US_ASCII encoded string" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
end
