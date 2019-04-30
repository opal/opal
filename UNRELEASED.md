<!--
Whitespace conventions:
- 4 spaces before ## titles
- 2 spaces before ### titles
- 1 spaces before normal text
-->

### Added

- Added `Module#prepend` and completely overhauled the module and class inheritance system (#1826)
- Methods and properties are now assigned with `Object.defineProperty()` as non-enumerable (#1821)
- Backtrace now includes the location inside the source file for syntax errors (#1814)
- Added support for a faster C-implemented lexer, it's enough to add `gem 'c_lexer` to the `Gemfile` (#1806)
- Added `Date#to_n` that returns the JavaScript Date object (in native.rb). (#1779, #1792)
- Added `Array#pack` (supports only `C, S, L, Q, c, s, l, q, A, a` formats). (#1723)
- Added `String#unpack` (supports only `C, S, L, Q, S>, L>, Q>, c, s, l, q, n, N, v, V, U, w, A, a, Z, B, b, H, h, u, M, m` formats). (#1723)
- Added `File#symlink?` for Node.js. (#1725)
- Added `Dir#glob` for Node.js (does not support flags). (#1727)
- Added support for a static folder in the "server" CLI runner via the `OPAL_CLI_RUNNERS_SERVER_STATIC_FOLDER` env var
- Added the CLI option `--runner-options` that allows passing arbitrary options to the selected runner, currently the only runner making use of them is `server` accepting `port` and `static_folder`
- Added a short helper to navigate constants manually: E.g. `Opal.$$.Regexp.$$.IGNORECASE` (see docs for "Compiled Ruby")
- Added initial support for OpenURI module (using XMLHttpRequest on browser and [xmlhttprequest](https://www.npmjs.com/package/xmlhttprequest) on Node). (#1735)
- Added `String#prepend` to the list of unsupported methods (because String are immutable in JavaScript)
- Added methods (most introduced in 2.4/2.5):
    * `Array#prepend` (#1757)
    * `Array#append` (#1757)
    * `Array#max` (#1757)
    * `Array#min` (#1757)
    * `Complex#finite?` (#1757)
    * `Complex#infinite?` (#1757)
    * `Complex#infinite?` (#1757)
    * `Date#to_time` (#1757)
    * `Date#next_year` (#1885)
    * `Date#prev_year` (#1885)
    * `Hash#slice` (#1757)
    * `Hash#transform_keys` (#1757)
    * `Hash#transform_keys!` (#1757)
    * `Numeric#finite?` (#1757)
    * `Numeric#infinite?` (#1757)
    * `Numeric#infinite?` (#1757)
    * `Integer#allbits?` (#1757)
    * `Integer#anybits?` (#1757)
    * `Integer#digits` (#1757)
    * `Integer#nobits?` (#1757)
    * `Integer#pow` (#1757)
    * `Integer#remainder` (#1757)
    * `Integer.sqrt` (#1757)
    * `Random.urandom` (#1757)
    * `String#delete_prefix` (#1757)
    * `String#delete_suffix` (#1757)
    * `String#casecmp?` (#1757)
    * `Kernel#yield_self` (#1757)
    * `String#unpack1` (#1757)
	* `String#to_r` (#1842)
	* `String#to_c` (#1842)
	* `String#match?` (#1842)
	* `String#unicode_normalize` returns self (#1842)
	* `String#unicode_normalized?` returns true (#1842)
	* `String#[]=` throws `NotImplementedError`(#1836)

- Added support of the `pattern` argument for `Enumerable#all?`, `Enumerable#any?`, `Enumerable#none?`. (#1757)
- Added `ndigits` option support to `Number#floor`, `Number#ceil`, `Number#truncate`. (#1757)
- Added `key` and `receiver` attributes to the `KeyError`. (#1757)
- Extended `Struct.new` to support `keyword_init` option. (#1757)
- Added a new `Opal::Config.missing_require_severity` option and relative `--missing-require` CLI flag. This option will command how the builder will behave when a required file is missing. Previously the behavior was undefined and partly controlled by `dynamic_require_severity`. Not to be confused with the runtime config option `Opal.config.missing_require_severity;` which controls the runtime behavior.
- Added `Matrix` (along with the internal MRI utility `E2MM`)
- Use shorter helpers for constant lookups, `$$` for relative (nesting) lookups and `$$$` for absolute (qualified) lookups
- Add support for the Mersenne Twister random generator, the same used by CRuby/MRI (#657 & #1891)
- [Nodejs] Added support for binary data in `OpenURI` (#1911, #1920)
- [Nodejs] Added support for binary data in `File#read` (#1919, #1921)
- [Nodejs] Added support for `File#readlines` (#1882)
- [Nodejs] Added support for `ENV#[]`, `ENV#[]=`, `ENV#key?`, `ENV#has_key?`, `ENV#include?`, `ENV#member?`, `ENV#empty?`, `ENV#keys`, `ENV#delete` and `ENV#to_s` (#1928)


### Changed

- **BREAKING** The dot (`.`) character is no longer replaced with [\s\S] in a multiline regexp passed to Regexp#match and Regexp#match? (#1796, #1795)
  * You're advised to always use [\s\S] instead of . in a multiline regexp, which is portable between Ruby and JavaScript
- **BREAKING** `Kernel#format` (and `sprintf` alias) are now in a dedicated module `corelib/kernel/format` and available exclusively in `opal` (#1930)
  * Previously the methods were part of the `corelib/kernel` module and available in both `opal` and `opal/mini`
- Filename extensions are no longer stripped from filenames internally, resulting in better error reporting (#1804)
- The internal API for CLI runners has changed, now it's just a callable object
- The `--map` CLI option now works only in conjunction with `--compile` (or `--runner compiler`)
- The `node` CLI runner now adds its `NODE_PATH` entry instead of replacing the ENV var altogether
- Added `--disable-web-security` option flag to the Chrome headless runner to be able to do `XMLHttpRequest`
- Migrated parser to 2.5. Bump RUBY_VERSION to 2.5.0.
- Exceptions raised during the compilation now add to the backtrace the current location of the opal file if available (#1814).
- Better use of `displayName` on functions and methods and more readable temp variable names (#1910)
- Source-maps are now inlined and already contain sources, incredibly more stable and precise (#1856)


### Deprecated

- The CLI `--server-port 1234` option is now deprecated in favor of using `--runner-options='{"port": 1234}'`
- Including `::Native` is now deprecated because it generates conflicts with core classes in constant lookups (both `Native::Object` and `Native::Array` exist). Instead `Native::Werapper` should be used.
- Using `node_require 'my_module'` to access the native `require()` function in Node.js is deprecated in favor of <code>\`require('my_module')\`</code> because static builders need to parse the call in order to function (#1886).


### Removed

- The `node` CLI runner no longer supports passing extra node options via the `NODE_OPT` env var, instead Node.js natively supports the `NODE_OPTIONS` env var.
- The gem "hike" is no longer an external dependency and is now an internal dependency available as `Opal::Hike` (#1881)
- Removed the internal Opal class `Marshal::BinaryString` (#1914)
- Removed Racc, as it's now replaced by the parser gem (#1880)



### Fixed

- Fix handling of trailing semicolons and JavaScript returns inside x-strings, the behavior is now well defined and covered by proper specs (#1776)
- Fixed singleton method definition to return method name. (#1757)
- Allow passing number of months to `Date#next_month` and `Date#prev_month`. (#1757)
- Fixed `pattern` argument handling for `Enumerable#grep` and `Enumerable#grep_v`. (#1757)
- Raise `ArgumentError` instead of `TypeError` from `Numeric#step` when step is not a number. (#1757)
- At run-time `LoadError` wasn't being raised even with `Opal.config.missing_require_severity;` set to `'error'`.
- Fixed `Kernel#public_methods` to return instance methods if the argument is set to false. (#1848)
- Fixed an issue in `String#gsub` that made it start an infinite loop when used recursively. (#1879)
- `Kernel#exit` was using status 0 when a number or a generic object was provided, now accepts numbers and tries to convert objects with `#to_int` (#1898, #1808).
- Fixed metaclass inheritance in subclasses of Module (#1901)
- `Method#to_proc` now correctly sets parameters and arity on the resulting Proc (#1903)
- Fixed bridged classes having their prototype removed from the original chain by separating them from the Ruby class (#1909)
- Improve `String#to_proc` performance (#1888)
- Fixed/updated the examples (#1887)
- `Opal.ancestors()` now returns false for when provided with JS-falsy objects (#1839)
- When subclassing now the constant is set before calling `::inherited` (#1838)
- `String#to_sym` now returns the string literal (#1835)
- `String#center` now correctly checks length (#1833)
- `redo` inside `while` now works properly (#1820)
- Fixed compilation of empty/whitespace-only x-strings (#1811)
- Fix `||=` assignments on constants when the constant is not yet defined (#1935)
- Fix `String#chomp` to return an empty String when `arg == self` (#1936)
- Fix methods of `Comparable` when `<=>` does not return Numeric (#1945)
- Fix `Class#native_alias` error message (#1946)
- Fix `gmt_offset` (alias `utc_offset`) should return 0 if the date is UTC (#1941)
- `exceptionDetails.stackTrace` can be undefined (#1955)
- Implement `String#each_codepoint` and `String#codepoints` (#1944, #1947)
- [internal] Terminate statement with semi-colon and remove unecessary semi-colon (#1948)
- Some steps toward "strict mode" (#1953)
- Preserve `Exception.stack`, in some cases the backtrace was lost (#1963)
- Make `String#ascii_only?` a little less wrong (#1951)
- Minor fixes to `::Native` (#1957)
