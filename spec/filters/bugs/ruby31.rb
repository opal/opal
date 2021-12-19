# NOTE: run bin/format-filters after changing this file
opal_filter "Ruby 3.1" do
  fails "main#private returns argument" # Expected nil to be identical to "main_public_method"
  fails "main#public returns argument" # Expected nil to be identical to "main_private_method"
end
