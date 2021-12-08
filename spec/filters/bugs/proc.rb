# NOTE: run bin/format-filters after changing this file
opal_filter "Proc" do
  fails "Proc#<< composition is a lambda when parameter is lambda" # NoMethodError: undefined method `<<' for #<Proc:0x760e0>
  fails "Proc#<< does not try to coerce argument with #to_proc" # Expected TypeError (callable object is expected) but got: NoMethodError (undefined method `<<' for #<Proc:0x760c8>)
  fails "Proc#<< raises TypeError if passed not callable object" # Expected TypeError (callable object is expected) but got: NoMethodError (undefined method `<<' for #<Proc:0x760d8>)
  fails "Proc#== is a public method" # Expected Proc to have public instance method '==' but it does not
  fails "Proc#== returns true if other is a dup of the original" # Expected false to be true
  fails "Proc#=== can call its block argument declared with a block argument" # Expected 6 to equal 10
  fails "Proc#=== on a Proc created with Kernel#lambda or Kernel#proc ignores excess arguments when self is a proc" # ArgumentError: expected kwargs
  fails "Proc#=== yields to the block given at declaration and not to the block argument" # Expected 3 to equal 7
  fails "Proc#>> composition is a lambda when self is lambda" # NoMethodError: undefined method `>>' for #<Proc:0x76126>
  fails "Proc#>> does not try to coerce argument with #to_proc" # Expected TypeError (callable object is expected) but got: NoMethodError (undefined method `>>' for #<Proc:0x76108>)
  fails "Proc#>> raises TypeError if passed not callable object" # Expected TypeError (callable object is expected) but got: NoMethodError (undefined method `>>' for #<Proc:0x76116>)
  fails "Proc#[] can call its block argument declared with a block argument" # Expected 6 to equal 10
  fails "Proc#[] yields to the block given at declaration and not to the block argument" # Expected 3 to equal 7
  fails "Proc#arity for instances created with proc { || } returns positive values for definition \n    @a = proc { |(a, (*b, c)), d=1| }\n    @b = proc { |a, (*b, c), d, (*e), (*), **k| }"
  fails "Proc#arity for instances created with proc { || } returns positive values for definition \n    @a = proc { |a, b=1| }\n    @b = proc { |a, b, c=1, d=2| }"
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |**k, &l| }\n    @b = proc { |a: 1, b: 2, **k| }"
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a: 1| }\n    @b = proc { |a: 1, b: 2| }"
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a=1, b: 2| }\n    @b = proc { |a=1, b: 2| }"
  fails "Proc#arity for instances created with proc { || } returns zero for definition \n    @a = proc { |a=1| }\n    @b = proc { |a=1, b=2| }"
  fails "Proc#binding returns the binding associated with self"
  fails "Proc#call can call its block argument declared with a block argument" # Expected 6 to equal 10
  fails "Proc#call on a Proc created with Kernel#lambda or Kernel#proc ignores excess arguments when self is a proc" # ArgumentError: expected kwargs
  fails "Proc#call yields to the block given at declaration and not to the block argument" # Expected 3 to equal 7
  fails "Proc#curry with arity argument returns Procs with arities of -1 regardless of the value of _arity_"
  fails "Proc#curry with arity argument returns a Proc if called on a lambda that requires fewer than _arity_ arguments but may take more" # ArgumentError: wrong number of arguments (4 for 5)
  fails "Proc#eql? is a public method" # Expected Proc to have public instance method 'eql?' but it does not
  fails "Proc#eql? returns true if other is a dup of the original" # Expected false to be true
  fails "Proc#inspect for a proc created with Proc.new has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with Proc.new returns a description including file and line number" # Expected "#<Proc:0x200>" =~ /^#<Proc:([^ ]*?)@ruby\/core\/proc\/shared\/to_s\.rb:6>$/ to be truthy but was nil
  fails "Proc#inspect for a proc created with Symbol#to_proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with Symbol#to_proc returns a description including '(&:symbol)'" # Expected "#<Proc:0x75d4e>" to match /^#<Proc:0x\h+\(&:foobar\)>$/
  fails "Proc#inspect for a proc created with UnboundMethod#to_proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with UnboundMethod#to_proc returns a description including '(lambda)' and optionally including file and line number"
  fails "Proc#inspect for a proc created with lambda has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with lambda returns a description including '(lambda)' and including file and line number" # Expected "#<Proc:0x22e>" =~ /^#<Proc:([^ ]*?)@ruby\/core\/proc\/shared\/to_s\.rb:16 \(lambda\)>$/ to be truthy but was nil
  fails "Proc#inspect for a proc created with proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#inspect for a proc created with proc returns a description including file and line number" # Expected "#<Proc:0x25a>" =~ /^#<Proc:([^ ]*?)@ruby\/core\/proc\/shared\/to_s\.rb:26>$/ to be truthy but was nil
  fails "Proc#lambda? is preserved when passing a Proc with & to the lambda keyword"
  fails "Proc#lambda? is preserved when passing a Proc with & to the proc keyword"
  fails "Proc#ruby2_keywords marks the final hash argument as keyword hash" # NoMethodError: undefined method `ruby2_keywords' for #<Proc:0x36616>
  fails "Proc#ruby2_keywords prints warning when a proc accepts keyword splat" # NoMethodError: undefined method `ruby2_keywords' for #<Proc:0x365fe>
  fails "Proc#ruby2_keywords prints warning when a proc accepts keywords" # NoMethodError: undefined method `ruby2_keywords' for #<Proc:0x36612>
  fails "Proc#ruby2_keywords prints warning when a proc does not accept argument splat" # NoMethodError: undefined method `ruby2_keywords' for #<Proc:0x3660a>
  fails "Proc#ruby2_keywords returns self" # NoMethodError: undefined method `ruby2_keywords' for #<Proc:0x36602>
  fails "Proc#source_location returns an Array"
  fails "Proc#source_location returns the first line of a multi-line proc (i.e. the line containing 'proc do')"
  fails "Proc#source_location returns the location of the proc's body; not necessarily the proc itself"
  fails "Proc#source_location returns the same value for a proc-ified method as the method reports" # Expected ["ruby/core/proc/fixtures/source_location.rb", 3] to equal nil
  fails "Proc#source_location sets the first value to the path of the file in which the proc was defined"
  fails "Proc#source_location sets the last value to an Integer representing the line on which the proc was defined" # NoMethodError: undefined method `last' for nil
  fails "Proc#source_location works even if the proc was created on the same line"
  fails "Proc#to_s for a proc created with Proc.new has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with Proc.new returns a description including file and line number" # Expected "#<Proc:0x17cc0>" =~ /^#<Proc:([^ ]*?)@ruby\/core\/proc\/shared\/to_s\.rb:6>$/ to be truthy but was nil
  fails "Proc#to_s for a proc created with Symbol#to_proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with Symbol#to_proc returns a description including '(&:symbol)'" # Expected "#<Proc:0x6cd2c>" to match /^#<Proc:0x\h+\(&:foobar\)>$/
  fails "Proc#to_s for a proc created with UnboundMethod#to_proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with UnboundMethod#to_proc returns a description including '(lambda)' and optionally including file and line number"
  fails "Proc#to_s for a proc created with lambda has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with lambda returns a description including '(lambda)' and including file and line number" # Expected "#<Proc:0x17cec>" =~ /^#<Proc:([^ ]*?)@ruby\/core\/proc\/shared\/to_s\.rb:16 \(lambda\)>$/ to be truthy but was nil
  fails "Proc#to_s for a proc created with proc has a binary encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Proc#to_s for a proc created with proc returns a description including file and line number" # Expected "#<Proc:0x17d18>" =~ /^#<Proc:([^ ]*?)@ruby\/core\/proc\/shared\/to_s\.rb:26>$/ to be truthy but was nil
  fails "Proc#yield can call its block argument declared with a block argument" # Expected 6 to equal 10
  fails "Proc#yield on a Proc created with Kernel#lambda or Kernel#proc ignores excess arguments when self is a proc" # ArgumentError: expected kwargs
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
  fails "Proc.new with an associated block returns a subclass of Proc"
  fails "Proc.new without a block raises an ArgumentError when passed no block" # Expected ArgumentError (tried to create Proc object without a block) but got: ArgumentError (tried to create a Proc object without a block)
end
