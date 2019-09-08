# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Pathname" do
  fails "Pathname.new is tainted if path is tainted"
end
