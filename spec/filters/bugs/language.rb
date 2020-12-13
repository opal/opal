# NOTE: run bin/format-filters after changing this file
opal_filter "language" do
  fails "A Symbol literal with invalid bytes raises an EncodingError at parse time" # Actually passes, the error comes from the difference between MRI's opal and compiled opal-parser
  fails "A block yielded a single Array assigns elements to required arguments when a keyword rest argument is present"
  fails "A block yielded a single Array assigns non-symbol keys to non-keyword arguments"
  fails "A block yielded a single Array assigns symbol keys from a Hash returned by #to_hash to keyword arguments"
  fails "A block yielded a single Array assigns symbol keys from a Hash to keyword arguments"
  fails "A block yielded a single Array assigns the last element to a non-keyword argument if #to_hash returns nil"
  fails "A block yielded a single Array calls #to_hash on the argument and uses resulting hash as first argument when optional argument and keyword argument accepted" # Expected [nil, {"a"=>1, "b"=>2}] == [{"a"=>1, "b"=>2}, {}] to be truthy but was false
  fails "A block yielded a single Array calls #to_hash on the argument but does not use the result when no keywords are present"
  fails "A block yielded a single Array calls #to_hash on the argument" # Expected [nil, {"a"=>1, "b"=>2}] to equal [{"a"=>1, "b"=>2}, {}]
  fails "A block yielded a single Array does not treat hashes with string keys as keyword arguments"
  fails "A block yielded a single Array raises a TypeError if #to_hash does not return a Hash"
  fails "A block yielded a single Array when non-symbol keys are in a keyword arguments Hash separates non-symbol keys and symbol keys" # Expected [nil, {"a"=>10, "b"=>2}] to equal [{"a"=>10}, {"b"=>2}]
  fails "A class definition allows using self as the superclass if self is a class"
  fails "A class definition extending an object (sclass) allows accessing the block of the original scope" # Opal::SyntaxError: undefined method `uses_block!' for nil
  fails "A class definition extending an object (sclass) can use return to cause the enclosing method to return"
  fails "A class definition extending an object (sclass) raises a TypeError when trying to extend non-Class" # Expected TypeError (/superclass must be a.* Class/) but no exception was raised (nil was returned)
  fails "A class definition extending an object (sclass) raises a TypeError when trying to extend numbers"
  fails "A class definition raises TypeError if any constant qualifying the class is not a Module"
  fails "A class definition raises TypeError if the constant qualifying the class is nil"
  fails "A class definition raises a TypeError if inheriting from a metaclass"
  fails "A lambda expression 'lambda { ... }' assigns variables from parameters for definition \n    def m(a) yield a end\n    def m2() yield end\n    @a = lambda { |a, | a }"
  fails "A lambda expression 'lambda { ... }' requires a block"
  fails "A lambda expression 'lambda { ... }' with an implicit block can be created"
  fails "A lambda literal -> () { } assigns variables from parameters with circular optional argument reference shadows an existing local with the same name as the argument"
  fails "A lambda literal -> () { } assigns variables from parameters with circular optional argument reference shadows an existing method with the same name as the argument"
  fails "A lambda literal -> () { } assigns variables from parameters with circular optional argument reference warns and uses a nil value when there is an existing local variable with same name" # Expected warning to match: /circular argument reference/ but got: ""
  fails "A lambda literal -> () { } assigns variables from parameters with circular optional argument reference warns and uses a nil value when there is an existing method with same name" # Expected warning to match: /circular argument reference/ but got: ""
  fails "A method assigns local variables from method parameters for definition 'def m() end'" # ArgumentError: [SpecEvaluate#m] wrong number of arguments(1 for 0)
  fails "A method assigns local variables from method parameters for definition 'def m(*a) a end'" # Expected [{}] to equal []
  fails "A method assigns local variables from method parameters for definition 'def m(*a, **) a end'"
  fails "A method assigns local variables from method parameters for definition 'def m(*a, **k) [a, k] end'"
  fails "A method assigns local variables from method parameters for definition 'def m(*a, b: 1) [a, b] end'"
  fails "A method assigns local variables from method parameters for definition 'def m(*a, b:) [a, b] end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a = nil, **k) [a, k] end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a:) a end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a:, **) a end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a:, **k) [a, k] end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a:, b: 1) [a, b] end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a:, b:) [a, b] end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a=1, **) a end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a=1, b: 2) [a, b] end'"
  fails "A method assigns local variables from method parameters for definition 'def m(a=1, b:) [a, b] end'"
  fails "A method assigns local variables from method parameters for definition \n    def m(a, b = nil, c = nil, d, e: nil, **f)\n      [a, b, c, d, e, f]\n    end" # Exception: Cannot read property '$$is_array' of undefined
  fails "A method definition in an eval creates a class method"
  fails "A method definition in an eval creates a singleton method"
  fails "A method definition in an eval creates an instance method"
  fails "A nested method definition creates a class method when evaluated in a class method"
  fails "A nested method definition creates a method in the surrounding context when evaluated in a def expr.method"
  fails "A nested method definition creates an instance method inside Class.new" # NoMethodError: undefined method `new_def' for #<#<Class:0x40de>:0x40dc>
  fails "A nested method definition creates an instance method when evaluated in an instance method"
  fails "A number literal can be a decimal literal with trailing 'r' to represent a Rational" # requires String#to_r
  fails "A number literal can be a float literal with trailing 'r' to represent a Rational" # Expected (5030569068109113/288230376151711740) == (136353847812057/7812500000000000) to be truthy but was false
  fails "A singleton class doesn't have singleton class"
  fails "A singleton class raises a TypeError for Fixnum's"
  fails "A singleton class raises a TypeError for symbols"
  fails "A singleton method definition can be declared for a global variable"
  fails "A singleton method definition raises FrozenError with the correct class name" # Expected FrozenError but no exception was raised ("foo" was returned)
  fails "Allowed characters allows non-ASCII lowercased characters at the beginning" # Expected nil == 1 to be truthy but was false
  fails "Allowed characters allows not ASCII characters in the middle of a name" # NoMethodError: undefined method `mod' for #<MSpecEnv:0xa920>
  fails "An ensure block inside 'do end' block is executed even when a symbol is thrown in it's corresponding begin block" # Expected ["begin", "rescue", "ensure"] to equal ["begin", "ensure"]
  fails "An ensure block inside a begin block is executed even when a symbol is thrown in it's corresponding begin block"
  fails "An ensure block inside a class is executed even when a symbol is thrown" # Expected ["class", "rescue", "ensure"] to equal ["class", "ensure"]
  fails "An instance method definition with a splat requires the presence of any arguments that precede the *" # ArgumentError: [MSpecEnv#foo] wrong number of arguments(1 for -3)
  fails "An instance method raises FrozenError with the correct class name" # Expected FrozenError but no exception was raised (#<Module:0x225b4> was returned)
  fails "An instance method raises an error with too few arguments" # ArgumentError: [MSpecEnv#foo] wrong number of arguments(1 for 2)
  fails "An instance method raises an error with too many arguments" # ArgumentError: [MSpecEnv#foo] wrong number of arguments(2 for 1)
  fails "An instance method with a default argument evaluates the default when required arguments precede it" # ArgumentError: [MSpecEnv#foo] wrong number of arguments(0 for -2)
  fails "An instance method with a default argument prefers to assign to a default argument before a splat argument" # ArgumentError: [MSpecEnv#foo] wrong number of arguments(0 for -2)
  fails "An instance method with a default argument shadows an existing method with the same name as the local"
  fails "An instance method with a default argument warns and uses a nil value when there is an existing local method with same name" # Expected warning to match: /circular argument reference/ but got: ""
  fails "Constant resolution within methods with dynamically assigned constants searches Object as a lexical scope only if Object is explicitly opened"
  fails "Constant resolution within methods with statically assigned constants searches Object as a lexical scope only if Object is explicitly opened"
  fails "Executing break from within a block raises LocalJumpError when converted into a proc during a a super call" # Expected LocalJumpError but no exception was raised (1 was returned)
  fails "Executing break from within a block returns from the original invoking method even in case of chained calls"
  fails "Executing break from within a block works when passing through a super call" # Expected to not get Exception
  fails "Execution variable $: is initialized to an array of strings"
  fails "Execution variable $: is read-only"
  fails "Execution variable $: is the same object as $LOAD_PATH and $-I"
  fails "Global variable $-a is read-only"
  fails "Global variable $-d is an alias of $DEBUG"
  fails "Global variable $-l is read-only"
  fails "Global variable $-p is read-only"
  fails "Global variable $-v is an alias of $VERBOSE"
  fails "Global variable $-w is an alias of $VERBOSE"
  fails "Global variable $0 is the path given as the main script and the same as __FILE__"
  fails "Global variable $0 raises a TypeError when not given an object that can be coerced to a String"
  fails "Global variable $< is read-only"
  fails "Global variable $? is read-only"
  fails "Global variable $? is thread-local"
  fails "Global variable $FILENAME is read-only"
  fails "Global variable $VERBOSE converts truthy values to true" # Expected 1 to be true
  fails "Global variable $\" is read-only"
  fails "Hash literal expands a BasicObject using ** into the containing Hash literal initialization" # NoMethodError: undefined method `respond_to?' for BasicObject
  fails "Heredoc string allow HEREDOC with <<\"identifier\", interpolated" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Heredoc string allows HEREDOC with <<'identifier', no interpolation" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Heredoc string allows HEREDOC with <<-'identifier', allowing to indent identifier, no interpolation" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Heredoc string allows HEREDOC with <<-\"identifier\", allowing to indent identifier, interpolated" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Heredoc string allows HEREDOC with <<-identifier, allowing to indent identifier, interpolated" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Heredoc string allows HEREDOC with <<identifier, interpolated" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Heredoc string prints a warning if quoted HEREDOC identifier is ending not on same line" # Opal::SyntaxError: unterminated string meets end of file
  fails "Instantiating a singleton class raises a TypeError when allocate is called"
  fails "Instantiating a singleton class raises a TypeError when new is called"
  fails "Invoking a method expands the Array elements from the splat after executing the arguments and block if no other arguments follow the splat" # Expected [[1, nil], nil] to equal [[1], nil]
  fails "Literal (A::X) constant resolution with dynamically assigned constants evaluates the right hand side before evaluating a constant path"
  fails "Literal Regexps caches the Regexp object"
  fails "Literal Regexps raises a RegexpError for lookbehind with specific characters" # Expected RegexpError but no exception was raised (0 was returned)
  fails "Literal Regexps support handling unicode 9.0 characters with POSIX bracket expressions" # Expected "" to equal "𐓘"
  fails "Literal Regexps supports (?# )"
  fails "Literal Regexps supports (?> ) (embedded subexpression)"
  fails "Literal Regexps supports \\g (named backreference)"
  fails "Literal Regexps supports character class composition"
  fails "Literal Regexps supports conditional regular expressions with named capture groups" # Exception: named captures are not supported in javascript: "^(?<word>foo)?(?(<word>)(T)|(F))$"
  fails "Literal Regexps supports conditional regular expressions with positional capture groups" # Exception: Invalid regular expression: /^(foo)?(?(1)(T)|(F))$/: Invalid group
  fails "Literal Regexps supports escaping characters when used as a terminator" # Expected "!" to equal "(?-mix:!)"
  fails "Literal Regexps supports possessive quantifiers"
  fails "Literal Regexps throws SyntaxError for malformed literals"
  fails "Literal Regexps treats an escaped non-escapable character normally when used as a terminator" # Expected "\\$" to equal "(?-mix:\\$)"
  fails "Local variable shadowing leads to warning in verbose mode" # Expected warning to match: /shadowing outer local variable/ but got: ""
  fails "Magic comment is optional"
  fails "Magic comments in a loaded file are case-insensitive" # LoadError: cannot load such file -- ruby/language/fixtures/case_magic_comment
  fails "Magic comments in a loaded file are optional" # LoadError: cannot load such file -- ruby/language/fixtures/no_magic_comment
  fails "Magic comments in a loaded file can be after the shebang" # LoadError: cannot load such file -- ruby/language/fixtures/shebang_magic_comment
  fails "Magic comments in a loaded file can take Emacs style" # LoadError: cannot load such file -- ruby/language/fixtures/emacs_magic_comment
  fails "Magic comments in a loaded file can take vim style" # LoadError: cannot load such file -- ruby/language/fixtures/vim_magic_comment
  fails "Magic comments in a loaded file determine __ENCODING__" # LoadError: cannot load such file -- ruby/language/fixtures/magic_comment
  fails "Magic comments in a loaded file do not cause bytes to be mangled by passing them through the wrong encoding" # LoadError: cannot load such file -- ruby/language/fixtures/bytes_magic_comment
  fails "Magic comments in a loaded file must be at the first line" # LoadError: cannot load such file -- ruby/language/fixtures/second_line_magic_comment
  fails "Magic comments in a loaded file must be the first token of the line" # LoadError: cannot load such file -- ruby/language/fixtures/second_token_magic_comment
  fails "Magic comments in a required file are case-insensitive" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file are optional" # Expected nil to equal "UTF-8"
  fails "Magic comments in a required file can be after the shebang" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file can take Emacs style" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file can take vim style" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file determine __ENCODING__" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file do not cause bytes to be mangled by passing them through the wrong encoding" # Expected nil to equal "[167, 65, 166, 110]"
  fails "Magic comments in a required file must be at the first line" # Expected nil to equal "UTF-8"
  fails "Magic comments in a required file must be the first token of the line" # Expected nil to equal "UTF-8"
  fails "Magic comments in an -e argument are case-insensitive" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument are optional" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument can be after the shebang" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument can take Emacs style" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument can take vim style" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument determine __ENCODING__" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument do not cause bytes to be mangled by passing them through the wrong encoding" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument must be at the first line" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument must be the first token of the line" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an eval are case-insensitive" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in an eval are optional" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in an eval can be after the shebang" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in an eval can take Emacs style" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in an eval can take vim style" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in an eval determine __ENCODING__" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in an eval do not cause bytes to be mangled by passing them through the wrong encoding" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in an eval must be at the first line" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in an eval must be the first token of the line" # ArgumentError: [File.read] wrong number of arguments(2 for 1)
  fails "Magic comments in stdin are case-insensitive" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin are optional" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin can be after the shebang" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin can take Emacs style" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin can take vim style" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin determine __ENCODING__" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin do not cause bytes to be mangled by passing them through the wrong encoding" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin must be at the first line" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin must be the first token of the line" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in the main file are case-insensitive" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "Magic comments in the main file are optional" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "Magic comments in the main file can be after the shebang" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "Magic comments in the main file can take Emacs style" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "Magic comments in the main file can take vim style" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "Magic comments in the main file determine __ENCODING__" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "Magic comments in the main file do not cause bytes to be mangled by passing them through the wrong encoding" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "Magic comments in the main file must be at the first line" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "Magic comments in the main file must be the first token of the line" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x8aa2e>
  fails "NoMethodError#message calls receiver.inspect only when calling Exception#message" # Expected ["inspect_called"] to equal []
  fails "NoMethodError#message fallbacks to a simpler representation of the receiver when receiver.inspect raises an exception" # NoMethodError: undefined method `name' for #<NoMethodErrorSpecs::InstanceException: NoMethodErrorSpecs::InstanceException>
  fails "Operators * / % are left-associative"
  fails "Optional variable assignments using compounded constants with &&= assignments" # Expected warning to match: /already initialized constant/ but got: ""
  fails "Optional variable assignments using compounded constants with operator assignments" # Expected warning to match: /already initialized constant/ but got: ""
  fails "Optional variable assignments using compunded constants with ||= assignments"
  fails "Post-args with optional args with a circular argument reference shadows an existing local with the same name as the argument"
  fails "Post-args with optional args with a circular argument reference shadows an existing method with the same name as the argument"
  fails "Post-args with optional args with a circular argument reference warns and uses a nil value when there is an existing local variable with same name" # Expected warning to match: /circular argument reference/ but got: ""
  fails "Post-args with optional args with a circular argument reference warns and uses a nil value when there is an existing method with same name" # Expected warning to match: /circular argument reference/ but got: ""
  fails "Predefined global $+ captures the last non nil capture"
  fails "Predefined global $+ is equivalent to $~.captures.last"
  fails "Predefined global $, raises TypeError if assigned a non-String"
  fails "Predefined global $-0 changes $/"
  fails "Predefined global $-0 does not call #to_str to convert the object to a String"
  fails "Predefined global $-0 raises a TypeError if assigned a Fixnum"
  fails "Predefined global $-0 raises a TypeError if assigned a boolean"
  fails "Predefined global $-0 raises a TypeError if assigned an Integer" # Expected TypeError but no exception was raised (1 was returned)
  fails "Predefined global $. can be assigned a Float" # Expected 123.5 to equal 123
  fails "Predefined global $. raises TypeError if object can't be converted to an Integer" # Expected TypeError but no exception was raised (#<MockObject:0x518b4> was returned)
  fails "Predefined global $. should call #to_int to convert the object to an Integer" # Expected #<MockObject:0x518c2> to equal 321
  fails "Predefined global $/ changes $-0"
  fails "Predefined global $/ does not call #to_str to convert the object to a String"
  fails "Predefined global $/ raises a TypeError if assigned a Fixnum"
  fails "Predefined global $/ raises a TypeError if assigned a boolean"
  fails "Predefined global $/ raises a TypeError if assigned an Integer" # Expected TypeError but no exception was raised (#<Number>(#pretty_inspect raised #<TypeError: no implicit conversion of Number into String>) was returned)
  fails "Predefined global $_ is Thread-local"
  fails "Predefined global $_ is set at the method-scoped level rather than block-scoped"
  fails "Predefined global $_ is set to the last line read by e.g. StringIO#gets"
  fails "Predefined global $stdout raises TypeError error if assigned to nil"
  fails "Predefined global $stdout raises TypeError error if assigned to object that doesn't respond to #write"
  fails "Predefined global $~ is set at the method-scoped level rather than block-scoped"
  fails "Predefined global $~ raises an error if assigned an object not nil or instanceof MatchData"
  fails "Ruby String interpolation returns a string with the source encoding by default" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
  fails "Ruby String interpolation returns a string with the source encoding, even if the components have another encoding" # ArgumentError: unknown encoding name - euc-jp
  fails "Safe navigator allows assignment methods"
  fails "Safe navigator allows assignment operators"
  fails "Safe navigator does not call the operator method lazily with an assignment operator"
  fails "The =~ operator with named captures on syntax of 'string_literal' =~ /regexp/ does not set local variables" # Exception: named captures are not supported in javascript: "(?<matched>foo)(?<unmatched>bar)?"
  fails "The =~ operator with named captures on syntax of /regexp/ =~ string_variable sets local variables by the captured pairs"
  fails "The =~ operator with named captures on syntax of regexp_variable =~ string_variable does not set local variables"
  fails "The =~ operator with named captures on syntax of string_variable =~ /regexp/ does not set local variables"
  fails "The =~ operator with named captures on the method calling does not set local variables"
  fails "The BEGIN keyword accesses variables outside the eval scope"
  fails "The BEGIN keyword runs first in a given code unit"
  fails "The BEGIN keyword runs in a shared scope"
  fails "The BEGIN keyword runs multiple begins in FIFO order"
  fails "The BEGIN keyword uses top-level for self" # NameError: uninitialized constant TOPLEVEL_BINDING
  fails "The END keyword runs last in a given code unit" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1e972>
  fails "The END keyword runs multiple ends in LIFO order" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1e972>
  fails "The END keyword runs only once for multiple calls" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1e972>
  fails "The __ENCODING__ pseudo-variable is US-ASCII by default"
  fails "The __ENCODING__ pseudo-variable is the encoding specified by a magic comment in the file"
  fails "The __ENCODING__ pseudo-variable is the encoding specified by a magic comment inside an eval"
  fails "The __ENCODING__ pseudo-variable is the evaluated strings's one inside an eval"
  fails "The __FILE__ pseudo-variable equals the absolute path of a file loaded by a relative path" # we can't clear $LOADED_FEATURES, should be treated as readonly
  fails "The __FILE__ pseudo-variable equals the absolute path of a file loaded by an absolute path" # we can't clear $LOADED_FEATURES, should be treated as readonly
  fails "The __LINE__ pseudo-variable equals the line number of the text in a loaded file"
  fails "The alias keyword can create a new global variable, synonym of the original" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x4478>
  fails "The alias keyword can override an existing global variable and make them synonyms" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x4478>
  fails "The alias keyword is not allowed against Fixnum or String instances"
  fails "The alias keyword is not allowed against Integer or String instances" # Expected TypeError but got: Exception (Cannot read property '$to_s' of undefined)
  fails "The alias keyword on top level defines the alias on Object"
  fails "The alias keyword operates on methods defined via attr, attr_reader, and attr_accessor"
  fails "The alias keyword operates on the object's metaclass when used in instance_eval"
  fails "The alias keyword supports aliasing twice the same global variables" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x22a72>
  fails "The break statement in a captured block from a scope that has returned raises a LocalJumpError when calling the block from a method"
  fails "The break statement in a captured block from a scope that has returned raises a LocalJumpError when yielding to the block"
  fails "The break statement in a captured block from another thread raises a LocalJumpError when getting the value from another thread" # NameError: uninitialized constant Thread
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when invoking the block from a method"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when invoking the block from the scope creating the block"
  fails "The break statement in a captured block when the invocation of the scope creating the block is still active raises a LocalJumpError when yielding to the block"
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from a block"
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from a method"
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from the toplevel"
  fails "The break statement in a lambda from a scope that has returned raises a LocalJumpError when yielding to a lambda passed as a block argument"
  fails "The break statement in a lambda from a scope that has returned returns a value to the block scope invoking the lambda in a method" # Exception: $brk is not defined
  fails "The break statement in a lambda from a scope that has returned returns a value to the method scope invoking the lambda" # Exception: $brk is not defined
  fails "The break statement in a lambda returns from the call site if the lambda is passed as a block" # Expected ["before", "unreachable1", "unreachable2", "after"] to equal ["before", "after"]
  fails "The break statement in a lambda when the invocation of the scope creating the lambda is still active returns a value to a block scope invoking the lambda in a method below" # Exception: $brk is not defined
  fails "The break statement in a lambda when the invocation of the scope creating the lambda is still active returns a value to the method scope below invoking the lambda" # Exception: $brk is not defined
  fails "The break statement in a lambda when the invocation of the scope creating the lambda is still active returns a value to the scope creating and calling the lambda" # Exception: $brk is not defined
  fails "The break statement in a lambda when the invocation of the scope creating the lambda is still active returns from the lambda" # Exception: unexpected break
  fails "The break statement in a lambda when the invocation of the scope creating the lambda is still active returns nil when not passed an argument" # Exception: $brk is not defined
  fails "The class keyword does not raise a SyntaxError when opening a class without a semicolon" # NameError: uninitialized constant ClassSpecsKeywordWithoutSemicolon
  fails "The def keyword within a closure looks outside the closure for the visibility"
  fails "The defined? keyword for a scoped constant returns nil when a constant is defined on top-level but not on the class" # Expected "constant" to be nil
  fails "The defined? keyword for variables returns 'instance-variable' for an instance variable that has been assigned to nil"
  fails "The defined? keyword for variables returns nil for a global variable that has been read but not assigned to"
  fails "The defined? keyword for variables when a Regexp matches a String returns nil for non-captures"
  fails "The defined? keyword for variables when a String matches a Regexp returns nil for non-captures"
  fails "The if expression accepts multiple assignments in conditional expression with nil values" # NoMethodError: undefined method `ary' for #<MSpecEnv:0x50754>
  fails "The if expression accepts multiple assignments in conditional expression with non-nil values" # NoMethodError: undefined method `ary' for #<MSpecEnv:0x50754>
  fails "The if expression with a boolean range ('flip-flop' operator) allows combining two flip-flops"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the second conditions lazily with exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the second conditions lazily with inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) keeps flip-flops from interfering"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics a sed conditional with a many-element exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics a sed conditional with a zero-element exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics an awk conditional with a many-element inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics an awk conditional with a single-element inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) scopes state by flip-flop"
  fails "The next statement in a method is invalid and raises a SyntaxError"
  fails "The or operator has a lower precedence than 'next' in 'next true or false'"
  fails "The predefined global constants includes TOPLEVEL_BINDING"
  fails "The redo statement in a method is invalid and raises a SyntaxError"
  fails "The redo statement triggers ensure block when re-executing a block"
  fails "The rescue keyword can capture the raised exception using a setter method" # NoMethodError: undefined method `message' for nil
  fails "The rescue keyword can capture the raised exception using a square brackets setter" # ArgumentError: [SquareBracketsCaptor#[]=] wrong number of arguments(1 for 2)
  fails "The rescue keyword inline form can be inlined" # Expected Infinity to equal 1
  fails "The rescue keyword only accepts Module or Class in rescue clauses" # RuntimeError: error
  fails "The rescue keyword only accepts Module or Class in splatted rescue clauses" # RuntimeError: error
  fails "The rescue keyword rescues the exception in the deepest rescue block declared to handle the appropriate exception type" # Expected "StandardError: an error occurred" to include ":in `raise_standard_error'"
  fails "The rescue keyword will execute an else block even without rescue and ensure" # Expected warning to match: /else without rescue is useless/ but got: ""
  fails "The rescue keyword without rescue expression will not rescue exceptions except StandardError" # NameError: uninitialized constant SystemStackError
  fails "The retry keyword inside a begin block's rescue block causes the begin block to be executed again"
  fails "The retry statement raises a SyntaxError when used outside of a begin statement"
  fails "The retry statement re-executes the closest block"
  fails "The return keyword at top level within a block within a class is allowed" # Exception: path.substr is not a function
  fails "The super keyword passes along modified rest args when they were originally empty"
  fails "The super keyword passes along modified rest args when they weren't originally empty"
  fails "The super keyword passes along reassigned rest args" # Expected ["bar"] to equal ["foo"]
  fails "The super keyword uses block argument given to method when used in a block" # LocalJumpError: no block given
  fails "The super keyword uses given block even if arguments are passed explicitly"
  fails "The super keyword when using keyword arguments passes any given keyword arguments including optional and required ones to the parent"
  fails "The super keyword when using keyword arguments passes default argument values to the parent" # Expected {} to equal {"b"=>"b"}
  fails "The super keyword when using regular and keyword arguments passes default argument values to the parent" # Expected ["a", {}] to equal ["a", {"c"=>"c"}]
  fails "The super keyword without explicit arguments passes arguments and rest arguments including any modifications"
  fails "The super keyword without explicit arguments passes arguments, rest arguments including modifications, and post arguments" # Expected [1, 2, 3] == [1, 14, 3] to be truthy but was false
  fails "The super keyword without explicit arguments passes optional arguments that have a default value but were modified"
  fails "The super keyword without explicit arguments passes optional arguments that have a default value"
  fails "The super keyword without explicit arguments passes optional arguments that have a non-default value but were modified"
  fails "The super keyword without explicit arguments passes rest arguments including any modifications"
  fails "The super keyword without explicit arguments that are '_' including any modifications" # Expected [1, 2] to equal [14, 2]
  fails "The super keyword wraps into array and passes along reassigned rest args with non-array scalar value" # Expected ["bar"] to equal ["foo"]
  fails "The throw keyword raises an UncaughtThrowError if used to exit a thread" # NotImplementedError: Thread creation not available
  fails "The unpacking splat operator (*) when applied to a BasicObject coerces it to Array if it respond_to?(:to_a)" # NoMethodError: undefined method `respond_to?' for BasicObject
  fails "The until expression restarts the current iteration without reevaluating condition with redo"
  fails "The until modifier restarts the current iteration without reevaluating condition with redo"
  fails "The until modifier with begin .. end block evaluates condition after block execution"
  fails "The until modifier with begin .. end block restart the current iteration without reevaluating condition with redo" # Expected [1] to equal [0, 0, 0, 1, 2]
  fails "The until modifier with begin .. end block runs block at least once (even if the expression is true)"
  fails "The until modifier with begin .. end block skips to end of body with next"
  fails "The while expression stops running body if interrupted by break in a begin ... end element op-assign value"
  fails "The while expression stops running body if interrupted by break in a parenthesized element op-assign value"
  fails "The while modifier with begin .. end block evaluates condition after block execution"
  fails "The while modifier with begin .. end block restarts the current iteration without reevaluating condition with redo" # Expected [1, 1, 1, 2] to equal [0, 0, 0, 1, 2]
  fails "The while modifier with begin .. end block runs block at least once (even if the expression is false)"
  fails "The while modifier with begin .. end block skips to end of body with next"
  fails "The yield call taking a single argument yielding to a lambda should not destructure an Array into multiple arguments" # Expected ArgumentError but no exception was raised ([1, 2] was returned)
  fails "The yield call taking no arguments ignores assignment to the explicit block argument and calls the passed block"
  fails "a method definition that sets more than one default parameter all to the same value only allows overriding the default value of the first such parameter in each set" # ArgumentError: [MSpecEnv#foo] wrong number of arguments(2 for -1)
  fails "a method definition that sets more than one default parameter all to the same value treats the argument after the multi-parameter normally" # ArgumentError: [MSpecEnv#bar] wrong number of arguments(3 for -1)
  fails "self in a metaclass body (class << obj) raises a TypeError for numbers"
  fails "self in a metaclass body (class << obj) raises a TypeError for symbols"
  fails "self.send(:block_given?) returns false when a method defined by define_method is called with a block"
  fails "self.send(:block_given?) returns true if and only if a block is supplied"
  fails "top-level constant lookup on a class does not search Object after searching other scopes" # Expected NameError but no exception was raised (Hash was returned)
  fails_badly "The while expression stops running body if interrupted by break in a begin ... end attribute op-assign-or value"
  fails_badly "The while expression stops running body if interrupted by break in a parenthesized attribute op-assign-or value"
  fails_badly "The while expression stops running body if interrupted by break with unless in a begin ... end attribute op-assign-or value"
  fails_badly "The while expression stops running body if interrupted by break with unless in a parenthesized attribute op-assign-or value"
end
