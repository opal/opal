opal_filter "BasicObject" do
  fails "BasicObject raises NoMethodError for nonexistent methods after #method_missing is removed"
  fails "BasicObject#initialize does not accept arguments"
  fails "BasicObject#instance_eval raises a TypeError when defining methods on an immediate"
  fails "BasicObject#instance_eval raises a TypeError when defining methods on numerics"
  fails "BasicObject#instance_eval evaluates string with given filename and linenumber"
  fails "BasicObject#instance_eval evaluates string with given filename and negative linenumber" # Expected ["RuntimeError"] to equal ["b_file", "-98"]
  fails "BasicObject#instance_exec binds the block's binding self to the receiver"
  fails "BasicObject#instance_exec raises a LocalJumpError unless given a block"
  fails "BasicObject#instance_exec raises a TypeError when defining methods on an immediate"
  fails "BasicObject#instance_exec raises a TypeError when defining methods on numerics"
  fails "BasicObject#method_missing for an instance sets the receiver of the raised NoMethodError"
  fails "BasicObject#method_missing for an instance sets the receiver of the raised NoMethodError"
end
