opal_filter "BasicObject" do
  fails "BasicObject#instance_eval evaluates strings"
  fails "BasicObject#instance_exec passes arguments to the block"
end
