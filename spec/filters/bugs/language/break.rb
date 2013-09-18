opal_filter "break" do
  fails "Break inside a while loop with a splat wraps a non-Array in an Array"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when invoking the block from the scope creating the block"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when invoking the block from a method"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when yielding to the block"
  fails "The break statement in a captured block from a scope that has returned raises a LocalJumpError when calling the block from a method"
  fails "The break statement in a captured block from a scope that has returned raises a LocalJumpError when yielding to the block"
  fails "The break statement in a lambda when the invocation of the scope creating the lambda is still active raises a LocalJumpError when yielding to a lambda passed as a block argument"
  fails "The break statement in a lambda from a scope that has returned raises a LocalJumpError when yielding to a lambda passed as a block argument"
  fails "Executing break from within a block returns from the original invoking method even in case of chained calls"
end
