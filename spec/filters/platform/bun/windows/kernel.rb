# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#p is not affected by setting $\\, $/ or $," # Errno::EPERM: Operation not permitted - EPERM: operation not permitted, unlink 'C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/mspec_output_to__1744749238'
end
