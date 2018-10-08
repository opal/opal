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




## [1.0.0] - Unreleased

### Added

- Added `Date#to_n` that returns the JavaScript Date object (in native.rb). (#1779)
- Added `Array#pack` (supports only `C, S, L, Q, c, s, l, q, A, a` formats). (#1723)
- Added `String#unpack` (supports only `C, S, L, Q, S>, L>, Q>, c, s, l, q, n, N, v, V, U, w, A, a, Z, B, b, H, h, u, M, m` formats). (#1723)
- Added `File#symlink?` for Node.js. (#1725)
- Added `Dir#glob` for Node.js (does not support flags). (#1727)
- Added support for a static folder in the "server" CLI runner via the `OPAL_CLI_RUNNERS_SERVER_STATIC_FOLDER` env var
- Added the CLI option `--runner-options` that allows passing arbitrary options to the selected runner, currently the only runner making use of them is `server` accepting `port` and `static_folder`
- Added a short helper to navigate constants manually: E.g. `Opal.$$.Regexp.$$.IGNORECASE` (see docs for "Compiled Ruby")
- Added initial support for OpenURI module (using XMLHttpRequest on browser and [xmlhttprequest](https://www.npmjs.com/package/xmlhttprequest) on Node). (#1735)
- Added `String#prepend` to the list of unsupported methods (because String are immutable in JavaScript)
- Added 2.4/2.5 methods (#1757):
    * `Array#prepend`
    * `Array#append`
    * `Array#max`
    * `Array#min`
    * `Complex#finite?`
    * `Complex#infinite?`
    * `Complex#infinite?`
    * `Date#to_time`
    * `Hash#slice`
    * `Hash#transform_keys`
    * `Hash#transform_keys!`
    * `Numeric#finite?`
    * `Numeric#infinite?`
    * `Numeric#infinite?`
    * `Integer#allbits?`
    * `Integer#anybits?`
    * `Integer#digits`
    * `Integer#nobits?`
    * `Integer#pow`
    * `Integer#remainder`
    * `Integer.sqrt`
    * `Random.urandom`
    * `String#delete_prefix`
    * `String#delete_suffix`
    * `String#casecmp?`
    * `Kernel#yield_self`
    * `String#unpack1`
- Added support of the `pattern` argument for `Enumerable#all?`, `Enumerable#any?`, `Enumerable#none?`. (#1757)
- Added `ndigits` option support to `Number#floor`, `Number#ceil`, `Number#truncate`. (#1757)
- Added `key` and `receiver` attributes to the `KeyError`. (#1757)
- Extended `Struct.new` to support `keyword_init` option. (#1757)
- Added a new `Opal::Config.missing_require_severity` option and relative `--missing-require` CLI flag. This option will command how the builder will behave when a required file is missing. Previously the behavior was undefined and partly controlled by `dynamic_require_severity`. Not to be confused with the runtime config option `Opal.config.missing_require_severity;` which controls the runtime behavior.
- Added `Matrix` (along with the internal MRI utility `E2MM`)
- Use shorter helpers for constant lookups, `$$` for relative (nesting) lookups and `$$$` for absolute (qualified) lookups
- Add support for the Mersenne Twister random generator, the same used by CRuby/MRI (#657 & #1891)


### Changed

- **BREAKING** The dot (`.`) character is no longer replaced with [\s\S] in a multiline regexp passed to Regexp#match and Regexp#match?
  * You're advised to always use [\s\S] instead of . in a multiline regexp, which is portable between Ruby and JavaScript
- The internal API for CLI runners has changed, now it's just a callable object
- The `--map` CLI option now works only in conjunction with `--compile` (or `--runner compiler`)
- The `node` CLI runner now adds its `NODE_PATH` entry instead of replacing the ENV var altogether
- Added `--disable-web-security` option flag to the Chrome headless runner to be able to do `XMLHttpRequest`
- Migrated parser to 2.5. Bump RUBY_VERSION to 2.5.0.
- Exceptions raised during the compilation now add to the backtrace the current location of the opal file if available (#1814).


### Deprecated

- The CLI `--server-port 1234` option is now deprecated in favor of using `--runner-options='{"port": 1234}'`
- Including `::Native` is now deprecated because it generates conflicts with core classes in constant lookups (both `Native::Object` and `Native::Array` exist). Instead `Native::Werapper` should be used.
- Using `node_require 'my_module'` to access the native `require()` function in Node.js is deprecated in favor of <code>\`require('my_module')\`</code> because static builders need to parse the call in order to function (#1886).


### Removed

- The `node` CLI runner no longer supports passing extra node options via the `NODE_OPT` env var, instead Node.js natively supports the `NODE_OPTIONS` env var.
- The gem "hike" is no longer an external dependency and is now an internal dependency available as `Opal::Hike`


### Fixed

- Fix handling of trailing semicolons and JavaScript returns inside x-strings, the behavior is now well defined and covered by proper specs (#1776)
- Fixed singleton method definition to return method name. (#1757)
- Allow passing number of months to `Date#next_month` and `Date#prev_month`. (#1757)
- Fixed `pattern` argument handling for `Enumerable#grep` and `Enumerable#grep_v`. (#1757)
- Raise `ArgumentError` instead of `TypeError` from `Numeric#step` when step is not a number. (#1757)
- At run-time `LoadError` wasn't being raised even with `Opal.config.missing_require_severity;` set to `'error'`.
- Fixed `Kernel#public_methods` to return instance methods if the argument is set to false.
- Fixed an issue in `String#gsub` that made it start an infinite loop when used recursively. (#1879)


<!-- generated-content-beyond-this-comment -->




## [0.11.3](https://github.com/opal/opal/compare/v0.11.2...v0.11.3) - 2018-08-28


### Fixed

- Fixed `Array#dup` when `method_missing` support was disabled




## [0.11.2](https://github.com/opal/opal/compare/v0.11.1...v0.11.2) - 2018-08-24


### Fixed

- Remove symlink that caused problems on Windows




## [0.11.1](https://github.com/opal/opal/compare/v0.11.0...v0.11.1) - 2018-07-17


### Added

- Added support for a static folder in the "server" CLI runner via the `OPAL_CLI_RUNNERS_SERVER_STATIC_FOLDER` env var
- Added ability to pass the port to the "server" CLI runner using the `OPAL_CLI_RUNNERS_SERVER_PORT` (explicit option passed via CLI is still working but deprecated)
- Added a new `Opal::Config.missing_require_severity` option and relative `--missing-require` CLI flag. This option will command how the builder will behave when a required file is missing. Previously the behavior was undefined and partly controlled by `dynamic_require_severity`. Not to be confused with the runtime config option `Opal.config.missing_require_severity;` which controls the runtime behavior.
- At run-time `LoadError` wasn't being raised even with `Opal.config.missing_require_severity;` set to `'error'`.




## [0.11.0](https://github.com/opal/opal/compare/v0.10.6...v0.11.0) - 2017-12-08


### Added

- Added support for complex (`0b1110i`) and rational (`0b1111r`) number literals. (#1487)
- Added 2.3.0 methods:
    * `Array#bsearch_index`
    * `Array#dig`
    * `Enumerable#chunk_while`
    * `Enumerable#grep_v`
    * `Enumerable#slice_after`
    * `Enumerable#slice_when`
    * `Hash#>`
    * `Hash#<`
    * `Hash#>=`
    * `Hash#>=`
    * `Hash#dig`
    * `Hash#fetch_values`
    * `Hash#to_proc`
    * `Struct#dig`
    * `Kernel#itself`
- Added safe navigator (`&.`) support. (#1532)
- Added Random class with seed support. The following methods were reworked to use it:
    * `Kernel.rand`
    * `Kernel.srand`
    * `Array#shuffle`
    * `Array#shuffle!`
    * `Array#sample`
- Added rudimental history support to `opal-repl`, just create the history file (`~/.opal-repl-history`) and it record the last 1000 lines
- Added `JS::Error` error class that can be used to catch any JS error.
- Added `Method#source_location` and `Method#comments`.
- Added a deprecation API that can be set to raise on deprecation with: `Opal.raise_on_deprecation = true`
- Added `Opal::SimpleServer` as the quickest way to get up and running with Opal: `rackup -ropal -ropal/simple_server -b 'Opal.append_path("app"); run Opal::SimpleServer.new'`
- Added `String#ascii_only?` (#1592)
- Added `StringScanner#matched_size` (#1595)
- Added `Hash#compare_by_identity` (#1657)


### Removed

- Dropped support for IE8 and below, and restricted Safari and Opera support to the last two versions
- Dropped support for PhantomJS as it was [abandoned](https://groups.google.com/forum/#!topic/phantomjs/9aI5d-LDuNE).


### Changed

- Removed self-written lexer/parser. Now uses parser/ast gems to convert source code to AST. (#1465)
- Migrated parser to 2.3. Bump RUBY_VERSION to 2.3.0.
- Changed to be 2.3 compliant:
    * `Enumerable#chunk` (to take only a a block)
    * `Enumerable#slice_before` (to raise proper argument errors)
    * `Number#positive?` (to return false for 0)
- Use meaningful names for temporary variables in compiled JavaScript (e.g. for `def foo` was `TMP_123`, now `TMP_foo_123`)
- Dynamic require severity now defaults to `:ignore` meaning that by default a `LoadError` will be raised at runtime instead of compile time.


### Deprecated

- `require 'opal/server` and `Opal::Server` are deprecated in favor of `require 'opal/sprockets/server'` and `Opal::Sprockets::Server` (now part of the opal-sprockets gem).


### Removed

- Removed `yaml` from stdlib, the older implementation was only available for NodeJS and not tested. Replace with `require 'nodejs/yaml'`
- Extracted sprockets support to `opal-sprockets` which should allow for wider support and less coupling (e.g. the `opal` gem will now be able to improve the compiler without worrying about `sprockets` updates). All the old behavior is preserved except for `Opal::Server` that has become `Opal::Sprockets::Server` (see Deprecated section above).


### Changed

- Strip Regexp flags that are unsupported by browsers (backport), previously they were ignored, lately most of them now raise an error for unknown flags.


### Fixed

- Newly compliant with the Ruby Spec Suite:
    * `Module#class_variables`
    * `Module#class_variable_get`
    * `Module#class_variable_set`
    * `Module#remove_class_variable`
    * `Module#include?`
    * `Numeric#step` (#1512)

- Improvements for Range class (#1486)
    * Moved private/tainted/untrusted specs to not supported
    * Conforming `Range#to_s` and `Range#inspect`
    * Starting `Range#bsearch` implementation
    * Simple `Range#step` implementation
    * Fixing `Range#min` for empty Ranges
    * Fixing `Range#last(n)` `Range#first(n)` and one edge case of `Range#each`
    * Fixing some `Range#step` issues on String ranges
    * Simple `Range#bsearch` implementation, passes about half the specs
    * Minor styling improvements. Fixed size of `Range#step`.
    * Compile complex ranges to "Range.new" so there will be a check for begin and end to be comparable.

- Fixed `defined?` for methods raising exceptions
- Fixed `Kernel#loop` (to catch `StopIteration` error)
- Fixed inheritance from the `Module` class.
- Fixed using `--preload` along with `--no-opal` for CLI
- Fixed `Integer("0")` raising `ArgumentError` instead of parsing as 0
- Fixed `JSON#parse` to raise `JSON::ParserError` for invalid input
- `Module#append_features` now detects cyclic includes
- `Process.clock_gettime(Process::CLOCK_MONOTONIC)` will now return true monotonic values or raise `Errno::EINVAL` if no monotonic clock is available
- Opal::Builder no longer always raises an error when a dependency isn't found and instead respects `dynamic_require_severity` value
- Fixed a constant reference to `Sprockets::FileNotFound` that previously pointed to `Opal::Sprockets` instead of `::Sprockets`.




## [0.10.6](https://github.com/opal/opal/compare/v0.10.5...v0.10.6) - 2018-06-21


### Changed

- Strip Regexp flags that are unsupported by browsers (backport), previously they were ignored, lately most of them now raise an error for unknown flags.


### Fixed

- Fixed a constant reference to `Sprockets::FileNotFound` that previously pointed to `Opal::Sprockets` instead of `::Sprockets`.




## [0.10.5](https://github.com/opal/opal/compare/v0.10.4...v0.10.5) - 2017-06-21


### Fixed

- Fix `Time#zone` for zones expressed numerically




## [0.10.4](https://github.com/opal/opal/compare/v0.10.3...v0.10.4) - 2017-05-06


### Changed

- Better `Opal::Config` options documentation and organization
- Always cache source-maps at build-time so they're available once enabled




## [0.10.3](https://github.com/opal/opal/compare/v0.10.2...v0.10.3) - 2016-10-31


### Fixed

- Fixed inheritance from the `Module` class (#1476)
- Fixed source map server with url-encoded paths
- Silence Sprockets 3.7 deprecations, full support for Sprockets 4 will be available in Opal 0.11
- Don't print the full stack trace with deprecation messages




## [0.10.2](https://github.com/opal/opal/compare/v0.10.1...v0.10.2) - 2016-09-09


### Changed

- Avoid special utf-8 chars in method names, now they start with `$$`




## [0.10.1](https://github.com/opal/opal/compare/v0.10.0...v0.10.1) - 2016-07-06


### Fixed

- Fixed `-L` option for compiling requires as modules (#1510)




## [0.10.0](https://github.com/opal/opal/compare/v0.9.4...v0.10.0) - 2016-07-04


### Added

- Pathname#relative_path_from
- Source maps now include method names
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
    * `Module#module_eval` with a string
- Add `-L` / `--library` option to compile only the code of the library (#1281)
- Implement `Kernel.open` method (#1218)
- Generate meaningful names for functions representing Ruby methods
- Implement `Pathname#join` and `Pathname#+` methods (#1301)
- Added support for `begin;rescue;else;end`.
- Implement `File.extname` method (#1219)
- Added support for keyword arguments as lambda parameters.
- Super works with define_method blocks
- Added support for kwsplats.
- Added support for squiggly heredoc.
- Implement `Method#parameters` and `Proc#parameters`.
- Implement `File.new("path").mtime`, `File.mtime("path")`, `File.stat("path").mtime`.
- if-conditions now support `null` and `undefined` as falsy values (#867)
- Implement IO.read method for Node.js (#1332)
- Implement IO.each_line method for Node.js (#1221)
- Generate `opal-builder.js` to ease the compilation of Ruby library from JavaScript (#1290)


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

- `Module#ancestors` and shared code like `====` and `is_a?` deal with singleton class modules better (#1449)
- `Class#to_s` now shows correct names for singleton classes
- `Pathname#absolute?` and `Pathname#relative?` now work properly
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
- Fixed docs for Compiled Ruby - Native section. Rename opal variable to win since window was causing error
- Fixed the `--map` option, now correclty outputs the sourcemap as json


### Removed

- Remove support for configuring Opal via `Opal::Processor`, the correct place is `Opal::Config`
- Remove `Opal.process` which used to be an alias to `Sprockets::Environment#[]`




## [0.9.4](https://github.com/opal/opal/compare/v0.9.3...v0.9.4) - 2016-06-20


### Fixed

- Rebuilt the gem with Rubygems 2.4.8 as building with 2.5.1+ would make the gem un-installable

- Removed all symlinks from `node_module` directories to avoid further issues building the gem




## [0.9.3](https://github.com/opal/opal/compare/v0.9.2...v0.9.3) - 2016-06-16


### Fixed

- `Hash#initialize` now accepts JS `null` as well as `undefined`, restoring its 0.8 behavior




## [0.9.2](https://github.com/opal/opal/compare/v0.9.1...v0.9.2) - 2016-01-09


### Fixed

- Rebuilt the gem with Ruby 2.2 as building with 2.3 would make the gem un-installable




## [0.9.1](https://github.com/opal/opal/compare/v0.9.0...v0.9.1) - 2016-01-09


### Fixed

- Backport rack2 compatibility (#1260)
- Fixed issue with JS nil return paths being treated as true (#1274)
- Fix using more than two `rescue` in sequence (#1269)




## [0.9.0](https://github.com/opal/opal/compare/v0.8.1...v0.9.0) - 2015-12-20


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




## [0.8.1](https://github.com/opal/opal/compare/v0.8.0...v0.8.1) - 2015-10-12


### Removed

- Use official Sprockets processor cache keys API:
    The old cache key hack has been removed.
    Add `Opal::Processor.cache_key` and `Opal::Processor.reset_cache_key!` to
    reset it as it’s cached but should change whenever `Opal::Config` changes.

### Fixed

- Fix an issue for which a Pathname was passed instead of a String to Sprockets.




## [0.8.0](https://github.com/opal/opal/compare/v0.7.2...v0.8.0) - 2015-07-16


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




## [0.7.2](https://github.com/opal/opal/compare/v0.7.1...v0.7.2) - 2015-04-23


- Remove Sprockets 3.0 support (focus moved to upcoming 0.8)
- Fix version number consistency.




## [0.7.1](https://github.com/opal/opal/compare/v0.7.0...v0.7.1) - 2015-02-13


- CLI options `-d` and `-v` now set respectively `$DEBUG` and `$VERBOSE`
- Fixed a bug that would make the `-v` CLI option wait for STDIN input
- Add the `-E` / `--no-exit` CLI option to skip implicit `Kernel#exit` call
- Now the CLI implicitly calls `Kernel#exit` at the end of the script, thus making `at_exit` blocks be respected.




## [0.7.0](https://github.com/opal/opal/compare/v0.6.3...v0.7.0) - 2015-02-01


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




## [0.6.3](https://github.com/opal/opal/compare/v0.6.2...v0.6.3) - 2014-11-23


- Fix `Regexp.escape` internal regexp




## [0.6.2](https://github.com/opal/opal/compare/v0.6.1...v0.6.2) - 2014-04-24


- Added Range#size

- `opal` executable now reads STDIN when no file or `-e` are passed

- `opal` executable doesn't exit after showing version on `-v` if other options are passed

- (Internal) improved the mspec runner




## [0.6.1](https://github.com/opal/opal/compare/v0.6.0...v0.6.1) - 2014-04-14


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




## [0.6.0](https://github.com/opal/opal/compare/v0.5.5...v0.6.0) - 2014-03-05


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




## [0.5.5](https://github.com/opal/opal/compare/v0.5.4...v0.5.5) - 2013-11-25


- Fix regression: add `%i[foo bar]` style words back to lexer

- Move corelib from `opal/core` to `opal/corelib`. This stops files in `core/` clashing with user files.




## [0.5.4](https://github.com/opal/opal/compare/v0.5.3...v0.5.4) - 2013-11-20


- Reverted `RUBY_VERSION` to `1.9.3`. Opal `0.6.0` will be the first release for `2.0.0`.




## [0.5.3](https://github.com/opal/opal/compare/v0.5.2...v0.5.3) - 2013-11-20


- Opal now targets ruby 2.0.0

- Named function inside class body now generates with `$` prefix, e.g. `$MyClass`. This makes it easier to wrap/bridge native functions.

- Support Array subclasses

- Various fixes to `String`, `Kernel` and other core classes

- Fix `Method#call` to use correct receiver

- Fix `Module#define_method` to call `#to_proc` on explicit argument

- Fix `super()` dispatches on class methods

- Support `yield()` calls from inside a block (inside a method)

- Cleanup string parsing inside lexer

- Cleanup parser/lexer to use `t` and `k` prefixes for all tokens




## [0.5.2](https://github.com/opal/opal/compare/v0.5.1...v0.5.2) - 2013-11-11


- Include native into corelib for 0.5.x




## [0.5.1](https://github.com/opal/opal/compare/v0.5.0...v0.5.1) - 2013-11-10


- Move all corelib under `core/` directory to prevent filename clashes with `require`

- Move `native.rb` into stdlib - must now be explicitly required

- Implement `BasicObject#__id__`

- Cleanup and fix various `Enumerable` methods




## [0.5.0](https://github.com/opal/opal/compare/v0.4.4...v0.5.0) - 2013-11-03


- Optimized_operators is no longer a compiler option
- Replace `Opal.bridge_class()` with <code>class Foo < \`bar\`</code> syntax
- Expose `Opal.bridge_class()` for bridging native prototypes
- Source maps improvements
- Massive Rubyspec cleanup + passing specs
- Massive Corelib/Stdlib cleanup + fixes
- Massive internal cleanup + fixes

*See the [full diff](https://github.com/opal/opal/compare/v0.4.4...v0.5.0) for more details (almost 800 commits)*




## [0.4.4](https://github.com/opal/opal/compare/v0.4.3...v0.4.4) - 2013-08-13


- Remove native object method calls
- Add Struct class
- Add method stubs as method_missing option, stubs enabled by default
- Native is now used to wrap native objects directly
- Fix Hash.new and Hash.allocate for subclasses
- Generate sourcemaps from fragments
- Allow blocks to be passed to zsuper (no args) calls
- Fix yield when given 1 or multiple arguments for block destructuring




## [0.4.3](https://github.com/opal/opal/compare/v0.4.2...v0.4.3) - 2013-07-24


- Re-implement class system. Classes are now real objects instead of converted Procs. This allows classes to properly inherit methods from each other.
- Fix exception hierarchy. Not all standard exception classes were subclassing the correct parent classes, this is now fixed.
- Move ERB into stdlib. The erb compiler/parser has also been moved into lib/
- Opal::Builder class. A simple port/clone of sprockets general building. This allows us to build projects similar to the way opal-sprockets does.
- Move json.rb to stdlib.




## [0.4.2](https://github.com/opal/opal/compare/v0.4.1...v0.4.2) - 2013-07-03


- Added `Kernel#rand`. (fntzr)

- Restored the `bin/opal` executable in gemspec.

- Now `.valueOf()` is used in `#to_n` of Boolean, Numeric, Regexp and String
    to return the naked JavaScript value instead of a wrapping object.

- Parser now wraps or-ops in paranthesis to stop variable order from
    leaking out when minified by uglify. We now have code in this
    format: `(((tmp = lhs) !== false || !==nil) ? tmp : rhs)`.




## [0.4.1](https://github.com/opal/opal/compare/v0.4.0...v0.4.1) - 2013-06-16


- Move sprockets logic out to external opal-sprockets gem. That now
    handles the compiling and loading of opal files in sprockets.




## [0.4.0](https://github.com/opal/opal/compare/v0.3.44...v0.4.0) - 2013-06-15


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




## [0.3.44](https://github.com/opal/opal/compare/v0.3.43...v0.3.44) - 2013-05-31


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




## [0.3.43](https://github.com/opal/opal/compare/v0.3.42...v0.3.43) - 2013-05-02


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




## [0.3.42](https://github.com/opal/opal/compare/v0.3.41...v0.3.42) - 2013-03-21


- Fix/add lots of language specs.

- Seperate sprockets support out to opal-sprockets gem.

- Support %r[foo] style regexps.

- Use mspec to run specs on corelib and runtime. Rubyspecs are now
    used, where possible to be as compliant as possible.




## [0.3.41](https://github.com/opal/opal/compare/v0.3.40...v0.3.41) - 2013-02-26


- Remove bin/opal - no longer required for building sources.

- Depreceate Opal::Environment. The Opal::Server class provides a better
    method of using the opal load paths. Opal.paths still stores a list of
    load paths for generic sprockets based apps to use.




## [0.3.40](https://github.com/opal/opal/compare/v0.3.39...v0.3.40) - 2013-02-23


- Add Opal::Server as an easy to configure rack server for testing and
    running Opal based apps.

- Added optional arity check mode for parser. When turned on, every method
    will have code which checks the argument arity. Off by default.

- Exception subclasses now relfect their name in webkit/firefox debuggers
    to show both their class name and message.

- Add Class#const_set. Trying to access undefined constants by a literal
    constant will now also raise a NameError.




## [0.3.39](https://github.com/opal/opal/compare/v0.3.38...v0.3.39) - 2013-02-20


- Fix bug where methods defined on a parent class after subclass was defined
    would not given subclass access to method. Subclasses are now also tracked
    by superclass, by a private '_inherited' property.

- Fix bug where classes defined by `Class.new` did not have a constant scope.

- Move Date out of opal.rb loading, as it is part of stdlib not corelib.

- Fix for defining methods inside metaclass, or singleton_class scopes.




## [0.3.38](https://github.com/opal/opal/compare/v0.3.37...v0.3.38) - 2013-02-19


- Add Native module used for wrapping objects to forward calls as native calls.

- Support method_missing for all objects. Feature can be enabled/disabled on `Opal::Processor`.

- Hash can now use any ruby object as a key.

- Move to Sprockets based building via `Opal::Processor`.




## [0.3.37](https://github.com/opal/opal/compare/v0.3.36...v0.3.37) - 2013-02-15


- Extract the JavaScript runtime to `opal/runtime.js`
- Add core `template.rb` for the basis of template libraries for Opal




## [0.3.36](https://github.com/opal/opal/compare/v0.3.35...v0.3.36) - 2013-02-08


- Use Ruby `require` directive inside Sprockets
- Depreceate `Opal.process` in favour of `Opal::Environment`




## [0.3.35](https://github.com/opal/opal/compare/v0.3.34...v0.3.35) - 2013-02-05


- Internal cleanup




## [0.3.34](https://github.com/opal/opal/compare/v0.3.33...v0.3.34) - 2013-02-05


- Fix bug where camelcased lvars could parse as constants
- Add `Array#shuffle`
- Migrate to Sprockets-based building
- Move ERB to separate gem




## [0.3.33](https://github.com/opal/opal/compare/000000...v0.3.33) - 2013-01-18


- Implement attr_reader/writer/accessor for dynamic uses
- Hash internals update




