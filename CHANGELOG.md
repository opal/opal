# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

Changes are grouped as follows:
- **Added** for new features.
- **Changed** for changes in existing functionality.
- **Deprecated** for once-stable features removed in upcoming releases.
- **Removed** for deprecated features removed in this release.
- **Fixed** for any bug fixes.
- **Security** to invite users to upgrade in case of vulnerabilities.

<!--
Whitespace conventions:
- 4 spaces before ## titles
- 2 spaces before ### titles
- 1 spaces before normal text
 -->




## [0.10.0] - Unreleased


### Added

- `Module#included_modules` works
- Internal runtime cleanup (#1241)
- Make it easier to add custom runners for the CLI (#1261)
- Add Rack v2 compatibility (#1260)
- Newly compliant with the Ruby Spec Suite:
    * `Array#slice!`
    * `Array#repeated_combination`
    * `Array#repeated_permutation`
    * `Array#sort_by!`
    * `Enumerable#sort`
    * `Enumerable#max`
    * `Enumerable#each_entry` (#1303)
    * `Module#const_set`
- Add `-L` / `--library` option to compile only the code of the library (#1281)
- Implement `Kernel.open` method (#1218)
- Generate meaningful names for functions representing Ruby methods
- Implement `Pathname#join` and `Pathname#+` methods (#1301)
- Added support for `begin;rescue;else;end`.
- Implement `File.extname` method (#1219)
- Implement File.extname method (#1219)
- Added support for keyword arguments as lambda parameters.
- Super works with define_method blocks
- Added support for kwsplats.
- Added support for squiggly heredoc.
- Implement `Method#parameters` and `Proc#parameters`.


### Changed

- Remove deprecation of `Opal::Environment` after popular request
- Setting `Opal::Config.dynamic_require_severity` will no longer affect `Opal.dynamic_require_severity` which now needs to be explicitly set if it differs from the default value of `"warning"` (See also the `Opal.dynamic_require_severity` rename below).
- The new default for `Opal::Config.dynamic_require_severity` is now `:warning`
- `Opal.dynamic_require_severity` and `OPAL_CONFIG` are now merged into `Opal.config.missing_require_severity` (defaults to `error`, the expected ruby behavior) and `Opal.config.unsupported_features_severity` (defaults to `warning`, e.g. a one-time heads up that freezing isn't supported). Added variable `__OPAL_COMPILER_CONFIG__` that contains compiler options that may be used in runtime.
- `Hash` instances should now list the string map (`$$smap`) as the first key, making debugging easier (most hashes will just have keys there).
- Handle Pathname object in Pathname constructor


### Deprecated

- `Opal::Processor.stubbed_files` and `Opal::Processor.stub_file` in favor of `Opal::Config.stubbed_files`


### Removed

- Removed the previously deprecated `Opal::Fragment#to_code`
- Removed the previously deprecated `Opal::Processor.load_asset_code`
- Removed the previously deprecated acceptance of a boolean as single argument to `Opal::Server.new`


### Fixed

- `File::dirname` and `File::basename` are now Rubyspec compliant
- `SourceMap::VLQ` patch (#1075)
- `Regexp::new` no longer throws error when the expression ends in \\\\
- `super` works properly with overwritten alias methods (#1384)
- `NoMethodError` does not need a name to be instantiated
- `method_added` fix for singleton class cases
- Super now works properly with blocks (#1237)
- Fix using more than two `rescue` in sequence (#1269)
- Fixed inheritance for `Array` subclasses.
- Always populate all stub_subscribers with all method stubs, as a side effect of this now `method_missing` on bridged classes now works reliably (#1273)
- Fix `Hash#instance_variables` to not return `#default` and `#default_proc` (#1258)
- Fix `Module#name` when constant was created using `Opal.cdecl` (constant declare) like `ChildClass = Class.new(BaseClass)` (#1259)
- Fix issue with JavaScript `nil` return paths being treated as true (#1274)
- Fix `Array#to_n`, `Hash#to_n`, `Struct#to_n` when the object contains native objects (#1249, #1256)
- `break` semantics are now correct, except for the case in which a lambda containing a `break` is passed to a `yield` (#1250)
- Avoid double "/" when `Opal::Sprockets.javascript_include_tag` receives a prefix with a trailing slash.
- Fixed context of evaluation for `Kernel#eval` and `BasicObject#instance_eval`
- Fix `Module#===` to use all ancestors of the passed object (#1284)
- Fix `Struct.new` to be almost compatible with Rubyspec (#1251)
- Fix `Enumerator#with_index` to return the result of the previously called method.
- Improved `Date.parse` to cover most date formatting cases.
- Fixed `Module#const_get` for dynamically created constants.
- Fixed `File.dirname` to return joined String instead of Array.
- Fixed multiple assignment for constants, i.e., allowing `A, B = 1, 2`.
- Fixed `Number#[]` with negative number. Now `(-1)[1]` returns 1.
- Fixed parsing of pre-defined `$-?` global variables.
- Fixed parsing of unicode constants.
- Fixed parsing of quoted heredoc identifier.
- Fixed parsing of mass assignment of method call without parentheses.
- Fixed parsing of `%I{}` lists.
- Fixed parsing of `%{}` lists when list item contains same brackets.
- Fixed an issue with `"-"` inside the second arg of `String#tr`
- Fixed Base64 and enabled specs
- Fixed method definition in method body.
- Partially implemented `Marshal.load`/`Marshal.dump`. In order to use it require `opal/full`.


### Removed

- Remove support for configuring Opal via `Opal::Processor`, the correct place is `Opal::Config`
- Remove `Opal.process` which used to be an alias to `Sprockets::Environment#[]`




## [0.9.2] - 2016-01-10


### Fixed
- Rebuilt the gem with Ruby 2.2 as building with 2.3 would make the gem un-installable




## [0.9.1] - 2016-01-09


### Fixed
- Backport rack2 compatibility (#1260)
- Fixed issue with JS nil return paths being treated as true (#1274)
- Fix using more than two `rescue` in sequence (#1269)




## [0.9.0] - 2015-12-20


### Added

- A `console` wrapper has been added to the stdlib, requiring it will make available the `$console` global variable.
- `method_added`, `method_removed` and `method_undefined` reflection now works.
- `singleton_method_added`, `singleton_method_removed` and `singleton_method_undefined` reflection now works.
- Now you can bridge a native class to a Ruby class that inherits from another Ruby class
- `Numeric` semantics are now compliant with Ruby.
- `Complex` has been fully implemented.
- `Rational` has been fully implemented.
- `Kernel#raise` now properly re-raises exceptions (regardless of how many levels deep you are) and works properly if supplied a class that has an exception method.
- `Exception#exception`, `Exception::exception`, `Exception#message`, and `Exception#to_s` are fully implemented
- You can make direct JavaScript method calls on using the `recv.JS.method`syntax. Has support for method calls, final callback (as a block), property getter and setter (via `#[]` and `#[]=`), splats, JavaScript keywords (via the `::JS` module) and global functions (after `require "js"`).
- `Set#superset?`, `Set#subset?`, and the respective `proper_` variant of each are now implemented
- `NameError` and `NoMethodError` - add `#name` and `#args` attributes
- `RegExp#match` now works correctly in multiline mode with white space
- `BasicObject#instance_eval` now can accept a string argument (after `require "opal-parser"`)
- Adds Nashorn (Java 8+ Javascript engine) runner `bundle exec bin/opal -R nashorn -r nashorn hello.rb`

- Newly compliant with the Ruby Spec Suite:
    * `Enumerable#chunk`
    * `Enumerable#each_cons`
    * `Enumerable#minmax`
    * `Range#to_a` (#1246)
    * `Module` comparison methods: `#<` `#<=` `#<=>` `#>` `#>=`
    - `OpenStruct#method_missing`
    - `OpenStruct#inspect`
    - `OpenStruct#to_s`
    - `OpenStruct#delete_field`


### Changed

- Renamed:
    - `Hash.keys` => `Hash.$$keys`
    - `Hash.map` => `Hash.$$map`
    - `Hash.smap` => `Hash.$$smap`
- `Kernel#pp` no longer forwards arguments directly to `console.log`, this behavior has been replaced by stdlib's own `console.rb` (see above).
- `Opal::Sprockets.javascript_include_tag` has been added to allow easy debug mode (i.e. with source maps) when including a sprockets asset into an HTML page.


### Deprecated

- `Opal::Processor.load_asset_code(sprockets, name)` has been deprecated in favor of `Opal::Sprockets.load_asset(name, sprockets)`.


### Fixed

- Fixed usage of JavaScript keywords as instance variable names for:
    - `Kernel#instance_variable_set`
    - `Kernel#instance_variable_get`
    - `Kernel#instance_variables`
- `Struct#hash` now works properly based on struct contents
- No longer crashes when calling a method with an opt arg followed by an optional kwarg when called without the kwarg
- Operator methods (e.g. `+`, `<`, etc.) can be handled by `method_missing`
- Fix issue where passing a block after a parameter and a hash was causing block to not be passed (e.g. `method1 some_param, 'a' => 1, &block`)
- Method defs issued inside `Module#instance_eval` and `Class#instance_eval`, and the respective `exec` now create class methods
- Now with enabled arity checks calling a method with more arguments than those supported by its signature raises an `ArgumentError` as well.
- Previously arity checks would raise an error without clearing the block for a method, that could lead to strange bugs in case the error was rescued.
- `Regexp#===` returns false when the right hand side of the expression cannot be coereced to a string (instead of throwing a `TypeError`)
- `Regexp#options` has been optimized and correctly returns 0 when called on a Regexp literal without any options (e.g. `//`)
- Fix `Kernel#exit` to allow exit inside `#at_exit`
- Fixed a number of syntax errors (e.g. #1224 #1225 #1227 #1231 #1233 #1226)
- Fixed `Native()` when used with `Array` instances containing native objects (which weren't wrapped properly) – #1212
- Fix `Array#to_n`, `Hash#to_n`, `Struct#to_n` when the object contains native objects (#1249)
- Internal cleanup and lots of bugs!




## [0.8.1] - 2015-10-12


### Removed

- Use official Sprockets processor cache keys API:
    The old cache key hack has been removed.
    Add `Opal::Processor.cache_key` and `Opal::Processor.reset_cache_key!` to
    reset it as it’s cached but should change whenever `Opal::Config` changes.

### Fixed

- Fix an issue for which a Pathname was passed instead of a String to Sprockets.




## [0.8.0] - 2015-07-16


### Added

- `Hash[]` implementation fully compliant with rubyspec

- Newly compliant with the Ruby Spec Suite:
    - `Array#bsearch`
    - `Array#combination`
    - `Array#permutation`
    - `Array#product`
    - `Array#rotate!`
    - `Array#rotate`
    - `Array#sample`
    - `Array#to_h`
    - `Array#values_at`
    - `Array#zip`
    - `Enumerator#with_index`
    - `Kernel#===`
    - `Kernel#Array`
    - `Kernel#Float`
    - `Kernel#Hash`
    - `Kernel#Integer`
    - `Kernel#String`
    - `Kernel#format`
    - `Kernel#sprintf`
    - `MatchData#==`
    - `MatchData#eql?`
    - `MatchData#values_at`
    - `Module#instance_methods`
    - `Regexp#match`
    - `String#%`
    - `String#===`
    - `String#==`
    - `String#[]`
    - `String#each_line`
    - `String#eql?`
    - `String#index`
    - `String#inspect`
    - `String#lines`
    - `String#match`
    - `String#next`
    - `String#oct`
    - `String#scan`
    - `String#slice`
    - `String#split`
    - `String#succ`
    - `String#to_i`
    - `String#try_convert`


### Changed

- Updated to Sprockets v3.0.
- Enable operator inlining by default in the compiler.


### Removed

- Removed `minitest` from stdlib. It's not part of MRI and it never belonged there, checkout the `opal-minitest` gem instead.


### Fixed

- Delegate dependency management directly to Sprockets (when used) making sourcemaps swift again.
    This means code generated by sprockets will always need to be bootstrapped via `Opal.load` or `Opal.require`.
    Luckily `Opal::Processor.load_asset_code(sprockets, name)` does just that in the right way.
- Fix `Promise#always`.
- Fix `String#split` when no match is found and a limit is provided
- Fix `require_tree(".")` when used from file at the root of the assets paths
- Parser: Allow trailing comma in paren arglists, after normal args as well as assoc args.
- Parser: Fix parsing of parens following divide operator without a space.
- Parser: Fix bug where keyword arguments could not be parsed if method definition did not have parens around arguments.
-  `Module#const_get` now accepts a scoped constant name
-  `Regexp#===` sets global match data vars





## [0.7.2] - 2015-04-23

- Remove Sprockets 3.0 support (focus moved to upcoming 0.8)
- Fix version number consistency.


## [0.7.1] - 2015-02-14

- CLI options `-d` and `-v` now set respectively `$DEBUG` and `$VERBOSE`
- Fixed a bug that would make the `-v` CLI option wait for STDIN input
- Add the `-E` / `--no-exit` CLI option to skip implicit `Kernel#exit` call
- Now the CLI implicitly calls `Kernel#exit` at the end of the script, thus making `at_exit` blocks be respected.


## [0.7.0] - 2015-02-01

- Stop keyword-arg variable names leaking to global javascript scope

- `Class#native_class` now also exposes `MyClass.new` (Ruby) as `Opal.global.MyClass.new()` (JS)

- Add CRuby (MRI) tests harness to start checking Opal against them too.

- Add Minitest to the stdlib.

- Add `Date#<=>` with specs.

- Show extended info and context upon parsing, compiling and building errors.

- Support keyword arguments in method calls and definitions.

- Fix `begin`/`rescue` blocks to evaluate to last expression.

- Add support for `RUBY_ENGINE/RUBY_PLATFORM != "opal"` pre-processor directives.

        if RUBY_ENGINE != "opal"
          # this code never compiles
        end

- Fix donating methods defined in modules. This ensures that if a class includes more than one module, then the methods defined on the class respect the order in which the modules are included.

- Improved support for recursive `Hash` for both `#inspect` and `#hash`.

- Optimized `Hash` implementation for `String` and `Symbol`, they have a separate hash-table in which they're used as both keys and hashes.

- Added real `#hash` / `eql?` support, previously was relying on `.toString()`.

- `String#to_proc` now uses `__send__` instead of `send` for calling
    methods on receivers.

- Deprecated `Opal::Sprockets::Environment`. It can easily be replaced by `Opal::Server` or by appending `Opal.paths` to a `Sprockets::Environment`:

        Sprockets::Environment.new.tap { |e| Opal.paths.each {|p| e.append_path(p)} }

- Add `Set` methods `#classify`, `#collect!`, `#map!`, `#subtract` `#replace`,
    `#difference` and `#eql?`

- Support `module_function` without args to toggle module functions.

- Fix bug where command calls with no space and sym arg were incorrectly parsed.

- Add some `StringScanner` methods.

- Add `Date#<<` and `Date#>>` implementations.

- Support nested directories using `require_tree` directive.

- Fix bug where Exception subclasses could not have methods defined on them.

- Fix symbols with interpolations `:"#{foo}"`

- Implement $1..N matchers and rewrite support for $~, $', $& and $\`.

- Implement `Regexp.last_match`.

- Fixed `-@` unary op. precedence with a numeric and followed by a method call (e.g. `-1.foo` was parsed as `-(1.foo)`)

- `require_relative` (with strings) is now preprocessed, expanded and added to `Compiler#requires`

- Rewritten the require system to respect requires position (previously all the requires were stacked up at the top of the file)

- Implement for-loop syntax

- Add Array#|

- Fix Range.new to raise `ArgumentError` on contructor values that cannot
    be compared

- Fix compiler bug where Contiguous strings were not getting concatenated.

- Cleanup generated code for constant access. All constant lookups now go through `$scope.get('CONST_NAME')` to produce cleaner code and a unified place for const missing dispatch.

- Remove `const_missing` option from compiler. All constant lookups are now strict.

- Add initial support for Module#autoload.

- Fix `Enumerator#with_index`, `Numeric#round`.


## [0.6.2] - 2014-04-25

- Added Range#size

- `opal` executable now reads STDIN when no file or `-e` are passed

- `opal` executable doesn't exit after showing version on `-v` if other options are passed

- (Internal) improved the mspec runner


## [0.6.1] - 2014-04-15

- Updated RubySpec to master and added `rubysl-*` specs. Thanks to Mike Owens (@mieko)

- Added `Kernel#require_remote(url)` in `opal-parser` that requires files with basic synchronous ajax
    GET requests. It is used to load `<scripts type="text/ruby" src="…url…">`.

- Various parsing fixes (Hash parsing, `def` returns method name, cleanup `core/util`, Enumerator fixes)

- Added `#native_reader`, `#native_writer` and `#native_accessor`as class methods
    donated by `include Native`

- Added specs for Sprockets' processors (both .js.rb and .opalerb), backported from `opal-rails`

- Set 2.1.1 as RUBY_VERSION

- Add `opal-build` command utility to easily build libraries to js

- Add `opal-repl` to gemspec executables,
    previously was only available by using Opal from source

- Fix parsing `=>` in hash literals where it would sometimes incorrectly
    parse as a key name.


## [0.6.0] - 2014-03-05

- Fix parsing of escapes in single-strings ('foo\n'). Only ' and \
    characters now get escaped in single quoted strings. Also, more escape
    sequences in double-quoted strings are now supported: `\a`, `\v`, `\f`,
    `\e`, `\s`, octal (`\314`), hex (`\xff`) and unicode (`\u1234`).

- Sourcemaps revamp. Lexer now tracks column and line info for every token to
    produce much more accurate sourcemaps. All method calls are now located on
    the correct source line, and multi-line xstrings are now split to generate
    a map line-to-line for long inline javascript parts.

- Merged sprockets support from `opal-sprockets` directly into Opal. For the
    next release, the exernal `opal-sprockets` gem is no longer needed. This
    commit adds `Opal::Processor`, `Opal::Server` and `Opal::Environment`.

- Introduce pre-processed if directives to hide code from Opal. Two special
    constant checks now take place in the compiler. Either `RUBY_ENGINE` or
    `RUBY_PLATFORM` when `== "opal"`. Both if and unless statements can pick
    up these logic checks:

        if RUBY_ENGINE == "opal"
          # this code compiles
        else
          # this code never compiles
        end

    Unless:

        unless RUBY_ENGINE == "opal"
          # this code never compiles
        end

    This is particularly useful for avoiding `require()` statements being
    picked up, which are included at compile time.

- Add special `debugger` method to compiler. Compiles down to javascript
    `debugger` keyword to start in-browser debug console.

- Add missing string escapes to `read_escape` in lexer. Now most ruby escape
    sequences are properly detected and handled in string parsing.

- Disable escapes inside x-strings. This means no more double escaping all
    characters in x-strings and backticks. (`\n` => `\n`).

- Add `time.rb` to stdlib and moved `Time.parse()` and `Time.iso8601()`
    methods there.

- `!` is now treated as an unary method call on the object. Opal now parsed
    `!` as a def method name, and implements the method on `BasicObject`,
    `NilClass` and `Boolean`.

- Fixed bug where true/false as object literals from javascript were not
    correctly being detected as truthy/falsy respectively. This is due to the
    javascript "feature" where `new Boolean(false) !== false`.

- Moved `native.rb` to stdlib. Native support must now be explicitly required
    into Opal. `Native` is also now a module, instead of a top level class.
    Also added `Native::Object#respond_to?`.

- Remove all core `#as_json()` methods from `json.rb`. Added them externally
    to `opal-activesupport`.

- `Kernel#respond_to?` now calls `#respond_to_missing?` for compliance.

- Fix various `String` methods and add relevant rubyspecs for them. `#chars`,
    `#to_f`, `#clone`, `#split`.

- Fix `Array` method compliance: `#first`, `#fetch`, `#insert`, `#delete_at`,
    `#last`, `#splice`, `.try_convert`.

- Fix compliance of `Kernel#extend` and ensure it calls `#extended()` hook.

- Fix bug where sometimes the wrong regexp flags would be generated in the
    output javascript.

- Support parsing `__END__` constructs in ruby code, inside the lexer. The
    content is gathered up by use of the parser. The special constant `DATA`
    is then available inside the ruby code to read the content.

- Support single character strings (using ? prefix) with escaped characters.

- Fix lexer to detect dereferencing on local variables even when whitespace
    is present (`a = 0; a [0]` parses as a deference on a).

- Fix various `Struct` methods. Fixed `#each` and `#each_pair` to return
    self. Add `Struct.[]` as synonym for `Struct.new`.

- Implemented some `Enumerable` methods: `#collect_concat`, `#flat_map`,
    `#reject`, `#reverse_each`, `#partition` and `#zip`.

- Support any Tilt template for `index_path` in `Opal::Server`. All index
    files are now run through `Tilt` (now supports haml etc).

- Fix code generation of `op_asgn_1` calls (`foo[val] += 10`).

- Add `base64` to stdlib.

- Add promises implementation to stdlib.

- Add `Math` module to corelib.

- Use `//#` instead of `//@` deprecated syntax for sourceMappingURL.

- Implicitly require `erb` from stdlib when including erb templates.

- Fix `Regexp.escape` to also escape '(' character.

- Support '<' and '>' as matching pairs in string boundrys `%q<hi>`.

- `Opal::Server` no longer searches for an index file if not specified.

- Move `Math` and `Encoding` to stdlib. Can be required using
    `require 'math'`, etc.

- Fix some stdlib `Date` methods.

- Fix `Regexp.escape` to properly escape \n, \t, \r, \f characters.

- Add `Regexp.quote` as an alias of `escape`.


## [0.5.5] - 2013-11-25

- Fix regression: add `%i[foo bar]` style words back to lexer

- Move corelib from `opal/core` to `opal/corelib`. This stops files in
    `core/` clashing with user files.


## [0.5.4] - 2013-11-20

- Reverted `RUBY_VERSION` to `1.9.3`. Opal `0.6.0` will be the first release
    for `2.0.0`.


## [0.5.3] - 2013-11-12

- Opal now targets ruby 2.0.0

- Named function inside class body now generates with `$` prefix, e.g.
    `$MyClass`. This makes it easier to wrap/bridge native functions.

- Support Array subclasses

- Various fixes to `String`, `Kernel` and other core classes

- Fix `Method#call` to use correct receiver

- Fix `Module#define_method` to call `#to_proc` on explicit argument

- Fix `super()` dispatches on class methods

- Support `yield()` calls from inside a block (inside a method)

- Cleanup string parsing inside lexer

- Cleanup parser/lexer to use `t` and `k` prefixes for all tokens


## [0.5.2] - 2013-11-11

- Include native into corelib for 0.5.x


## [0.5.1] - 2013-11-10

- Move all corelib under `core/` directory to prevent filename clashes with
    `require`

- Move `native.rb` into stdlib - must now be explicitly required

- Implement `BasicObject#__id__`

- Cleanup and fix various `Enumerable` methods


## [0.5.0] - 2013-11-03

- WIP: https://gist.github.com/elia/7747460


## [0.4.2] - 2013-07-03

- Added `Kernel#rand`. (fntzr)

- Restored the `bin/opal` executable in gemspec.

- Now `.valueOf()` is used in `#to_n` of Boolean, Numeric, Regexp and String
    to return the naked JavaScript value instead of a wrapping object.

- Parser now wraps or-ops in paranthesis to stop variable order from
    leaking out when minified by uglify. We now have code in this
    format: `(((tmp = lhs) !== false || !==nil) ? tmp : rhs)`.


## [0.4.1] - 2013-06-16

- Move sprockets logic out to external opal-sprockets gem. That now
    handles the compiling and loading of opal files in sprockets.


## [0.4.0] - 2013-06-15

- Added fragments to parser. All parser methods now generate one or
    more Fragments which store the original sexp. This allows us to
    enumerate over them after parsing to map generated lines back to
    original line numbers.

- Reverted `null` for `nil`. Too buggy at this time.

- Add Opal::SprocketsParser as Parser subclass for handling parsing
    for sprockets environment. This subclass handles require statements
    and stores them for sprockets to use.

- Add :irb option to parser to keep top level lvars stored inside
    opal runtime so that an irb session can be persisted and maintain
    access to local variables.

- Add Opal::Environment#use_gem() helper to add a gem to opals load
    path.

- Stop pre-setting ivars to `nil`. This is no longer needed as `nil`
    is now `null` or `undefined`.

- Use `null` as `nil` in opal. This allows us to send methods to
    `null` and `undefined`, and both act as `nil`. This makes opal a
    much better javascript citizen. **REVERTED**

- Add Enumerable#none? with specs.

- Add Opal.block_send() runtime helper for sending methods to an
    object which uses a block.

- Remove \_klass variable for denoting ruby classes, and use
    constructor instead. constructor is a javascript property used for
    the same purpose, and this makes opal fit in as a better js citizen.

- Add Class.bridge\_class method to bridge a native constructor into an
    opal class which will set it up with all methods from Object, as
    well as giving it a scope and name.

- Added native #[]= and #to_h methods, for setting properties and
    converting to a hash respectivaly.

- Fix bug where '::' was parsed as :colon2 instead of :colon3 when in
    an args scope. Fixes #213

- Remove lots of properties added to opal classes. This makes normal
    js constructors a lot closer to opal classes, making is easier to
    treat js classes as opal classes.

- Merge Hash.from_native into Hash.new


## [0.3.44] - 2013-05-31

- Cleanup runtime, and remove various flags and functions from opal
    objects and classes (moving them to runtime methods).

- Remove some activesupport methods into external lib.

- Add/fix lots of String methods, with specs.

- Add more methods to MatchData class.

- Implement $' and $` variables.

- Opal can now call methods on all native objects, via method missing
    dispatcher.

- Add Opal::Environment as custom sprockets subclass which adds all
    opal load paths automatically.


## [0.3.43] - 2013-05-02

- Stop inlining respond_to? inside the parser. This now fully respects
    an object overriding respond_to?.

- Expose `Opal.eval()` function when parser is loaded for parsing
    and running strings of ruby code.

- Add erb to corelib (as well as compiler to gem lib). ERB files with
    .opalerb extension will automatically be compiled into Template
    constant.

- Added some examples into examples/ dir.

- Add Opal.send() javascript function for sending methods to ruby
    objects.

- Native class for wrapping and interacting with native objects and
    function calls.

- Add local_storage to stdlib as a basic wrapper around localStorage.

- Make method_missing more performant by reusing same dispatch function
    instead of reallocating one for each run.

- Fix Kernel#format to work in firefox. String.prototype.replace() had
    different semantics for empty matching groups which was breaking
    Kernel#format.


## [0.3.42] - 2013-03-21

- Fix/add lots of language specs.

- Seperate sprockets support out to opal-sprockets gem.

- Support %r[foo] style regexps.

- Use mspec to run specs on corelib and runtime. Rubyspecs are now
    used, where possible to be as compliant as possible.


## [0.3.41] - 2013-02-26

- Remove bin/opal - no longer required for building sources.

- Depreceate Opal::Environment. The Opal::Server class provides a better
    method of using the opal load paths. Opal.paths still stores a list of
    load paths for generic sprockets based apps to use.


## [0.3.40] - 2013-02-23

- Add Opal::Server as an easy to configure rack server for testing and
    running Opal based apps.

- Added optional arity check mode for parser. When turned on, every method
    will have code which checks the argument arity. Off by default.

- Exception subclasses now relfect their name in webkit/firefox debuggers
    to show both their class name and message.

- Add Class#const_set. Trying to access undefined constants by a literal
    constant will now also raise a NameError.


## [0.3.39] - 2013-02-20

- Fix bug where methods defined on a parent class after subclass was defined
    would not given subclass access to method. Subclasses are now also tracked
    by superclass, by a private '_inherited' property.

- Fix bug where classes defined by `Class.new` did not have a constant scope.

- Move Date out of opal.rb loading, as it is part of stdlib not corelib.

- Fix for defining methods inside metaclass, or singleton_class scopes.


## [0.3.38] - 2013-02-13

- Add Native module used for wrapping objects to forward calls as native calls.

- Support method_missing for all objects. Feature can be enabled/disabled on `Opal::Processor`.

- Hash can now use any ruby object as a key.

- Move to Sprockets based building via `Opal::Processor`.




[0.10.0]: https://github.com/opal/opal/compare/v0.9.2...HEAD
[0.9.2]: https://github.com/opal/opal/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/opal/opal/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/opal/opal/compare/v0.8.1...v0.9.0
[0.8.1]: https://github.com/opal/opal/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/opal/opal/compare/v0.7.2...v0.8.0
[0.7.2]: https://github.com/opal/opal/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/opal/opal/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/opal/opal/compare/v0.6.3...v0.7.0
[0.6.3]: https://github.com/opal/opal/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/opal/opal/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/opal/opal/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/opal/opal/compare/v0.5.5...v0.6.0
[0.5.5]: https://github.com/opal/opal/compare/v0.5.4...v0.5.5
[0.5.4]: https://github.com/opal/opal/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/opal/opal/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/opal/opal/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/opal/opal/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/opal/opal/compare/v0.4.4...v0.5.0
[0.4.4]: https://github.com/opal/opal/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/opal/opal/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/opal/opal/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/opal/opal/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/opal/opal/compare/v0.3.8...v0.4.0
[0.3.8]: https://github.com/opal/opal/compare/v0.3.7...v0.3.8
[0.3.7]: https://github.com/opal/opal/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/opal/opal/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/opal/opal/compare/v0.3.44...v0.3.5
[0.3.44]: https://github.com/opal/opal/compare/v0.3.43...v0.3.44
[0.3.43]: https://github.com/opal/opal/compare/v0.3.42...v0.3.43
[0.3.42]: https://github.com/opal/opal/compare/v0.3.41...v0.3.42
[0.3.41]: https://github.com/opal/opal/compare/v0.3.40...v0.3.41
[0.3.40]: https://github.com/opal/opal/compare/v0.3.4...v0.3.40
[0.3.4]: https://github.com/opal/opal/compare/v0.3.39...v0.3.4
[0.3.39]: https://github.com/opal/opal/compare/v0.3.38...v0.3.39
[0.3.38]: https://github.com/opal/opal/compare/v0.3.37...v0.3.38
[0.3.37]: https://github.com/opal/opal/compare/v0.3.36...v0.3.37
[0.3.36]: https://github.com/opal/opal/compare/v0.3.35...v0.3.36
[0.3.35]: https://github.com/opal/opal/compare/v0.3.34...v0.3.35
[0.3.34]: https://github.com/opal/opal/compare/v0.3.33...v0.3.34
[0.3.33]: https://github.com/opal/opal/compare/v0.3.32...v0.3.33
[0.3.32]: https://github.com/opal/opal/compare/v0.3.31...v0.3.32
[0.3.31]: https://github.com/opal/opal/compare/v0.3.30...v0.3.31
[0.3.30]: https://github.com/opal/opal/compare/v0.3.3...v0.3.30
[0.3.3]: https://github.com/opal/opal/compare/v0.3.29...v0.3.3
[0.3.29]: https://github.com/opal/opal/compare/v0.3.21...v0.3.29
[0.3.21]: https://github.com/opal/opal/compare/v0.3.20...v0.3.21
[0.3.20]: https://github.com/opal/opal/compare/v0.3.2...v0.3.20
[0.3.2]: https://github.com/opal/opal/compare/v0.3.19...v0.3.2
[0.3.19]: https://github.com/opal/opal/compare/v0.3.18...v0.3.19
[0.3.18]: https://github.com/opal/opal/compare/v0.3.17...v0.3.18
[0.3.17]: https://github.com/opal/opal/compare/v0.3.11...v0.3.17
[0.3.11]: https://github.com/opal/opal/compare/v0.3.10...v0.3.11
[0.3.10]: https://github.com/opal/opal/compare/v0.3.1...v0.3.10
[0.3.1]: https://github.com/opal/opal/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/opal/opal/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/opal/opal/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/opal/opal/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/opal/opal/compare/v0.0.6...v0.1.0
[0.0.6]: https://github.com/opal/opal/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/opal/opal/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/opal/opal/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/opal/opal/compare/v0.0.2...v0.0.3
