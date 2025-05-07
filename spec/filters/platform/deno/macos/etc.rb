# NOTE: run bin/format-filters after changing this file
opal_filter "Etc" do
  fails "Etc.passwd returns a Etc::Passwd struct" # Expected nil (NilClass) to be an instance of Etc::Passwd
end
