# NOTE: run bin/format-filters after changing this file
opal_filter "Proc" do
  fails "Proc as an implicit block pass argument remains the same object if re-vivified by the target method"
  fails "Proc#=== can call its block argument declared with a block argument" # Expected 6 to equal 10
  fails "Proc#=== yields to the block given at declaration and not to the block argument" # Expected 3 to equal 7
  fails "Proc#[] can call its block argument declared with a block argument" # Expected 6 to equal 10
  fails "Proc#[] yields to the block given at declaration and not to the block argument" # Expected 3 to equal 7
  fails "Proc#arity for instances created with proc { || } returns positive values for definition \n    @a = proc { |(a, (*b, c)), d=1| }\n    @b = proc { |a, (*b, c), d, (*e), (*), **k| }"
  fails "Proc#arity for instances created with proc { || } returns positive values for definition \n    @a = proc { |a, b=1| }\n    @b = proc { |a, b, c=1, d=2| }"
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |**k, &l| }\n    @b = proc { |a: 1, b: 2, **k| }"
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a: 1| }\n    @b = proc { |a: 1, b: 2| }"
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a=1, b: 2| }\n    @b = proc { |a=1, b: 2| }"
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a=1| }\n    @b = proc { |a=1, b=2| }"
  fails "Proc#binding returns a Binding instance"
  fails "Proc#binding returns the binding associated with self"
  fails "Proc#call can call its block argument declared with a block argument" # Expected 6 to equal 10
  fails "Proc#call yields to the block given at declaration and not to the block argument" # Expected 3 to equal 7
  fails "Proc#curry with arity argument returns Procs with arities of -1 regardless of the value of _arity_"
  fails "Proc#curry with arity argument returns a Proc if called on a lambda that requires fewer than _arity_ arguments but may take more" # ArgumentError: wrong number of arguments (4 for 5)
  fails "Proc#inspect for a proc created with Proc.new has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with Symbol#to_proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with Symbol#to_proc has an ASCII-8BIT encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with Symbol#to_proc returns a description including '(&:symbol)'" # Expected "#<Proc:0x75d4e>" to match /^#<Proc:0x\h+\(&:foobar\)>$/
  fails "Proc#inspect for a proc created with UnboundMethod#to_proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with UnboundMethod#to_proc returns a description including '(lambda)' and optionally including file and line number"
  fails "Proc#inspect for a proc created with lambda has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with lambda returns a description including '(lambda)' and optionally including file and line number"
  fails "Proc#inspect for a proc created with proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#lambda? is preserved when passing a Proc with & to the lambda keyword"
  fails "Proc#lambda? is preserved when passing a Proc with & to the proc keyword"
  fails "Proc#source_location returns an Array"
  fails "Proc#source_location returns the first line of a multi-line proc (i.e. the line containing 'proc do')"
  fails "Proc#source_location returns the location of the proc's body; not necessarily the proc itself"
  fails "Proc#source_location returns the same value for a proc-ified method as the method reports" # Expected ["ruby/core/proc/fixtures/source_location.rb", 3] to equal nil
  fails "Proc#source_location sets the first value to the path of the file in which the proc was defined"
  fails "Proc#source_location sets the last value to a Fixnum representing the line on which the proc was defined"
  fails "Proc#source_location works even if the proc was created on the same line"
  fails "Proc#to_s for a proc created with Proc.new has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with Symbol#to_proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with Symbol#to_proc has an ASCII-8BIT encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with Symbol#to_proc returns a description including '(&:symbol)'" # Expected "#<Proc:0x6cd2c>" to match /^#<Proc:0x\h+\(&:foobar\)>$/
  fails "Proc#to_s for a proc created with UnboundMethod#to_proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with UnboundMethod#to_proc returns a description including '(lambda)' and optionally including file and line number"
  fails "Proc#to_s for a proc created with lambda has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with lambda returns a description including '(lambda)' and optionally including file and line number"
  fails "Proc#to_s for a proc created with proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#yield can call its block argument declared with a block argument" # Expected 6 to equal 10
  fails "Proc#yield yields to the block given at declaration and not to the block argument" # Expected 3 to equal 7
  fails "Proc.allocate raises a TypeError"
  fails "Proc.new with a block argument called indirectly from a subclass returns the passed proc created from a block"
  fails "Proc.new with a block argument called indirectly from a subclass returns the passed proc created from a method"
  fails "Proc.new with a block argument called indirectly from a subclass returns the passed proc created from a symbol"
  fails "Proc.new with an associated block called on a subclass of Proc returns an instance of the subclass"
  fails "Proc.new with an associated block called on a subclass of Proc that does not 'super' in 'initialize' still constructs a functional proc"
  fails "Proc.new with an associated block called on a subclass of Proc using a reified block parameter returns an instance of the subclass"
  fails "Proc.new with an associated block calls initialize on the Proc object"
  fails "Proc.new with an associated block raises a LocalJumpError when context of the block no longer exists"
  fails "Proc.new with an associated block returns a new Proc instance from the block passed to the containing method"
  fails "Proc.new with an associated block returns a subclass of Proc"
  fails "Proc.new without a block uses the implicit block from an enclosing method when called inside a block" # ArgumentError: tried to create a Proc object without a block
  fails "Proc.new without a block uses the implicit block from an enclosing method"
end
