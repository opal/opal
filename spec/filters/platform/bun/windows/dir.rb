# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir.mkdir creates the named directory with the given permissions" # Errno::EEXIST: File exists - EEXIST: file already exists, mkdir 'C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/reduced'
end
