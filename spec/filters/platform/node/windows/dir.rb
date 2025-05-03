# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir.mktmpdir when passed a block creates the tmp-dir before yielding" # ArgumentError: parent directory is world writable but not sticky: C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp
  fails "Dir.mktmpdir when passed a block removes the tmp-dir after executing the block" # ArgumentError: parent directory is world writable but not sticky: C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp
  fails "Dir.mktmpdir when passed a block returns the blocks return value" # ArgumentError: parent directory is world writable but not sticky: C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp
  fails "Dir.mktmpdir when passed a block yields the path to the passed block" # ArgumentError: parent directory is world writable but not sticky: C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp
end
