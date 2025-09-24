# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Math" do
  fails "Math#atanh is a private instance method" # Expected Math to have private instance method 'atanh' but it does not
end
