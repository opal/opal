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





## [1.4.1](https://github.com/opal/opal/compare/v1.4.0...v1.4.1) - 2022-01-12


### Changed

- PromiseV2 is now declared a stable interface!

### Fixed

- Args named with JS reserved words weren't always renamed when _zsuper_ was involved ([#2385](https://github.com/opal/opal/pull/2385))

<!--
### Added
### Removed
### Deprecated
### Internal
-->




## [1.4.0](https://github.com/opal/opal/compare/v1.3.2...v1.4.0) - 2021-12-24


### Added

- Implement `chomp:` option for `String#each_line` and `#lines` ([#2355](https://github.com/opal/opal/pull/2355))
- Ruby 3.1 support and some older Ruby features we missed ([#2347](https://github.com/opal/opal/pull/2347))
  - Use parser in 3.1 mode to support new language-level features like hashes/kwargs value omission, the pin operator for pattern matching
  - `Array#intersect?`
  - `String#strip` and `String#lstrip` to also remove NUL bytes
  - `Integer.try_convert`
  - `public`, `private`, `protected`, `module_function` now return their arguments
  - `Class#descendants`, `Class#subclasses`
  - (<=1.8) `Kernel#local_variables`
  - (<=2.3) Set local variables for regexp named captures (`/(?<b>a)/ =~ 'a'` => `b = 'a'`)
  - Remove deprecated `NIL`, `TRUE`, `FALSE` constants
  - `String#unpack` and `String#unpack1` to support an `offset:` kwarg
  - `MatchData#match`, `MatchData#match_length`
  - Enumerable modernization
    - `Enumerable#tally` to support an optional hash accumulator
    - `Enumerable#each_{cons,slice}` to return self
    - `Enumerable#compact`
  - `Refinement` becomes its own class now
  - `Struct#keyword_init?`
  - (pre-3.1) Large Enumerator rework
    - Introduce `Enumerator::ArithmeticSequence`
    - Introduce `Enumerator::Chain`
    - Introduce `Enumerator#+` to create `Enumerator::Chain`s
    - `Enumerator#{rewind,peek,peek_values,next,next_values}`
    - Improve corelib support for beginless/endless ranges and `ArithmeticSequences`
      - `String#[]`, `Array#[]`, `Array#[]=`, `Array#fill`, `Array#values_at`
    - `Range#step` and `Numeric#step` return an `ArithmeticSequence` when `Numeric` values are in play
    - Introduce `Range#%`
    - `Enumerator::Yielder#to_proc`
    - Fix #2367
  - (2.7) `UnboundMethod#bind_call`
  - (Opal) `{Kernel,BasicObject}#{inspect,p,pp,method_missing}` may work with JS native values now, also they now correctly report cycles
  - `Enumerable#sum` uses Kahan's summation algorithm to reduce error with floating point values
  - `File.dirname` supports a new `level` argument
- Vendor in `optparse` and `shellwords` ([#2326](https://github.com/opal/opal/pull/2326))
- Preliminary support for compiling the whole `bin/opal` with Opal ([#2326](https://github.com/opal/opal/pull/2326))

### Fixed

- Fix coertion for `Array#drop` ([#2371](https://github.com/opal/opal/pull/2371))
- Fix coertion for `File.absolute_path` ([#2372](https://github.com/opal/opal/pull/2372))
- Fix some `IO#puts` edge cases (no args, empty array, nested array, …) ([#2372](https://github.com/opal/opal/pull/2372))
- Preserve UNC path prefix on File.join ([#2366](https://github.com/opal/opal/pull/2366))
- Methods on `Kernel`, `BasicObject`, `Boolean` will never return boxed values anymore ([#2293](https://github.com/opal/opal/pull/2293))
  - `false.tap{}` will now correctly return a JS value of `false`, not `Object(false)`
- opal-parser doesn't break on `<<~END` strings anymore ([#2364](https://github.com/opal/opal/pull/2364))
- Fix error reporting at the early stage of loading ([#2326](https://github.com/opal/opal/pull/2326))

### Changed

- Various outputted code size optimizations - 19% improvement for minified unmangled AsciiDoctor bundle - see: https://opalrb.com/blog/2021/11/24/optimizing-opal-output-for-size/ ([#2356](https://github.com/opal/opal/pull/2356))
- Second round of code size optimizations - 3% improvement for AsciiDoctor bundle on top of the first round - 23% total - see: https://github.com/opal/opal/pull/2365/commits ([#2365](https://github.com/opal/opal/pull/2365))
  - The calls to `==`, `!=` and `===` changed their semantics slightly: it's impossible to monkey patch those calls for `String` and `Number`, but on other classes they can now return `nil` and it will be handled correctly
  - The calls to `!` changed their semantics slightly: it's impossible to monkey patch this call for `Boolean` or `NilClass`.
- Refactored the structure of the internal `stdlib/nodejs` folder ([#2374](https://github.com/opal/opal/pull/2374))
  - Added `nodejs/base` with just I/O, exit, and ARGV management
  - Moved `Process::Status` to corelib
  - Fixed requires to be more robust

### Removed

- Removed `nodejs/irb` from stdlib as it's been broken for some time ([#2374](https://github.com/opal/opal/pull/2374))
- Removed `Kernel#node_require` from `nodejs/kernel` as it's been deprecated for a long time ([#2374](https://github.com/opal/opal/pull/2374))

<!--
### Deprecated
### Internal
-->




## [1.3.2](https://github.com/opal/opal/compare/v1.3.1...v1.3.2) - 2021-11-10


### Fixed

- Update documentation ([#2350](https://github.com/opal/opal/pull/2350))
- Fix `IO#gets` getting an extra char under some circumstances ([#2349](https://github.com/opal/opal/pull/2349))
- Raise a `TypeError` instead of `UndefinedMethod` if not a string is passed to `__send__` ([#2346](https://github.com/opal/opal/pull/2346))
- Do not modify `$~` when calling `String#scan` from internal methods ([#2353](https://github.com/opal/opal/pull/2353))
- Stop interpreting falsey values as a missing constant in `Module#const_get` ([#2354](https://github.com/opal/opal/pull/2354))




## [1.3.1](https://github.com/opal/opal/compare/v1.3.0...v1.3.1) - 2021-11-03


### Fixed

- Fix REPL if bundler environment isn't set ([#2338](https://github.com/opal/opal/pull/2338))
- Fix Chrome runner if bundler environment isn't set and make it work on other Unixes ([#2339](https://github.com/opal/opal/pull/2339))
- `Proc#binding` to return a binding if `Binding` is defined (#2341, #2340)
- `Array#zip` to correctly `yield` (#2342, #1611)
- `String#scan` to correctly `yield` (#2342, #1660)




## [1.3.0](https://github.com/opal/opal/compare/v1.2.0...v1.3.0) - 2021-10-27


### Added

- Add support for `retry` ([#2264](https://github.com/opal/opal/pull/2264))
- Modernize Exceptions ([#2264](https://github.com/opal/opal/pull/2264))
  - Add `#cause`, `#backtrace_locations`, `#full_message` to `Exception`
  - Normalize backtraces across platforms
  - Add `Thread::Backtrace::Location`
  - Output Exception#full_message on uncaught exceptions ([#2269](https://github.com/opal/opal/pull/2269))
- TracePoint `:class` support ([#2049](https://github.com/opal/opal/pull/2049))
- Implement the Flip-Flop operators ([#2261](https://github.com/opal/opal/pull/2261))
- Add `JS[]` to access properties on the global object ([#2259](https://github.com/opal/opal/pull/2259))
- Add `ENV.fetch` to the Nodejs implementation of `ENV` ([#2259](https://github.com/opal/opal/pull/2259))
- Opal::Cache, an optional compiler cache (enabled by default) (#2242, #2278, #2329)
- Alias for gvars, alias on main ([#2270](https://github.com/opal/opal/pull/2270))
- Support for GJS (GNOME's JavaScript runtime) runner ([#2280](https://github.com/opal/opal/pull/2280))
- Scope variables support for `eval()` ([#2256](https://github.com/opal/opal/pull/2256))
- Add support for `Kernel#binding` ([#2256](https://github.com/opal/opal/pull/2256))
- A (mostly) correct support for refinements ([#2256](https://github.com/opal/opal/pull/2256))
- Add support for ECMAScript modules with an `--esm` CLI option ([#2286](https://github.com/opal/opal/pull/2286))
- Implement `Regexp#names` and add named captures support ([#2272](https://github.com/opal/opal/pull/2272))
- REPL improvements: ([#2285](https://github.com/opal/opal/pull/2285))
  - Colored output & history support
  - `ls` to show available constants and variable
- Add `Method#===` as an alias to `Method#call`, works the same as `Proc#===` ([#2305](https://github.com/opal/opal/pull/2305))
- Add `IO#gets` and `IO#read_proc` along with other supporting methods ([#2309](https://github.com/opal/opal/pull/2309))
  - Support `#gets` on most platforms, including browsers (via `prompt`)
  - Move the REPL to a `--repl` CLI option of the main executable
  - Completely refactor IO, now supporting methods like `#each_line` throughout the entire IO chain
  - Add a runner for MiniRacer (as `miniracer`)
  - Support Windows on the Chrome runner
  - Support Windows on the REPL
  - Platforms an IO implementations should either set `IO#read_proc` or overwrite `IO#sysread`
- [experimental] Add support for JavaScript async/await ([#2221](https://github.com/opal/opal/pull/2221))
  - Enable the feature by adding a magic comment: `# await: true`
  - The magic comment can be also used to mark specific method patterns to be awaited
    (e.g. `# await: *_await, sleep` will make any method ending in `_await` or named `sleep` to be awaited)
  - Add `Kernel#__await__` as a bridge to the `await` keyword (inspired by CoffeeScript await support)
  - Require `opal/await` to get additional support
  - Read more on the newly added documentation page
- Better interoperability between legacy Promise (v1) and native Promise (v2) ([#2221](https://github.com/opal/opal/pull/2221))
  - Add `PromiseV1` as an alias to the original (legacy) Promise class
  - Add `#to_v1` and `#to_v2` to both classes
  - `Promise#to_n` will convert it to a native Promise (v2)
- Add `Opal::Config.esm` to enable/disable ES modules ([#2316](https://github.com/opal/opal/pull/2316))
  - If Config.esm is enabled, SimpleServer does type="module"
  - Add new rack-esm example
- Add a QuickJS (https://bellard.org/quickjs/) runner ([#2331](https://github.com/opal/opal/pull/2331))
- Add `IO#fileno`, `Method#curry`, `Buffer#to_s`, `Pathname.pwd` ([#2332](https://github.com/opal/opal/pull/2332))
- Add NodeJS support for `ARGF`, `ENV.{inspect,to_h,to_hash,merge}`, `File.{delete,unlink}`, `Kernel#system`, <code>Kernel#\`</code>, `Process::Status` ([#2332](https://github.com/opal/opal/pull/2332))
- Introduce `__dir__` support ([#2323](https://github.com/opal/opal/pull/2323))
- Full autoload support ([#2323](https://github.com/opal/opal/pull/2323))
  - Now compatible with `opal-zeitwerk` and `isomorfeus`
  - Allow toplevel autoloads
  - Allow dynamic autoloads (e.g. can be hooked to fetch a URL upon autoload with a custom loader)
  - Allow overwriting `require` (e.g. like rubygems does)
  - Allow autoloading trees with `require_tree "./foo", autoload: true`
  - Add Module#autoload?
- Autoload parts of the corelib ([#2323](https://github.com/opal/opal/pull/2323))

### Fixed

- Fixed multiple line `Regexp` literal to not generate invalid syntax as JavaScript ([#1616](https://github.com/opal/opal/pull/1616))
- Fix `Kernel#{throw,catch}` along with `UncaughtThrowError` ([#2264](https://github.com/opal/opal/pull/2264))
- Update source-map-support to fix an off-by-one error ([#2264](https://github.com/opal/opal/pull/2264))
- Source map: lines should start from 1, not 0 ([#2273](https://github.com/opal/opal/pull/2273))
- Allow for multiple underscored args with the same name in strict mode ([#2292](https://github.com/opal/opal/pull/2292))
- Show instance variables in `Kernel#inspect` ([#2285](https://github.com/opal/opal/pull/2285))
- `0.digits` was returning an empty array in strict mode ([#2301](https://github.com/opal/opal/pull/2301))
- Non Integer numbers were responding to `#digits` ([#2301](https://github.com/opal/opal/pull/2301))
- Correctly delete hash members when dealing with boxed strings ([#2306](https://github.com/opal/opal/pull/2306))
- Escape string components in interpolated strings (`dstrs`) correctly ([#2308](https://github.com/opal/opal/pull/2308))
- Don't try to return the JS `debugger` statement, just return `nil` ([#2307](https://github.com/opal/opal/pull/2307))
- Retain the `-` while stringifying `-0.0` ([#2304](https://github.com/opal/opal/pull/2304))
- Fix super support for rest args and re-assignments with implicit arguments ([#2315](https://github.com/opal/opal/pull/2315))
- Fix calling `Regexp#last_match` when `$~` is nil ([#2328](https://github.com/opal/opal/pull/2328))
- Windows support for chrome runner ([#2324](https://github.com/opal/opal/pull/2324))
  - Use correct node separator for NODE_PATH on Windows
  - Pass dir and emulate exec a bit on Windows
  - Use Gem.win_platform?, match supported platform to ruby, simplify run
- NodeJS: Drop the first `--` argument in `ARGV` ([#2332](https://github.com/opal/opal/pull/2332))
- Fix `Object#require` not pointing to `Kernel#require` ([#2323](https://github.com/opal/opal/pull/2323))

### Changed

- Fast-track bad constant names passed to `Struct.new` ([#2259](https://github.com/opal/opal/pull/2259))
- Renamed internal `super` related helpers,
  `find_super_dispatcher` is now `find_super`, `find_iter_super_dispatcher` is now `find_block_super` ([#2090](https://github.com/opal/opal/pull/2090))
- The `opal-repl` CLI now requires files to be passed with `--require` (or `-r`) instead of the bare filename ([#2309](https://github.com/opal/opal/pull/2309))
- `Process` is now a Module, not a Class - just like in MRI ([#2332](https://github.com/opal/opal/pull/2332))
- `s = StringIO.new("a"); s << "b"; s.string` now returns "b", like MRI, but Opal used to return "ab" ([#2309](https://github.com/opal/opal/pull/2309))

### Internal

- Switch from jshint to ESLint ([#2289](https://github.com/opal/opal/pull/2289))
- Switch from UglifyJS to Terser ([#2318](https://github.com/opal/opal/pull/2318))
- [CI] Performance regression check (#2276, #2282)




## [1.2.0](https://github.com/opal/opal/compare/v1.1.1...v1.2.0) - 2021-07-28


### Added

- Support for multiple arguments in Hash#{merge, merge!, update} ([#2187](https://github.com/opal/opal/pull/2187))
- Support for Ruby 3.0 forward arguments: `def a(...) puts(...) end` ([#2153](https://github.com/opal/opal/pull/2153))
- Support for beginless and endless ranges: `(1..)`, `(..1)` ([#2150](https://github.com/opal/opal/pull/2150))
- Preliminary support for `**nil` argument - see #2240 to note limitations ([#2152](https://github.com/opal/opal/pull/2152))
- Support for `Random::Formatters` which add methods `#{hex,base64,urlsafe_base64,uuid,random_float,random_number,alphanumeric}` to `Random` and `SecureRandom` ([#2218](https://github.com/opal/opal/pull/2218))
- Basic support for ObjectSpace finalizers and ObjectSpace::WeakMap ([#2247](https://github.com/opal/opal/pull/2247))
- A more robust support for encodings (especially binary strings) ([#2235](https://github.com/opal/opal/pull/2235))
- Support for `"\x80"` syntax in String literals ([#2235](https://github.com/opal/opal/pull/2235))
- Added `String#+@`, `String#-@` ([#2235](https://github.com/opal/opal/pull/2235))
- Support for `begin <CODE> end while <CONDITION>` ([#2255](https://github.com/opal/opal/pull/2255))
- Added Hash#except and `Hash#except!` ([#2243](https://github.com/opal/opal/pull/2243))
- Parser 3.0: Implement pattern matching (as part of this `{Array,Hash,Struct}#{deconstruct,deconstruct_keys} methods were added)` ([#2243](https://github.com/opal/opal/pull/2243))
- [experimental] Reimplement Promise to make it bridged with JS native Promise, this new implementation can be used by requiring `promise/v2` ([#2220](https://github.com/opal/opal/pull/2220))

### Fixed

- Encoding lookup was working only with uppercase names, not giving any errors for wrong ones (#2181, #2183, #2190)
- Fix `Number#to_i` with huge number ([#2191](https://github.com/opal/opal/pull/2191))
- Add regexp support to `String#start_with` ([#2198](https://github.com/opal/opal/pull/2198))
- `String#bytes` now works in strict mode ([#2194](https://github.com/opal/opal/pull/2194))
- Fix nested module inclusion ([#2053](https://github.com/opal/opal/pull/2053))
- SecureRandom is now cryptographically secure on most platforms (#2218, #2170)
- Fix performance regression for `Array#unshift` on v8 > 7.1 ([#2116](https://github.com/opal/opal/pull/2116))
- String subclasses now call `#initialize` with multiple arguments correctly (with a limitation caused by the String immutability issue, that a source string must be the first argument and `#initialize` can't change its value) (#2238, #2185)
- Number#step is moved to Numeric ([#2100](https://github.com/opal/opal/pull/2100))
- Fix class Class < superclass for invalid superclasses ([#2123](https://github.com/opal/opal/pull/2123))
- Fix `String#unpack("U*")` on binary strings with latin1 high characters, fix performance regression on that call (#2235, #2189, #2129, #2099, #2094, #2000, #2128)
- Fix `String#to_json` output on some edge cases ([#2235](https://github.com/opal/opal/pull/2235))
- Rework class variables to support inheritance correctly ([#2251](https://github.com/opal/opal/pull/2251))
- ISO-8859-1 and US-ASCII encodings are now separated as in MRI ([#2235](https://github.com/opal/opal/pull/2235))
- `String#b` no longer modifies object strings in-place ([#2235](https://github.com/opal/opal/pull/2235))
- Parser::Builder::Default.check_lvar_name patch ([#2195](https://github.com/opal/opal/pull/2195))

### Changed

- `String#unpack`, `Array#pack`, `String#chars`, `String#length`, `Number#chr`, and (only partially) `String#+` are now encoding aware ([#2235](https://github.com/opal/opal/pull/2235))
- `String#inspect` now uses `\x` for binary stirngs ([#2235](https://github.com/opal/opal/pull/2235))
- `if RUBY_ENGINE == "opal"` and friends are now outputing less JS code (#2159, #1965)
- `Array`: `to_a`, `slice`/`[]`, `uniq`, `*`, `difference`/`-`, `intersection`/`&`, `union`/`|`, flatten now return Array, not a subclass, as Ruby 3.0 does ([#2237](https://github.com/opal/opal/pull/2237))
- `Array`: `difference`, `intersection`, `union` now accept multiple arguments ([#2237](https://github.com/opal/opal/pull/2237))

### Deprecated

- Stopped testing Opal on Ruby 2.5 since it reached EOL.

### Removed

- Removed support for the outdated `c_lexer`, it was optional and didn't work for the last few releases of parser ([#2235](https://github.com/opal/opal/pull/2235))




## [1.1.1](https://github.com/opal/opal/compare/v1.1.0...v1.1.1) - 2021-02-23


### Fixed

- The default runner (nodejs) wasn't starting to a bad require in the improved stack-traces ([#2182](https://github.com/opal/opal/pull/2182))




## [1.1.0](https://github.com/opal/opal/compare/v1.0.5...v1.1.0) - 2021-02-19


### Added

- Basic support for `uplevel:` keyword argument in `Kernel#warn` ([#2006](https://github.com/opal/opal/pull/2006))
- Added a `#respond_to_missing?` implementation for `BasicObject`, `Delegator`, `OpenStruct`, that's meant for future support in the Opal runtime, which currently ignores it ([#2007](https://github.com/opal/opal/pull/2007))
- `Opal::Compiler#magic_comments` that allows to access magic-comments format and converts it to a hash ([#2038](https://github.com/opal/opal/pull/2038))
- Use magic-comments to declare helpers required by the file ([#2038](https://github.com/opal/opal/pull/2038))
- `Opal.$$` is now a shortcut for `Opal.const_get_relative` ([#2038](https://github.com/opal/opal/pull/2038))
- `Opal.$$$` is now a shortcut for `Opal.const_get_qualified` ([#2038](https://github.com/opal/opal/pull/2038))
- Added support for `globalThis` as the generic global object accessor ([#2047](https://github.com/opal/opal/pull/2047))
- `Opal::Compiler#magic_comments` that allows to access magic-comments format and converts it to a hash
- Use magic-comments to declare helpers required by the file
- `Opal.$$` is now a shortcut for `Opal.const_get_relative`
- `Opal.$$$` is now a shortcut for `Opal.const_get_qualified`
- Source-map support for Node.js in the default runner ([#2045](https://github.com/opal/opal/pull/2045))
- SecureRandom#hex(n) ([#2050](https://github.com/opal/opal/pull/2050))
- Added a generic implementation of Kernel#caller and #warn(uplevel:) that works with sourcemaps in Node.js and Chrome ([#2065](https://github.com/opal/opal/pull/2065))
- Added support for numblocks `-> { _1 + _2 }.call(3, 4) # => 7` ([#2149](https://github.com/opal/opal/pull/2149))
- Support `<internal:…>` and `<js:…>` in stacktraces, like MRI we now distinguish internal lines from lib/app lines ([#2154](https://github.com/opal/opal/pull/2154))
- `Array#difference`, `Array#intersection`, `Array#union` as aliases respectively to `Array#{-,&,|}` ([#2151](https://github.com/opal/opal/pull/2151))
- Aliases `filter{,!}` to `select{,!}` throughout the corelib classes ([#2151](https://github.com/opal/opal/pull/2151))
- `Enumerable#filter_map`, `Enumerable#tally` ([#2151](https://github.com/opal/opal/pull/2151))
- Alias `Kernel#then` for `Kernel#yield_self` ([#2151](https://github.com/opal/opal/pull/2151))
- Method chaining: `{Proc,Method}#{<<,>>}` ([#2151](https://github.com/opal/opal/pull/2151))
- Added Integer#to_d ([#2006](https://github.com/opal/opal/pull/2006))
- Added a compiler option `use_strict` which can also be set by the `use_strict` magic comment ([#1959](https://github.com/opal/opal/pull/1959))
- Add `--rbrequire (-q)` option to `opal` command line executable ([#2120](https://github.com/opal/opal/pull/2120))

### Fixed

- Array#delete_if ([#2069](https://github.com/opal/opal/pull/2069))
- Array#keep_if ([#2069](https://github.com/opal/opal/pull/2069))
- Array#reject! ([#2069](https://github.com/opal/opal/pull/2069))
- Array#select! ([#2069](https://github.com/opal/opal/pull/2069))
- Struct#dup ([#1995](https://github.com/opal/opal/pull/1995))
- Integer#gcdlcm ([#1972](https://github.com/opal/opal/pull/1972))
- Enumerable#to_h ([#1979](https://github.com/opal/opal/pull/1979))
- Enumerator#size ([#1980](https://github.com/opal/opal/pull/1980))
- Enumerable#min ([#1982](https://github.com/opal/opal/pull/1982))
- Enumerable#min_by ([#1985](https://github.com/opal/opal/pull/1985))
- Enumerable#max_by ([#1985](https://github.com/opal/opal/pull/1985))
- Set#intersect? ([#1988](https://github.com/opal/opal/pull/1988))
- Set#disjoint? ([#1988](https://github.com/opal/opal/pull/1988))
- Set#keep_if ([#1987](https://github.com/opal/opal/pull/1987))
- Set#select! ([#1987](https://github.com/opal/opal/pull/1987))
- Set#reject! ([#1987](https://github.com/opal/opal/pull/1987))
- String#unicode_normalize ([#2175](https://github.com/opal/opal/pull/2175))
- Module#alias_method ([#1983](https://github.com/opal/opal/pull/1983))
- Enumerable#minmax_by ([#1981](https://github.com/opal/opal/pull/1981))
- Enumerator#each_with_index ([#1990](https://github.com/opal/opal/pull/1990))
- Range#== ([#1992](https://github.com/opal/opal/pull/1992))
- Range#each ([#1991](https://github.com/opal/opal/pull/1991))
- Enumerable#zip ([#1986](https://github.com/opal/opal/pull/1986))
- String#getbyte ([#2141](https://github.com/opal/opal/pull/2141))
- Struct#dup not copying `$$data` ([#1995](https://github.com/opal/opal/pull/1995))
- Fixed usage of semicolon in single-line backticks ([#2004](https://github.com/opal/opal/pull/2004))
- Module#attr with multiple arguments ([#2003](https://github.com/opal/opal/pull/2003))
- `PathReader` used to try to read missing files instead of respecting the `missing_require_severity` configuration value ([#2044](https://github.com/opal/opal/pull/2044))
- Removed some unused variables from the runtime ([#2052](https://github.com/opal/opal/pull/2052))
- Fixed a typo in the runtime ([#2054](https://github.com/opal/opal/pull/2054))
- Fix Regexp interpolation, previously interpolating with other regexps was broken ([#2062](https://github.com/opal/opal/pull/2062))
- Set match on StringScanner#skip and StringScanner#scan_until ([#2061](https://github.com/opal/opal/pull/2061))
- Fix ruby 2.7 warnings ([#2071](https://github.com/opal/opal/pull/2071))
- Improve the --help descriptions ([#2146](https://github.com/opal/opal/pull/2146))
- Remove BasicObject#class ([#2166](https://github.com/opal/opal/pull/2166))
- Time#strftime %j leading zeros ([#2161](https://github.com/opal/opal/pull/2161))
- Fix `call { true or next }` producing invalid code ([#2160](https://github.com/opal/opal/pull/2160))
- `define_method` can now be called on the main object ([#2029](https://github.com/opal/opal/pull/2029))
- Fix nested for-loops ([#2033](https://github.com/opal/opal/pull/2033))
- Fix Number#round for Integers ([#2030](https://github.com/opal/opal/pull/2030))
- Fix parsing Unicode characters from Opal ([#2073](https://github.com/opal/opal/pull/2073))
- Integer#===: improve Integer recognition ([#2089](https://github.com/opal/opal/pull/2089))
- Regexp: ensure ignoreCase is never undefined ([#2098](https://github.com/opal/opal/pull/2098))
- Hash#delete: ensure String keys are converted to values ([#2106](https://github.com/opal/opal/pull/2106))
- Array#shift: improve performance on v8 >7.1 ([#2115](https://github.com/opal/opal/pull/2115))
- Array#pop(1): improve performance ([#2130](https://github.com/opal/opal/pull/2130))
- Object#pretty_inspect ([#2139](https://github.com/opal/opal/pull/2139))
- Fix conversion from UTF-8 to bytes ([#2138](https://github.com/opal/opal/pull/2138))
- Restore compatibility with Chrome 38, used by Cordova and many mobile browsers ([#2109](https://github.com/opal/opal/pull/2109))

### Changed

- Updated outdated parser version ([#2013](https://github.com/opal/opal/pull/2013))
- Nashorn has been deprecated but GraalVM still supports it ([#1997](https://github.com/opal/opal/pull/1997))
- "opal/mini" now includes "opal/io" ([#2002](https://github.com/opal/opal/pull/2002))
- Regexps assigned to constants are now frozen ([#2007](https://github.com/opal/opal/pull/2007))
- `Opal.$$` changed from being the constant cache of Object to being a shortcut for `Opal.const_get_relative` ([#2038](https://github.com/opal/opal/pull/2038))
- Moved REPL implementation from bin/ to its own lib/ file as `opal/repl.rb` ([#2048](https://github.com/opal/opal/pull/2048))
- `Encoding.default_external` is now initialized with `__ENCODING__` ([#2072](https://github.com/opal/opal/pull/2072))
- Keep the MersenneTwister implementation private ([#2108](https://github.com/opal/opal/pull/2108))
- Change parser to 3.0 ([#2148](https://github.com/opal/opal/pull/2148))
- Fix forwarding a rescued error to a global var: `rescue => $gvar` ([#2154](https://github.com/opal/opal/pull/2154))
- Now using Parser v3.0 and targeting Ruby 3.0 ([#2156](https://github.com/opal/opal/pull/2156))
- `Comparable#clamp` to support a Range argument ([#2151](https://github.com/opal/opal/pull/2151))
- `#to_h` method to support a block (shortform for `.map(&block).to_h`) ([#2151](https://github.com/opal/opal/pull/2151))
- BigDecimal is now a subclass of Numeric ([#2006](https://github.com/opal/opal/pull/2006))
- PP to be rebased on upstream Ruby version ([#2083](https://github.com/opal/opal/pull/2083))
- String to report UTF-8 encoding by default, as MRI does ([#2117](https://github.com/opal/opal/pull/2117))
- Don't output "Failed to load WithCLexer, using pure Ruby lexer" warning unless in $DEBUG mode ([#2174](https://github.com/opal/opal/pull/2174))

### Deprecated

- Requiring nodejs/stacktrace has been deprecated, source-maps are already
  supported by the default Node.js runner or by requiring https://github.com/evanw/node-source-map-support
  before loading code compiled by Opal ([#2045](https://github.com/opal/opal/pull/2045))

### Removed

- Removed special compilation for the `Opal.truthy?` and `Opal.falsy?` helpers ([#2076](https://github.com/opal/opal/pull/2076))
- Removed the deprecated `tainting` compiler config option ([#2072](https://github.com/opal/opal/pull/2072))




## [1.0.5](https://github.com/opal/opal/compare/v1.0.4...v1.0.5) - 2020-12-23


### Fixed

- [Backported] Add --rbrequire (-q) option to opal cmdline tool ([#2120](https://github.com/opal/opal/pull/2120))
- Improve the --help descriptions ([#2146](https://github.com/opal/opal/pull/2146))




## [1.0.4](https://github.com/opal/opal/compare/v1.0.3...v1.0.4) - 2020-12-13


### Fixed

- [Backported] Using the `--map` / `-P` CLI option was only working in conjunction with other options ([#1974](https://github.com/opal/opal/pull/1974))




## [1.0.3](https://github.com/opal/opal/compare/v1.0.2...v1.0.3) - 2020-02-01


### Fixed

- Fixed compiling code with Unicode chars from Opal with opal-parser ([#2074](https://github.com/opal/opal/pull/2074))




## [1.0.2](https://github.com/opal/opal/compare/v1.0.1...v1.0.2) - 2019-12-15


- Increase the timeout for starting Chrome within the Chrome runner ([#2037](https://github.com/opal/opal/pull/2037))
- Run the Opal code within the body inside Chrome runner, it fixes an issue in opal-rspec ([#2037](https://github.com/opal/opal/pull/2037))




## [1.0.1](https://github.com/opal/opal/compare/v1.0.0...v1.0.1) - 2019-12-08


### Changed

- Relaxed parser version requirement ([#2013](https://github.com/opal/opal/pull/2013))




## [1.0.0](https://github.com/opal/opal/compare/v0.11.4...v1.0.0) - 2019-05-12


### Added

- Added `Module#prepend` and completely overhauled the module and class inheritance system ([#1826](https://github.com/opal/opal/pull/1826))
- Methods and properties are now assigned with `Object.defineProperty()` as non-enumerable ([#1821](https://github.com/opal/opal/pull/1821))
- Backtrace now includes the location inside the source file for syntax errors ([#1814](https://github.com/opal/opal/pull/1814))
- Added support for a faster C-implemented lexer, it's enough to add `gem 'c_lexer` to the `Gemfile` ([#1806](https://github.com/opal/opal/pull/1806))
- Added `Date#to_n` that returns the JavaScript Date object (in native.rb). (#1779, #1792)
- Added `Array#pack` (supports only `C, S, L, Q, c, s, l, q, A, a` formats). ([#1723](https://github.com/opal/opal/pull/1723))
- Added `String#unpack` (supports only `C, S, L, Q, S>, L>, Q>, c, s, l, q, n, N, v, V, U, w, A, a, Z, B, b, H, h, u, M, m` formats). ([#1723](https://github.com/opal/opal/pull/1723))
- Added `File#symlink?` for Node.js. ([#1725](https://github.com/opal/opal/pull/1725))
- Added `Dir#glob` for Node.js (does not support flags). ([#1727](https://github.com/opal/opal/pull/1727))
- Added support for a static folder in the "server" CLI runner via the `OPAL_CLI_RUNNERS_SERVER_STATIC_FOLDER` env var
- Added the CLI option `--runner-options` that allows passing arbitrary options to the selected runner, currently the only runner making use of them is `server` accepting `port` and `static_folder`
- Added a short helper to navigate constants manually: E.g. `Opal.$$.Regexp.$$.IGNORECASE` (see docs for "Compiled Ruby")
- Added initial support for OpenURI module (using XMLHttpRequest on browser and [xmlhttprequest](https://www.npmjs.com/package/xmlhttprequest) on Node). ([#1735](https://github.com/opal/opal/pull/1735))
- Added `String#prepend` to the list of unsupported methods (because String are immutable in JavaScript)
- Added methods (most introduced in 2.4/2.5):
    * `Array#prepend` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Array#append` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Array#max` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Array#min` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Complex#finite?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Complex#infinite?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Complex#infinite?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Date#to_time` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Date#next_year` ([#1885](https://github.com/opal/opal/pull/1885))
    * `Date#prev_year` ([#1885](https://github.com/opal/opal/pull/1885))
    * `Hash#slice` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Hash#transform_keys` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Hash#transform_keys!` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Numeric#finite?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Numeric#infinite?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Numeric#infinite?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Integer#allbits?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Integer#anybits?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Integer#digits` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Integer#nobits?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Integer#pow` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Integer#remainder` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Integer.sqrt` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Random.urandom` ([#1757](https://github.com/opal/opal/pull/1757))
    * `String#delete_prefix` ([#1757](https://github.com/opal/opal/pull/1757))
    * `String#delete_suffix` ([#1757](https://github.com/opal/opal/pull/1757))
    * `String#casecmp?` ([#1757](https://github.com/opal/opal/pull/1757))
    * `Kernel#yield_self` ([#1757](https://github.com/opal/opal/pull/1757))
    * `String#unpack1` ([#1757](https://github.com/opal/opal/pull/1757))
	* `String#to_r` ([#1842](https://github.com/opal/opal/pull/1842))
	* `String#to_c` ([#1842](https://github.com/opal/opal/pull/1842))
	* `String#match?` ([#1842](https://github.com/opal/opal/pull/1842))
	* `String#unicode_normalize` returns self ([#1842](https://github.com/opal/opal/pull/1842))
	* `String#unicode_normalized?` returns true ([#1842](https://github.com/opal/opal/pull/1842))
	* `String#[]=` throws `NotImplementedError`([#1836](https://github.com/opal/opal/pull/1836))

- Added support of the `pattern` argument for `Enumerable#all?`, `Enumerable#any?`, `Enumerable#none?`. ([#1757](https://github.com/opal/opal/pull/1757))
- Added `ndigits` option support to `Number#floor`, `Number#ceil`, `Number#truncate`. ([#1757](https://github.com/opal/opal/pull/1757))
- Added `key` and `receiver` attributes to the `KeyError`. ([#1757](https://github.com/opal/opal/pull/1757))
- Extended `Struct.new` to support `keyword_init` option. ([#1757](https://github.com/opal/opal/pull/1757))
- Added a new `Opal::Config.missing_require_severity` option and relative `--missing-require` CLI flag. This option will command how the builder will behave when a required file is missing. Previously the behavior was undefined and partly controlled by `dynamic_require_severity`. Not to be confused with the runtime config option `Opal.config.missing_require_severity;` which controls the runtime behavior.
- Added `Matrix` (along with the internal MRI utility `E2MM`)
- Use shorter helpers for constant lookups, `$$` for relative (nesting) lookups and `$$$` for absolute (qualified) lookups
- Add support for the Mersenne Twister random generator, the same used by CRuby/MRI (#657 & #1891)
- [Nodejs] Added support for binary data in `OpenURI` (#1911, #1920)
- [Nodejs] Added support for binary data in `File#read` (#1919, #1921)
- [Nodejs] Added support for `File#readlines` ([#1882](https://github.com/opal/opal/pull/1882))
- [Nodejs] Added support for `ENV#[]`, `ENV#[]=`, `ENV#key?`, `ENV#has_key?`, `ENV#include?`, `ENV#member?`, `ENV#empty?`, `ENV#keys`, `ENV#delete` and `ENV#to_s` ([#1928](https://github.com/opal/opal/pull/1928))


### Changed

- **BREAKING** The dot (`.`) character is no longer replaced with [\s\S] in a multiline regexp passed to Regexp#match and Regexp#match? (#1796, #1795)
  * You're advised to always use [\s\S] instead of . in a multiline regexp, which is portable between Ruby and JavaScript
- **BREAKING** `Kernel#format` (and `sprintf` alias) are now in a dedicated module `corelib/kernel/format` and available exclusively in `opal` ([#1930](https://github.com/opal/opal/pull/1930))
  * Previously the methods were part of the `corelib/kernel` module and available in both `opal` and `opal/mini`
- Filename extensions are no longer stripped from filenames internally, resulting in better error reporting ([#1804](https://github.com/opal/opal/pull/1804))
- The internal API for CLI runners has changed, now it's just a callable object
- The `--map` CLI option now works only in conjunction with `--compile` (or `--runner compiler`)
- The `node` CLI runner now adds its `NODE_PATH` entry instead of replacing the ENV var altogether
- Added `--disable-web-security` option flag to the Chrome headless runner to be able to do `XMLHttpRequest`
- Migrated parser to 2.5. Bump RUBY_VERSION to 2.5.0.
- Exceptions raised during the compilation now add to the backtrace the current location of the opal file if available ([#1814](https://github.com/opal/opal/pull/1814)).
- Better use of `displayName` on functions and methods and more readable temp variable names ([#1910](https://github.com/opal/opal/pull/1910))
- Source-maps are now inlined and already contain sources, incredibly more stable and precise ([#1856](https://github.com/opal/opal/pull/1856))


### Deprecated

- The CLI `--server-port 1234` option is now deprecated in favor of using `--runner-options='{"port": 1234}'`
- Including `::Native` is now deprecated because it generates conflicts with core classes in constant lookups (both `Native::Object` and `Native::Array` exist). Instead `Native::Werapper` should be used.
- Using `node_require 'my_module'` to access the native `require()` function in Node.js is deprecated in favor of <code>\`require('my_module')\`</code> because static builders need to parse the call in order to function ([#1886](https://github.com/opal/opal/pull/1886)).


### Removed

- The `node` CLI runner no longer supports passing extra node options via the `NODE_OPT` env var, instead Node.js natively supports the `NODE_OPTIONS` env var.
- The gem "hike" is no longer an external dependency and is now an internal dependency available as `Opal::Hike` ([#1881](https://github.com/opal/opal/pull/1881))
- Removed the internal Opal class `Marshal::BinaryString` ([#1914](https://github.com/opal/opal/pull/1914))
- Removed Racc, as it's now replaced by the parser gem ([#1880](https://github.com/opal/opal/pull/1880))



### Fixed

- Fix handling of trailing semicolons and JavaScript returns inside x-strings, the behavior is now well defined and covered by proper specs ([#1776](https://github.com/opal/opal/pull/1776))
- Fixed singleton method definition to return method name. ([#1757](https://github.com/opal/opal/pull/1757))
- Allow passing number of months to `Date#next_month` and `Date#prev_month`. ([#1757](https://github.com/opal/opal/pull/1757))
- Fixed `pattern` argument handling for `Enumerable#grep` and `Enumerable#grep_v`. ([#1757](https://github.com/opal/opal/pull/1757))
- Raise `ArgumentError` instead of `TypeError` from `Numeric#step` when step is not a number. ([#1757](https://github.com/opal/opal/pull/1757))
- At run-time `LoadError` wasn't being raised even with `Opal.config.missing_require_severity;` set to `'error'`.
- Fixed `Kernel#public_methods` to return instance methods if the argument is set to false. ([#1848](https://github.com/opal/opal/pull/1848))
- Fixed an issue in `String#gsub` that made it start an infinite loop when used recursively. ([#1879](https://github.com/opal/opal/pull/1879))
- `Kernel#exit` was using status 0 when a number or a generic object was provided, now accepts numbers and tries to convert objects with `#to_int` (#1898, #1808).
- Fixed metaclass inheritance in subclasses of Module ([#1901](https://github.com/opal/opal/pull/1901))
- `Method#to_proc` now correctly sets parameters and arity on the resulting Proc ([#1903](https://github.com/opal/opal/pull/1903))
- Fixed bridged classes having their prototype removed from the original chain by separating them from the Ruby class ([#1909](https://github.com/opal/opal/pull/1909))
- Improve `String#to_proc` performance ([#1888](https://github.com/opal/opal/pull/1888))
- Fixed/updated the examples ([#1887](https://github.com/opal/opal/pull/1887))
- `Opal.ancestors()` now returns false for when provided with JS-falsy objects ([#1839](https://github.com/opal/opal/pull/1839))
- When subclassing now the constant is set before calling `::inherited` ([#1838](https://github.com/opal/opal/pull/1838))
- `String#to_sym` now returns the string literal ([#1835](https://github.com/opal/opal/pull/1835))
- `String#center` now correctly checks length ([#1833](https://github.com/opal/opal/pull/1833))
- `redo` inside `while` now works properly ([#1820](https://github.com/opal/opal/pull/1820))
- Fixed compilation of empty/whitespace-only x-strings ([#1811](https://github.com/opal/opal/pull/1811))
- Fix `||=` assignments on constants when the constant is not yet defined ([#1935](https://github.com/opal/opal/pull/1935))
- Fix `String#chomp` to return an empty String when `arg == self` ([#1936](https://github.com/opal/opal/pull/1936))
- Fix methods of `Comparable` when `<=>` does not return Numeric ([#1945](https://github.com/opal/opal/pull/1945))
- Fix `Class#native_alias` error message ([#1946](https://github.com/opal/opal/pull/1946))
- Fix `gmt_offset` (alias `utc_offset`) should return 0 if the date is UTC ([#1941](https://github.com/opal/opal/pull/1941))
- `exceptionDetails.stackTrace` can be undefined ([#1955](https://github.com/opal/opal/pull/1955))
- Implement `String#each_codepoint` and `String#codepoints` (#1944, #1947)
- [internal] Terminate statement with semi-colon and remove unecessary semi-colon ([#1948](https://github.com/opal/opal/pull/1948))
- Some steps toward "strict mode" ([#1953](https://github.com/opal/opal/pull/1953))
- Preserve `Exception.stack`, in some cases the backtrace was lost ([#1963](https://github.com/opal/opal/pull/1963))
- Make `String#ascii_only?` a little less wrong ([#1951](https://github.com/opal/opal/pull/1951))
- Minor fixes to `::Native` ([#1957](https://github.com/opal/opal/pull/1957))




## [0.11.4](https://github.com/opal/opal/compare/v0.11.3...v0.11.4) - 2018-11-07


### Fixed

- `Kernel#exit` was using status 0 when a number or a generic object was provided, now accepts numbers and tries to convert objects with `#to_int`.




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

- Added support for complex (`0b1110i`) and rational (`0b1111r`) number literals. ([#1487](https://github.com/opal/opal/pull/1487))
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
- Added safe navigator (`&.`) support. ([#1532](https://github.com/opal/opal/pull/1532))
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
- Added `String#ascii_only?` ([#1592](https://github.com/opal/opal/pull/1592))
- Added `StringScanner#matched_size` ([#1595](https://github.com/opal/opal/pull/1595))
- Added `Hash#compare_by_identity` ([#1657](https://github.com/opal/opal/pull/1657))


### Removed

- Dropped support for IE8 and below, and restricted Safari and Opera support to the last two versions
- Dropped support for PhantomJS as it was [abandoned](https://groups.google.com/forum/#!topic/phantomjs/9aI5d-LDuNE).


### Changed

- Removed self-written lexer/parser. Now uses parser/ast gems to convert source code to AST. ([#1465](https://github.com/opal/opal/pull/1465))
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
    * `Numeric#step` ([#1512](https://github.com/opal/opal/pull/1512))

- Improvements for Range class ([#1486](https://github.com/opal/opal/pull/1486))
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

- Fixed inheritance from the `Module` class ([#1476](https://github.com/opal/opal/pull/1476))
- Fixed source map server with url-encoded paths
- Silence Sprockets 3.7 deprecations, full support for Sprockets 4 will be available in Opal 0.11
- Don't print the full stack trace with deprecation messages




## [0.10.2](https://github.com/opal/opal/compare/v0.10.1...v0.10.2) - 2016-09-09


### Changed

- Avoid special utf-8 chars in method names, now they start with `$$`




## [0.10.1](https://github.com/opal/opal/compare/v0.10.0...v0.10.1) - 2016-07-06


### Fixed

- Fixed `-L` option for compiling requires as modules ([#1510](https://github.com/opal/opal/pull/1510))




## [0.10.0](https://github.com/opal/opal/compare/v0.9.4...v0.10.0) - 2016-07-04


### Added

- Pathname#relative_path_from
- Source maps now include method names
- `Module#included_modules` works
- Internal runtime cleanup ([#1241](https://github.com/opal/opal/pull/1241))
- Make it easier to add custom runners for the CLI ([#1261](https://github.com/opal/opal/pull/1261))
- Add Rack v2 compatibility ([#1260](https://github.com/opal/opal/pull/1260))
- Newly compliant with the Ruby Spec Suite:
    * `Array#slice!`
    * `Array#repeated_combination`
    * `Array#repeated_permutation`
    * `Array#sort_by!`
    * `Enumerable#sort`
    * `Enumerable#max`
    * `Enumerable#each_entry` ([#1303](https://github.com/opal/opal/pull/1303))
    * `Module#const_set`
    * `Module#module_eval` with a string
- Add `-L` / `--library` option to compile only the code of the library ([#1281](https://github.com/opal/opal/pull/1281))
- Implement `Kernel.open` method ([#1218](https://github.com/opal/opal/pull/1218))
- Generate meaningful names for functions representing Ruby methods
- Implement `Pathname#join` and `Pathname#+` methods ([#1301](https://github.com/opal/opal/pull/1301))
- Added support for `begin;rescue;else;end`.
- Implement `File.extname` method ([#1219](https://github.com/opal/opal/pull/1219))
- Added support for keyword arguments as lambda parameters.
- Super works with define_method blocks
- Added support for kwsplats.
- Added support for squiggly heredoc.
- Implement `Method#parameters` and `Proc#parameters`.
- Implement `File.new("path").mtime`, `File.mtime("path")`, `File.stat("path").mtime`.
- if-conditions now support `null` and `undefined` as falsy values ([#867](https://github.com/opal/opal/pull/867))
- Implement IO.read method for Node.js ([#1332](https://github.com/opal/opal/pull/1332))
- Implement IO.each_line method for Node.js ([#1221](https://github.com/opal/opal/pull/1221))
- Generate `opal-builder.js` to ease the compilation of Ruby library from JavaScript ([#1290](https://github.com/opal/opal/pull/1290))


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

- `Module#ancestors` and shared code like `====` and `is_a?` deal with singleton class modules better ([#1449](https://github.com/opal/opal/pull/1449))
- `Class#to_s` now shows correct names for singleton classes
- `Pathname#absolute?` and `Pathname#relative?` now work properly
- `File::dirname` and `File::basename` are now Rubyspec compliant
- `SourceMap::VLQ` patch ([#1075](https://github.com/opal/opal/pull/1075))
- `Regexp::new` no longer throws error when the expression ends in \\\\
- `super` works properly with overwritten alias methods ([#1384](https://github.com/opal/opal/pull/1384))
- `NoMethodError` does not need a name to be instantiated
- `method_added` fix for singleton class cases
- Super now works properly with blocks ([#1237](https://github.com/opal/opal/pull/1237))
- Fix using more than two `rescue` in sequence ([#1269](https://github.com/opal/opal/pull/1269))
- Fixed inheritance for `Array` subclasses.
- Always populate all stub_subscribers with all method stubs, as a side effect of this now `method_missing` on bridged classes now works reliably ([#1273](https://github.com/opal/opal/pull/1273))
- Fix `Hash#instance_variables` to not return `#default` and `#default_proc` ([#1258](https://github.com/opal/opal/pull/1258))
- Fix `Module#name` when constant was created using `Opal.cdecl` (constant declare) like `ChildClass = Class.new(BaseClass)` ([#1259](https://github.com/opal/opal/pull/1259))
- Fix issue with JavaScript `nil` return paths being treated as true ([#1274](https://github.com/opal/opal/pull/1274))
- Fix `Array#to_n`, `Hash#to_n`, `Struct#to_n` when the object contains native objects (#1249, #1256)
- `break` semantics are now correct, except for the case in which a lambda containing a `break` is passed to a `yield` ([#1250](https://github.com/opal/opal/pull/1250))
- Avoid double "/" when `Opal::Sprockets.javascript_include_tag` receives a prefix with a trailing slash.
- Fixed context of evaluation for `Kernel#eval` and `BasicObject#instance_eval`
- Fix `Module#===` to use all ancestors of the passed object ([#1284](https://github.com/opal/opal/pull/1284))
- Fix `Struct.new` to be almost compatible with Rubyspec ([#1251](https://github.com/opal/opal/pull/1251))
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

- Backport rack2 compatibility ([#1260](https://github.com/opal/opal/pull/1260))
- Fixed issue with JS nil return paths being treated as true ([#1274](https://github.com/opal/opal/pull/1274))
- Fix using more than two `rescue` in sequence ([#1269](https://github.com/opal/opal/pull/1269))




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
    * `Range#to_a` ([#1246](https://github.com/opal/opal/pull/1246))
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
- Fix `Array#to_n`, `Hash#to_n`, `Struct#to_n` when the object contains native objects ([#1249](https://github.com/opal/opal/pull/1249))
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




