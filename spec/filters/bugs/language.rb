# NOTE: run bin/format-filters after changing this file
opal_filter "language" do
  fails "$LOAD_PATH.resolve_feature_path return nil if feature cannot be found" # NoMethodError: undefined method `resolve_feature_path' for []
  fails "$LOAD_PATH.resolve_feature_path returns what will be loaded without actual loading, .rb file" # NoMethodError: undefined method `resolve_feature_path' for []
  fails "$LOAD_PATH.resolve_feature_path returns what will be loaded without actual loading, .so file" # NoMethodError: undefined method `resolve_feature_path' for []
  fails "A Proc taking |*a, **kw| arguments does not autosplat keyword arguments" # Expected [[1], {"a"=>1}] == [[[1, {"a"=>1}]], {}] to be truthy but was false
  fails "A Symbol literal raises an EncodingError at parse time when Symbol with invalid bytes" # Expected EncodingError (invalid symbol in encoding UTF-8 :"\xC3") but no exception was raised ("Ã" was returned)
  fails "A block yielded a single Array assigns elements to mixed argument types" # Expected [1, 2, [], 3, 2, {"x"=>9}] == [1, 2, [3], {"x"=>9}, 2, {}] to be truthy but was false
  fails "A block yielded a single Array does not call #to_hash on final argument to get keyword arguments and does not autosplat" # ArgumentError: expected kwargs
  fails "A block yielded a single Array does not call #to_hash on the argument when optional argument and keyword argument accepted and does not autosplat" # ArgumentError: expected kwargs
  fails "A block yielded a single Array does not call #to_hash on the last element if keyword arguments are present" # ArgumentError: expected kwargs
  fails "A block yielded a single Array does not call #to_hash on the last element when there are more arguments than parameters" # ArgumentError: expected kwargs
  fails "A block yielded a single Array does not treat final Hash as keyword arguments and does not autosplat" # Expected [nil, {"a"=>10}] == [[{"a"=>10}], {}] to be truthy but was false
  fails "A block yielded a single Array does not treat hashes with string keys as keyword arguments and does not autosplat" # Expected [nil, {"a"=>10}] == [[{"a"=>10}], {}] to be truthy but was false
  fails "A block yielded a single Array when non-symbol keys are in a keyword arguments Hash does not separate non-symbol keys and symbol keys and does not autosplat" # Expected [nil, {"a"=>10, "b"=>2}] == [[{"a"=>10, "b"=>2}], {}] to be truthy but was false
  fails "A block yielded a single Object receives the object if it does not respond to #respond_to?" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x551e>
  fails "A class definition extending an object (sclass) can use return to cause the enclosing method to return" # Expected "outer" == "inner" to be truthy but was false
  fails "A class definition raises TypeError if any constant qualifying the class is not a Module" # Expected TypeError but no exception was raised (nil was returned)
  fails "A class definition raises TypeError if the constant qualifying the class is nil" # Expected TypeError but no exception was raised (nil was returned)
  fails "A class definition raises a TypeError if inheriting from a metaclass" # Expected TypeError but no exception was raised (nil was returned)
  fails "A lambda expression 'lambda { ... }' assigns variables from parameters for definition '@a = lambda { |*, **k| k }'" # ArgumentError: expected kwargs
  fails "A lambda expression 'lambda { ... }' assigns variables from parameters for definition \n    def m(a) yield a end\n    def m2() yield end\n    @a = lambda { |a, | a }" # ArgumentError: `block in <main>': wrong number of arguments (given 2, expected 1)
  fails "A lambda expression 'lambda { ... }' requires a block" # Expected ArgumentError but got: Exception (Cannot add property $$is_lambda, object is not extensible)
  fails "A lambda expression 'lambda { ... }' with an implicit block raises ArgumentError" # Expected ArgumentError (/tried to create Proc object without a block/) but got: Exception (Cannot add property $$is_lambda, object is not extensible)
  fails "A lambda literal -> () { } assigns variables from parameters for definition '@a = -> (*, **k) { k }'" # ArgumentError: expected kwargs
  fails "A method assigns local variables from method parameters for definition 'def m() end'" # ArgumentError: [SpecEvaluate#m] wrong number of arguments (given 1, expected 0)
  fails "A method assigns local variables from method parameters for definition 'def m(*a) a end'" # Expected [{}] == [] to be truthy but was false
  fails "A method assigns local variables from method parameters for definition 'def m(a, **) a end'" # Expected ArgumentError but no exception was raised ({"a"=>1, "b"=>2} was returned)
  fails "A method assigns local variables from method parameters for definition 'def m(a, **k) [a, k] end'" # Expected ArgumentError but no exception was raised ([{"a"=>1, "b"=>2}, {}] was returned)
  fails "A method assigns local variables from method parameters for definition 'def m(a, **nil); a end;'" # Expected ArgumentError but no exception was raised ({"a"=>1} was returned)
  fails "A method assigns local variables from method parameters for definition 'def m(a, b: 1) [a, b] end'" # Expected ArgumentError but no exception was raised ([{"a"=>1, "b"=>2}, 1] was returned)
  fails "A method assigns local variables from method parameters for definition 'def m(a:) a end'" # Expected ArgumentError but no exception was raised (1 was returned)
  fails "A method assigns local variables from method parameters for definition 'def m(a:, **k) [a, k] end'" # Expected [1, {"b"=>2}] == [1, {"a"=>1, "b"=>2}] to be truthy but was false
  fails "A method assigns local variables from method parameters for definition 'def m(a:, b: 1) [a, b] end'" # Expected ArgumentError but no exception was raised ([1, 2] was returned)
  fails "A method assigns local variables from method parameters for definition 'def m(a:, b:) [a, b] end'" # Expected ArgumentError but no exception was raised ([1, 2] was returned)
  fails "A method assigns local variables from method parameters for definition 'def m(a=1, b: 2) [a, b] end'" # Expected ArgumentError but no exception was raised ([1, 2] was returned)
  fails "A method assigns local variables from method parameters for definition 'def m(a=1, b:) [a, b] end'" # Expected ArgumentError but no exception was raised ([1, 2] was returned)
  fails "A method assigns local variables from method parameters for definition \n    def m(a, b = nil, c = nil, d, e: nil, **f)\n      [a, b, c, d, e, f]\n    end" # Expected [1, nil, nil, 2, nil, {"foo"=>"bar"}] == [1, 2, nil, {"foo"=>"bar"}, nil, {}] to be truthy but was false
  fails "A method assigns the last Hash to the last optional argument if the Hash contains non-Symbol keys and is not passed as keywords" # Expected ["a", {}, false] == ["a", {"key"=>"value"}, false] to be truthy but was false
  fails "A method definition in an eval creates a class method" # NoMethodError: undefined method `an_eval_class_method' for DefSpecNestedB
  fails "A method definition in an eval creates an instance method" # NoMethodError: undefined method `an_eval_instance_method' for #<DefSpecNested:0x108f2>
  fails "A method raises ArgumentError if passing hash as keyword arguments for definition 'def m(a: nil); a; end'" # Expected ArgumentError but no exception was raised (1 was returned)
  fails "A method when passing an empty keyword splat to a method that does not accept keywords for definition 'def m(*a); a; end'" # Expected [{}] == [] to be truthy but was false
  fails "A method when passing an empty keyword splat to a method that does not accept keywords for definition 'def m(a); a; end'" # Expected ArgumentError but no exception was raised (nil was returned)
  fails "A nested method definition creates a class method when evaluated in a class method" # NoMethodError: undefined method `a_class_method' for DefSpecNested
  fails "A nested method definition creates a method in the surrounding context when evaluated in a def expr.method" # Expected DefSpecNested to have instance method 'inherited_method' but it does not
  fails "A nested method definition creates an instance method inside Class.new" # NoMethodError: undefined method `new_def' for #<#<Class:0x10642>:0x10640>
  fails "A nested method definition creates an instance method when evaluated in an instance method" # NoMethodError: undefined method `an_instance_method' for #<DefSpecNested:0x1064c>
  fails "A number literal can be a decimal literal with trailing 'r' to represent a Rational" # Expected (5404319552844595/18014398509481984) == (3/10) to be truthy but was false
  fails "A number literal can be a float literal with trailing 'r' to represent a Rational" # Expected (5030569068109113/288230376151711740) == (136353847812057/7812500000000000) to be truthy but was false
  fails "A singleton class raises a TypeError for symbols" # Expected TypeError but no exception was raised (#<Class:#<String:0x9093e>> was returned)
  fails "A singleton method definition can be declared for a global variable" # TypeError: can't define singleton
  fails "A singleton method definition raises FrozenError with the correct class name" # Expected "can't modify frozen Class: #<Class:#<Object:0x10574>>".start_with? "can't modify frozen object" to be truthy but was false
  fails "Accessing a class variable raises a RuntimeError when a class variable is overtaken in an ancestor class" # Expected RuntimeError (/class variable @@cvar_overtaken of .+ is overtaken by .+/) but no exception was raised ("subclass" was returned)
  fails "Accessing a class variable raises a RuntimeError when accessed from the toplevel scope (not in some module or class)" # Expected RuntimeError (class variable access from toplevel) but got: NameError (uninitialized class variable @@cvar_toplevel1 in MSpecEnv)
  fails "Allowed characters allows non-ASCII lowercased characters at the beginning" # Expected nil == 1 to be truthy but was false
  fails "Allowed characters allows not ASCII upcased characters at the beginning" # NameError: wrong constant name ἍBB
  fails "Allowed characters parses a non-ASCII upcased character as a constant identifier" # Expected SyntaxError (/dynamic constant assignment/) but no exception was raised ("test" was returned)
  fails "An Exception reaching the top level kills all threads and fibers, ensure clauses are only run for threads current fibers, not for suspended fibers with ensure on non-root fiber" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x29a62>
  fails "An Exception reaching the top level kills all threads and fibers, ensure clauses are only run for threads current fibers, not for suspended fibers with ensure on the root fiber" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x29a62>
  fails "An ensure block inside 'do end' block is executed even when a symbol is thrown in it's corresponding begin block" # Expected ["begin", "rescue", "ensure"] == ["begin", "ensure"] to be truthy but was false
  fails "An ensure block inside a begin block is executed even when a symbol is thrown in it's corresponding begin block" # Expected ["begin", "rescue", "ensure"] == ["begin", "ensure"] to be truthy but was false
  fails "An ensure block inside a class is executed even when a symbol is thrown" # Expected ["class", "rescue", "ensure"] == ["class", "ensure"] to be truthy but was false
  fails "An instance method definition with a splat requires the presence of any arguments that precede the *" # Expected ArgumentError (wrong number of arguments (given 1, expected 2+)) but got: ArgumentError ([MSpecEnv#foo] wrong number of arguments (given 1, expected -3))
  fails "An instance method raises FrozenError with the correct class name" # Expected "can't modify frozen Module: #<Module:0x103d8>".start_with? "can't modify frozen module" to be truthy but was false
  fails "An instance method raises an error with too few arguments" # Expected ArgumentError (wrong number of arguments (given 1, expected 2)) but got: ArgumentError ([MSpecEnv#foo] wrong number of arguments (given 1, expected 2))
  fails "An instance method raises an error with too many arguments" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([MSpecEnv#foo] wrong number of arguments (given 2, expected 1))
  fails "An instance method with a default argument evaluates the default when required arguments precede it" # Expected ArgumentError (wrong number of arguments (given 0, expected 1..2)) but got: ArgumentError ([MSpecEnv#foo] wrong number of arguments (given 0, expected -2))
  fails "An instance method with a default argument prefers to assign to a default argument before a splat argument" # Expected ArgumentError (wrong number of arguments (given 0, expected 1+)) but got: ArgumentError ([MSpecEnv#foo] wrong number of arguments (given 0, expected -2))
  fails "Assigning an anonymous module to a constant sets the name of a module scoped by an anonymous module" # NoMethodError: undefined method `end_with?' for nil
  fails "Evaluation order during assignment with multiple assignment can be used to swap variables with nested method calls" # Expected #<VariablesSpecs::EvalOrder::Node:0x95bdc  @right=   #<VariablesSpecs::EvalOrder::Node:0x95bd8    @left=#<VariablesSpecs::EvalOrder::Node:0x95bdc ...>>> == #<VariablesSpecs::EvalOrder::Node:0x95bd8  @left=   #<VariablesSpecs::EvalOrder::Node:0x95bdc    @right=#<VariablesSpecs::EvalOrder::Node:0x95bd8 ...>>> to be truthy but was false
  fails "Evaluation order during assignment with multiple assignment evaluates from left to right, receivers first then methods" # Expected ["a", "b", "foo", "foo[]=", "bar", "bar.baz="] == ["foo", "bar", "a", "b", "foo[]=", "bar.baz="] to be truthy but was false
  fails "Evaluation order during assignment with single assignment evaluates from left to right" # Expected ["a", "foo", "foo[]="] == ["foo", "a", "foo[]="] to be truthy but was false
  fails "Executing break from within a block raises LocalJumpError when converted into a proc during a a super call" # Expected LocalJumpError but no exception was raised (1 was returned)
  fails "Execution variable $: default $LOAD_PATH entries until sitelibdir included have @gem_prelude_index set" # Expected [].include? nil to be truthy but was false
  fails "Execution variable $: is initialized to an array of strings" # Expected false == true to be truthy but was false
  fails "Execution variable $: is read-only" # Expected NameError but no exception was raised ([] was returned)
  fails "Execution variable $: is the same object as $LOAD_PATH and $-I" # Expected 688882 == 4 to be truthy but was false
  fails "Global variable $-a is read-only" # Expected NameError but no exception was raised (true was returned)
  fails "Global variable $-d is an alias of $DEBUG" # Expected nil to be true
  fails "Global variable $-l is read-only" # Expected NameError but no exception was raised (true was returned)
  fails "Global variable $-p is read-only" # Expected NameError but no exception was raised (true was returned)
  fails "Global variable $-v is an alias of $VERBOSE" # Expected nil to be true
  fails "Global variable $-w is an alias of $VERBOSE" # Expected nil to be true
  fails "Global variable $0 is the path given as the main script and the same as __FILE__" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa7382 @old_stdout=#<IO:0xa @fd=1 @flags="w" @eof=false @closed="read" @write_proc=#<Proc:0xaa7e6> @tty=true> @verbose=nil @dollar_slash="\n" @dollar_dash_zero=nil @dollar_backslash=nil @debug=false @method=nil @object=nil @orig_program_name=nil>
  fails "Global variable $0 raises a TypeError when not given an object that can be coerced to a String" # Expected TypeError but no exception was raised (nil was returned)
  fails "Global variable $< is read-only" # Expected NameError but no exception was raised (nil was returned)
  fails "Global variable $? is read-only" # Expected NameError but no exception was raised (nil was returned)
  fails "Global variable $? is thread-local" # NoMethodError: undefined method `system' for #<MSpecEnv:0xa7382 @old_stdout=#<IO:0xa @fd=1 @flags="w" @eof=false @closed="read" @write_proc=#<Proc:0xaa7e6> @tty=true> @verbose=nil @dollar_slash="\n" @dollar_dash_zero=nil @dollar_backslash=nil>
  fails "Global variable $FILENAME is read-only" # Expected NameError but no exception was raised ("-" was returned)
  fails "Global variable $VERBOSE converts truthy values to true" # Expected 1 to be true
  fails "Global variable $\" is an alias for $LOADED_FEATURES" # Expected [] to be identical to ["corelib/runtime",  "opal",  "opal/base",  "corelib/helpers",  "corelib/module",  ...]
  fails "Global variable $\" is read-only" # Expected NameError but no exception was raised ([] was returned)
  fails "Hash literal checks duplicated float keys on initialization" # Expected warning to match: /key 1.0 is duplicated|duplicated key/ but got: ""
  fails "Hash literal checks duplicated keys on initialization" # Expected warning to match: /key 1000 is duplicated|duplicated key/ but got: ""
  fails "Hash literal expands a BasicObject using ** into the containing Hash literal initialization" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0xab798>
  fails "Hash literal raises an EncodingError at parse time when Symbol key with invalid bytes and 'key: value' syntax used" # Expected EncodingError (invalid symbol in encoding UTF-8 :"\xC3") but no exception was raised ({"Ã"=>1} was returned)
  fails "Hash literal raises an EncodingError at parse time when Symbol key with invalid bytes" # Expected EncodingError (invalid symbol in encoding UTF-8 :"\xC3") but no exception was raised ({"Ã"=>1} was returned)
  fails "Heredoc string allow HEREDOC with <<\"identifier\", interpolated" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Heredoc string allows HEREDOC with <<'identifier', no interpolation" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Heredoc string allows HEREDOC with <<-'identifier', allowing to indent identifier, no interpolation" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Heredoc string allows HEREDOC with <<-\"identifier\", allowing to indent identifier, interpolated" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Heredoc string allows HEREDOC with <<-identifier, allowing to indent identifier, interpolated" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Heredoc string allows HEREDOC with <<identifier, interpolated" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Inside 'endless' method definitions allows method calls without parenthesis" # NoMethodError: undefined method `concat' for "Hi, "
  fails "Instance variables global variable when global variable is uninitialized warns about accessing uninitialized global variable in verbose mode" # Expected warning to match: /warning: global variable `\$specs_uninitialized_global_variable' not initialized/ but got: ""
  fails "Instantiating a singleton class raises a TypeError when allocate is called" # Expected TypeError but no exception was raised (#<Object:0x90a56> was returned)
  fails "Instantiating a singleton class raises a TypeError when new is called" # Expected TypeError but no exception was raised (#<Object:0x90a74> was returned)
  fails "Interrupt shows the backtrace and has a signaled exit status" # NoMethodError: undefined method `popen' for IO
  fails "Keyword arguments are now separated from positional arguments when the method takes a ** parameter does not convert a positional Hash to keyword arguments" # Expected ArgumentError (wrong number of arguments (given 4, expected 3)) but no exception was raised (42 was returned)
  fails "Keyword arguments are now separated from positional arguments when the method takes a key: parameter when it's called with a positional Hash and no ** raises ArgumentError" # Expected ArgumentError (wrong number of arguments (given 4, expected 3)) but no exception was raised (42 was returned)
  fails "Keyword arguments are separated from positional arguments" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation does not work with (*args)" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation works with (*args, **kwargs)" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation works with (...)" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation works with -> (*args, **kwargs) {}" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation works with call(*ruby2_keyword_args)" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation works with proc { |*args, **kwargs| }" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation works with super(*ruby2_keyword_args)" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation works with yield(*ruby2_keyword_args)" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments delegation works with zsuper" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Keyword arguments empty kwargs are treated as if they were not passed when calling a method" # Expected [{}] == [] to be truthy but was false
  fails "Keyword arguments empty kwargs are treated as if they were not passed when yielding to a block" # Expected [{}] == [] to be truthy but was false
  fails "Keyword arguments extra keywords are not allowed without **kwrest" # Expected ArgumentError (unknown keyword: :kw2) but no exception was raised ([] was returned)
  fails "Keyword arguments handle * and ** at the same call site" # Expected [{}] == [] to be truthy but was false
  fails "Keyword arguments raises ArgumentError exception when required keyword argument is not passed" # Expected ArgumentError (/missing keyword: :c/) but got: ArgumentError (missing keyword: c)
  fails "Keyword arguments raises ArgumentError for missing keyword arguments even if there are extra ones" # Expected ArgumentError (/missing keyword: :a/) but got: ArgumentError (missing keyword: a)
  fails "Literal (A::X) constant resolution uses the module or class #inspect to craft the error message if they are anonymous" # Expected NameError (/uninitialized constant <unusable info>::DOES_NOT_EXIST/) but got: NameError (uninitialized constant #<Module:0x913b2>::DOES_NOT_EXIST)
  fails "Literal (A::X) constant resolution uses the module or class #name to craft the error message" # Expected NameError (/uninitialized constant ModuleName::DOES_NOT_EXIST/) but got: NameError (uninitialized constant #<Module:0x913aa>::DOES_NOT_EXIST)
  fails "Literal Ranges creates a simple range as an object literal" # Expected 1..3.equal? 1..3 to be truthy but was false
  fails "Literal Regexps caches the Regexp object" # Expected /foo/ to be identical to /foo/
  fails "Literal Regexps supports (?# )" # Exception: Invalid regular expression: /foo(?#comment)bar/: Invalid group
  fails "Literal Regexps supports (?> ) (embedded subexpression)" # Exception: Invalid regular expression: /(?>foo)(?>bar)/: Invalid group
  fails "Literal Regexps supports \\g (named backreference)" # Expected [] == ["foo1barfoo2", "foo2"] to be truthy but was false
  fails "Literal Regexps supports character class composition" # Expected [] == ["def"] to be truthy but was false
  fails "Literal Regexps supports conditional regular expressions with named capture groups" # Exception: Invalid regular expression: /^(?<word>foo)?(?(<word>)(T)|(F))$/: Invalid group
  fails "Literal Regexps supports conditional regular expressions with positional capture groups" # Exception: Invalid regular expression: /^(foo)?(?(1)(T)|(F))$/: Invalid group
  fails "Literal Regexps supports possessive quantifiers" # Exception: Invalid regular expression: /fooA++bar/: Nothing to repeat
  fails "Literal Regexps throws SyntaxError for malformed literals" # Expected SyntaxError but got: Exception (Invalid regular expression: /(/: Unterminated group)
  fails "Local variable shadowing does not warn in verbose mode" # Expected nil == [3, 3, 3] to be truthy but was false
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
  fails "Magic comments in a required file are optional" # Expected nil == "UTF-8" to be truthy but was false
  fails "Magic comments in a required file can be after the shebang" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file can take Emacs style" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file can take vim style" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file determine __ENCODING__" # NameError: uninitialized constant Encoding::Big5
  fails "Magic comments in a required file do not cause bytes to be mangled by passing them through the wrong encoding" # Expected nil == "[167, 65, 166, 110]" to be truthy but was false
  fails "Magic comments in a required file must be at the first line" # Expected nil == "UTF-8" to be truthy but was false
  fails "Magic comments in a required file must be the first token of the line" # Expected nil == "UTF-8" to be truthy but was false
  fails "Magic comments in an -e argument are case-insensitive" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument are optional" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument can be after the shebang" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument can take Emacs style" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument can take vim style" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument determine __ENCODING__" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument do not cause bytes to be mangled by passing them through the wrong encoding" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument must be at the first line" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an -e argument must be the first token of the line" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in an eval are case-insensitive" # NoMethodError: undefined method `read' for File
  fails "Magic comments in an eval are optional" # NoMethodError: undefined method `read' for File
  fails "Magic comments in an eval can be after the shebang" # NoMethodError: undefined method `read' for File
  fails "Magic comments in an eval can take Emacs style" # NoMethodError: undefined method `read' for File
  fails "Magic comments in an eval can take vim style" # NoMethodError: undefined method `read' for File
  fails "Magic comments in an eval determine __ENCODING__" # NoMethodError: undefined method `read' for File
  fails "Magic comments in an eval do not cause bytes to be mangled by passing them through the wrong encoding" # NoMethodError: undefined method `read' for File
  fails "Magic comments in an eval must be at the first line" # NoMethodError: undefined method `read' for File
  fails "Magic comments in an eval must be the first token of the line" # NoMethodError: undefined method `read' for File
  fails "Magic comments in stdin are case-insensitive" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin are optional" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin can be after the shebang" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin can take Emacs style" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin can take vim style" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin determine __ENCODING__" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin do not cause bytes to be mangled by passing them through the wrong encoding" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin must be at the first line" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in stdin must be the first token of the line" # ArgumentError: unknown encoding name - locale
  fails "Magic comments in the main file are case-insensitive" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "Magic comments in the main file are optional" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "Magic comments in the main file can be after the shebang" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "Magic comments in the main file can take Emacs style" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "Magic comments in the main file can take vim style" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "Magic comments in the main file determine __ENCODING__" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "Magic comments in the main file do not cause bytes to be mangled by passing them through the wrong encoding" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "Magic comments in the main file must be at the first line" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "Magic comments in the main file must be the first token of the line" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7f626 @method="UTF8" @object=#<Proc:0x7f6de> @default=#<Encoding:UTF-8>>
  fails "NoMethodError#message calls receiver.inspect only when calling Exception#message" # Expected ["inspect_called"] == [] to be truthy but was false
  fails "Numbered parameters does not support more than 9 parameters" # Expected NameError (/undefined local variable or method `_10'/) but got: NoMethodError (undefined method `_10' for #<MSpecEnv:0x91b82>)
  fails "Operators * / % are left-associative" # Expected 1 == 1 to be falsy but was true
  fails "Operators <=> == === != =~ !~ have higher precedence than &&" # Expected false == false to be falsy but was true
  fails "Optional constant assignment with ||= causes side-effects of the module part to be applied (for nil constant)" # Expected 3 == 1 to be truthy but was false
  fails "Optional constant assignment with ||= causes side-effects of the module part to be applied only once (for undefined constant)" # Expected 2 == 1 to be truthy but was false
  fails "Optional variable assignments using &&= using a #[] evaluates the index arguments in the correct order" # TypeError: NilClass can't be coerced into Numeric
  fails "Optional variable assignments using &&= using a #[] evaluates the index precisely once" # Expected [] == ["x"] to be truthy but was false
  fails "Optional variable assignments using compounded constants with &&= assignments" # Expected warning to match: /already initialized constant/ but got: ""
  fails "Optional variable assignments using compounded constants with operator assignments" # Expected warning to match: /already initialized constant/ but got: ""
  fails "Pattern matching Array pattern calls #deconstruct once for multiple patterns, caching the result" # Expected ["deconstruct", "deconstruct"] == ["deconstruct"] to be truthy but was false
  fails "Pattern matching Array pattern raises TypeError if #deconstruct method does not return array" # Expected TypeError (/deconstruct must return Array/) but no exception was raised (nil was returned)
  fails "Pattern matching Hash pattern does not match object if #deconstruct_keys method does not return Hash" # Expected TypeError (/deconstruct_keys must return Hash/) but got: NoMethodError (undefined method `key?' for "")
  fails "Pattern matching Hash pattern does not match object if #deconstruct_keys method returns Hash with non-symbol keys" # Expected true == false to be truthy but was false
  fails "Pattern matching Hash pattern raise SyntaxError when keys duplicate in pattern" # Expected SyntaxError (/duplicated key name/) but got: SyntaxError (duplicate hash pattern key a)
  fails "Pattern matching alternative pattern does not support variable binding" # Expected SyntaxError (/illegal variable in alternative pattern/) but no exception was raised (nil was returned)
  fails "Pattern matching can be standalone assoc operator that deconstructs value and properly scopes variables" # Expected [nil, nil] == [0, nil] to be truthy but was false
  fails "Pattern matching cannot mix in and when operators" # Expected SyntaxError (/syntax error, unexpected `in'/) but got: SyntaxError (unexpected token kIN)
  fails "Pattern matching raises NoMatchingPatternError if no pattern matches and evaluates the expression only once" # Expected NoMatchingPatternError (/\[0, 1\]/) but got: NoMethodError (undefined method `+' for nil)
  fails "Pattern matching refinements are used for #=== in constant pattern" # NoMatchingPatternError: {}
  fails "Pattern matching refinements are used for #deconstruct" # NoMatchingPatternError: []
  fails "Pattern matching refinements are used for #deconstruct_keys" # NoMatchingPatternError: {}
  fails "Pattern matching variable pattern allows applying ^ operator to bound variables" # NoMatchingPatternError: [1, 1]
  fails "Pattern matching variable pattern does not support using variable name (except _) several times" # Expected SyntaxError (/duplicated variable name/) but got: SyntaxError (duplicate variable name a)
  fails "Pattern matching variable pattern requires bound variable to be specified in a pattern before ^ operator when it relies on a bound variable" # Expected SyntaxError (/n: no such local variable/) but got: SyntaxError (no such local variable: `n')
  fails "Pattern matching variable pattern supports existing variables in a pattern specified with ^ operator" # SyntaxError: no such local variable: `a'
  fails "Pattern matching warning when regular form does not warn about pattern matching is experimental feature" # NameError: uninitialized constant Warning
  fails "Predefined global $+ captures the last non nil capture" # Expected nil == "a" to be truthy but was false
  fails "Predefined global $+ is equivalent to $~.captures.last" # Expected nil == "o" to be truthy but was false
  fails "Predefined global $, raises TypeError if assigned a non-String" # Expected TypeError but no exception was raised (#<Object:0xa7e06> was returned)
  fails "Predefined global $-0 changes $/" # Expected  " " to be identical to "xyz"
  fails "Predefined global $-0 does not call #to_str to convert the object to a String" # Expected TypeError but no exception was raised (#<MockObject:0xa7ac4 @name="$-0 value", @null=nil> was returned)
  fails "Predefined global $-0 raises a TypeError if assigned a boolean" # Expected TypeError but no exception was raised (true was returned)
  fails "Predefined global $-0 raises a TypeError if assigned an Integer" # Expected TypeError but no exception was raised (1 was returned)
  fails "Predefined global $. can be assigned a Float" # Expected 123.5 == 123 to be truthy but was false
  fails "Predefined global $. raises TypeError if object can't be converted to an Integer" # Expected TypeError but no exception was raised (#<MockObject:0xa7e2c @name="bad-value", @null=nil> was returned)
  fails "Predefined global $. should call #to_int to convert the object to an Integer" # Expected #<MockObject:0xa7fde @name="good-value", @null=nil> == 321 to be truthy but was false
  fails "Predefined global $/ changes $-0" # Expected nil  to be identical to "xyz"
  fails "Predefined global $/ does not call #to_str to convert the object to a String" # Expected TypeError but no exception was raised (#<MockObject>(#pretty_inspect raised #<TypeError: can't convert MockObject into String (MockObject#to_str gives NilClass)>) was returned)
  fails "Predefined global $/ raises a TypeError if assigned a boolean" # Expected TypeError but no exception was raised (#<TrueClass>(#pretty_inspect raised #<TypeError: no implicit conversion of TrueClass into String>) was returned)
  fails "Predefined global $/ raises a TypeError if assigned an Integer" # Expected TypeError but no exception was raised (#<Number>(#pretty_inspect raised #<TypeError: no implicit conversion of Number into String>) was returned)
  fails "Predefined global $= warns when accessed" # Expected warning to match: /is no longer effective/ but got: ""
  fails "Predefined global $= warns when assigned" # Expected warning to match: /is no longer effective/ but got: ""
  fails "Predefined global $\\ does not call #to_str to convert the object to a String" # Expected TypeError but no exception was raised (#<MockObject:0xa7c78 @name="$\\ value", @null=nil> was returned)
  fails "Predefined global $\\ raises a TypeError if assigned not String" # Expected TypeError but no exception was raised (1 was returned)
  fails "Predefined global $_ is Thread-local" # NotImplementedError: Thread creation not available
  fails "Predefined global $_ is set at the method-scoped level rather than block-scoped" # Expected  "bar " ==  "baz " to be truthy but was false
  fails "Predefined global $stdout raises TypeError error if assigned to nil" # Expected TypeError but no exception was raised (nil was returned)
  fails "Predefined global $stdout raises TypeError error if assigned to object that doesn't respond to #write" # Expected TypeError but no exception was raised (#<MockObject:0xa7634 @name="object", @null=nil> was returned)
  fails "Predefined global $~ is set at the method-scoped level rather than block-scoped" # Expected nil == nil to be falsy but was true
  fails "Predefined global $~ raises an error if assigned an object not nil or instanceof MatchData" # Expected TypeError but no exception was raised (#<Object:0xa73aa> was returned)
  fails "Ruby String interpolation returns a string with the source encoding by default" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "Ruby String interpolation returns a string with the source encoding, even if the components have another encoding" # ArgumentError: unknown encoding name - euc-jp
  fails "Source files encoded in UTF-16 LE without a BOM are parsed as empty because they contain a NUL byte before the encoding comment" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x9a8a0>
  fails "The BEGIN keyword accesses variables outside the eval scope" # SyntaxError: Unsupported sexp: preexe
  fails "The BEGIN keyword runs first in a given code unit" # SyntaxError: Unsupported sexp: preexe
  fails "The BEGIN keyword runs in a shared scope" # SyntaxError: Unsupported sexp: preexe
  fails "The BEGIN keyword runs multiple begins in FIFO order" # SyntaxError: Unsupported sexp: preexe
  fails "The BEGIN keyword uses top-level for self" # SyntaxError: Unsupported sexp: preexe
  fails "The END keyword END blocks and at_exit callbacks are mixed runs them all in reverse order of registration" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword allows calling exit inside a handler" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword both exceptions in a handler and in the main script are printed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword calls the nested handler right after the outer one if a handler is nested into another handler" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword decides the exit status if both at_exit and the main script raise SystemExit" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword gives access to the last raised exception - global variables $! and $@" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword is affected by the toplevel assignment" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword runs after all other code" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword runs all handlers even if some raise exceptions" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword runs handlers even if the main script fails to parse" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword runs in reverse order of registration" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The END keyword runs only once for multiple calls" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x193ae>
  fails "The END keyword warns when END is used in a method" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x5bfd0 @method="END" @object=nil>
  fails "The __ENCODING__ pseudo-variable is US-ASCII by default" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "The __ENCODING__ pseudo-variable is the encoding specified by a magic comment in the file" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "The __ENCODING__ pseudo-variable is the encoding specified by a magic comment inside an eval" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "The __ENCODING__ pseudo-variable is the evaluated strings's one inside an eval" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "The __FILE__ pseudo-variable with load equals the absolute path of a file loaded by a relative path" # LoadError: cannot load such file -- ruby/fixtures/code/file_fixture
  fails "The __FILE__ pseudo-variable with load equals the absolute path of a file loaded by an absolute path" # LoadError: cannot load such file -- ruby/fixtures/code/file_fixture
  fails "The __FILE__ pseudo-variable with require equals the absolute path of a file loaded by a relative path" # LoadError: cannot load such file -- ruby/fixtures/code/file_fixture
  fails "The __FILE__ pseudo-variable with require equals the absolute path of a file loaded by an absolute path" # LoadError: cannot load such file -- ruby/fixtures/code/file_fixture
  fails "The __LINE__ pseudo-variable equals the line number of the text in a loaded file" # ArgumentError: [Method#load] wrong number of arguments (given 2, expected 1)
  fails "The alias keyword can create a new global variable, synonym of the original" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1c9ba @obj=#<AliasObject:0x1ce06> @meta=#<Class:#<AliasObject:0x1ce06>>>
  fails "The alias keyword can override an existing global variable and make them synonyms" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1c9ba @obj=#<AliasObject:0x1ce06> @meta=#<Class:#<AliasObject:0x1ce06>>>
  fails "The alias keyword is not allowed against Integer or String instances" # Expected TypeError but no exception was raised (Object was returned)
  fails "The alias keyword on top level defines the alias on Object" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1c9ba @obj=#<AliasObject:0x1ce00> @meta=#<Class:#<AliasObject:0x1ce00>>>
  fails "The alias keyword operates on methods defined via attr, attr_reader, and attr_accessor" # NameError: undefined method `foo' for class `Object'
  fails "The alias keyword operates on the object's metaclass when used in instance_eval" # NameError: undefined method `value' for class `Object'
  fails "The alias keyword supports aliasing twice the same global variables" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1c9ba @obj=#<AliasObject:0x1ce06> @meta=#<Class:#<AliasObject:0x1ce06>>>
  fails "The break statement in a captured block from another thread raises a LocalJumpError when getting the value from another thread" # NotImplementedError: Thread creation not available
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from a block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa5de4 @program=#<BreakSpecs::Lambda:0xa5ea2 @ensures=false>>
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from the toplevel" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa5de4 @program=#<BreakSpecs::Lambda:0xa5eaa @ensures=false>>
  fails "The class keyword does not raise a SyntaxError when opening a class without a semicolon" # NameError: uninitialized constant ClassSpecsKeywordWithoutSemicolon
  fails "The def keyword within a closure looks outside the closure for the visibility" # Expected DefSpecsLambdaVisibility to have private instance method 'some_method' but it does not
  fails "The defined? keyword for a scoped constant returns nil when a constant is defined on top-level but not on the class" # Expected "constant" to be nil
  fails "The defined? keyword for a simple constant returns 'constant' when the constant is defined" # Expected false == true to be truthy but was false
  fails "The defined? keyword for an expression returns 'assignment' for assigning a local variable" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals for a literal Array returns 'expression' if each element is defined" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals returns 'false' for false" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals returns 'nil' for nil" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals returns 'self' for self" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals returns 'true' for true" # Expected false == true to be truthy but was false
  fails "The defined? keyword for super for a method taking no arguments returns 'super' when a superclass method exists" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns 'class variable' when called with the name of a class variable" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns 'global-variable' for a global variable that has been assigned nil" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns 'instance-variable' for an instance variable that has been assigned to nil" # Expected nil == "instance-variable" to be truthy but was false
  fails "The defined? keyword for variables returns 'instance-variable' for an instance variable that has been assigned" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns 'local-variable' when called with the name of a local variable" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns nil for a global variable that has been read but not assigned to" # Expected "global-variable" to be nil
  fails "The defined? keyword for variables when a Regexp matches a String returns nil for non-captures" # Expected "global-variable" to be nil
  fails "The defined? keyword for variables when a String matches a Regexp returns nil for non-captures" # Expected "global-variable" to be nil
  fails "The defined? keyword for yield returns 'yield' if a block is passed to a method not taking a block parameter" # Expected false == true to be truthy but was false
  fails "The defined? keyword when called with a method name having a throw in the receiver escapes defined? and performs the throw semantics as normal" # Expected nil == "unreachable" to be truthy but was false
  fails "The defined? keyword when called with a method name in a void context does not execute the receiver" # Expected "defined_specs_side_effects" == "not_executed" to be truthy but was false
  fails "The defined? keyword when called with a method name in a void context warns about the void context when parsing it" # Expected warning to match: /warning: possibly useless use of defined\? in void context/ but got: ""
  fails "The defined? keyword when called with a method name without a receiver returns 'method' if the method is defined" # Expected false == true to be truthy but was false
  fails "The if expression when a branch syntactically does not return a value raises SyntaxError if both do not return a value" # Expected SyntaxError (/void value expression/) but no exception was raised ("m" was returned)
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with exclusive-end range" # NoMethodError: undefined method `collector' for #<MSpecEnv:0x7bd18>
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with inclusive-end range" # NoMethodError: undefined method `collector' for #<MSpecEnv:0x7bd18>
  fails "The redo statement in a method is invalid and raises a SyntaxError" # Expected SyntaxError but no exception was raised ("m" was returned)
  fails "The redo statement triggers ensure block when re-executing a block" # TypeError: NilClass can't be coerced into Numeric
  fails "The rescue keyword allows rescue in 'do end' block" # NoMethodError: undefined method `call' for nil
  fails "The rescue keyword inline form can be inlined" # Expected Infinity == 1 to be truthy but was false
  fails "The rescue keyword only accepts Module or Class in rescue clauses" # Expected TypeError but got: RuntimeError (error)
  fails "The rescue keyword only accepts Module or Class in splatted rescue clauses" # Expected TypeError but got: RuntimeError (error)
  fails "The rescue keyword rescues the exception in the deepest rescue block declared to handle the appropriate exception type" # Expected "<internal:corelib/runtime.js>:1878:5:in `Opal.send2'" to include ":in `raise_standard_error'"
  fails "The return keyword at top level return with argument warns but does not affect exit status" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1494e @filename=nil>
  fails "The return keyword at top level within BEGIN is allowed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x29c06>
  fails "The return keyword at top level within a block within a class is not allowed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1494e>
  fails "The super keyword is able to navigate to super, when a method is defined dynamically on the singleton class" # Exception: Maximum call stack size exceeded
  fails "The super keyword uses block argument given to method when used in a block" # LocalJumpError: no block given
  fails "The super keyword uses given block even if arguments are passed explicitly" # LocalJumpError: no block given
  fails "The throw keyword raises an UncaughtThrowError if used to exit a thread" # NotImplementedError: Thread creation not available
  fails "The unpacking splat operator (*) when applied to a BasicObject coerces it to Array if it respond_to?(:to_a)" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x4128>
  fails "The yield call taking a single argument yielding to a lambda should not destructure an Array into multiple arguments" # Expected ArgumentError but no exception was raised ([1, 2] was returned)
  fails "The yield call taking no arguments ignores assignment to the explicit block argument and calls the passed block" # Expected #<Proc:0x2b4c> == 42 to be truthy but was false
  fails "Using yield in a singleton class literal raises a SyntaxError" # Expected SyntaxError (/Invalid yield/) but got: SyntaxError (undefined method `uses_block!' for nil)
  fails "Using yield in non-lambda block raises a SyntaxError" # Expected SyntaxError (/Invalid yield/) but got: SyntaxError (undefined method `uses_block!' for nil)
  fails "a method definition that sets more than one default parameter all to the same value only allows overriding the default value of the first such parameter in each set" # Expected ArgumentError (wrong number of arguments (given 2, expected 0..1)) but got: ArgumentError ([MSpecEnv#foo] wrong number of arguments (given 2, expected -1))
  fails "a method definition that sets more than one default parameter all to the same value treats the argument after the multi-parameter normally" # Expected ArgumentError (wrong number of arguments (given 3, expected 0..2)) but got: ArgumentError ([MSpecEnv#bar] wrong number of arguments (given 3, expected -1))
  fails "self in a metaclass body (class << obj) raises a TypeError for symbols" # Expected TypeError but got: Exception (Cannot create property '$$meta' on string 'symbol')
  fails "self.send(:block_given?) returns false when a method defined by define_method is called with a block" # NoMethodError: undefined method `block_given?' for KernelSpecs::SelfBlockGiven
  fails "self.send(:block_given?) returns true if and only if a block is supplied" # NoMethodError: undefined method `block_given?' for KernelSpecs::SelfBlockGiven
  fails "top-level constant lookup on a class does not search Object after searching other scopes" # Expected NameError but no exception was raised (Hash was returned)
  fails_badly "Executing break from within a block works when passing through a super call" # Expected to not get Exception
  fails_badly "The break statement in a lambda created at the toplevel returns a value when invoking from a method" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa5de4 @program=#<BreakSpecs::Lambda:0xa5ea6 @ensures=false>>
end
