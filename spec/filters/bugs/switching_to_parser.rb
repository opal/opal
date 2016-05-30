opal_filter "To fix in spec/language:" do
  # while_spec
  fails "The while modifier returns nil if ended when condition became false"
  fails "The while expression stops running body if interrupted by break in a parenthesized element op-assign-or value"
  fails "The next statement from within the block returns to the invoking method, with the specified value"

  # _ args
  fails "A block arguments with _ assigns the first variable named"

  # for_spec
  fails "The for expression executes code in containing variable scope with 'do'"
  fails "The for expression executes code in containing variable scope"

  # precedence_spec
  fails "Operators or/and have higher precedence than if unless while until modifiers"
end

opal_filter 'To fix in corelib/**:' do
  # hash
  fails "Hash#default_proc= uses :to_proc on its argument" # looks like it didn't work before, returning value must be a passed argument

  # range (most probably a super issue)
  fails "Range#min given a block passes each pair of values in the range to the block"
  fails "Range#min given a block passes each pair of elements to the block where the first argument is the current element, and the last is the first element"
  fails "Range#min given a block returns the element the block determines to be the minimum"
  fails "Range#max given a block passes each pair of values in the range to the block"
  fails "Range#max given a block passes each pair of elements to the block in reversed order"
  fails "Range#max given a block returns the element the block determines to be the maximum"

  # string
  fails "String#rindex with Regexp returns nil if the substring isn't found"
end
