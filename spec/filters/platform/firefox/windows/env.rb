# NOTE: run bin/format-filters after changing this file
opal_filter "ENV" do
  fails "ENV.[] looks up values case-insensitively" # Expected nil == "bar" to be truthy but was false
end
