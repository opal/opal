<!--
Whitespace conventions:
- 4 spaces before ## titles
- 2 spaces before ### titles
- 1 spaces before normal text
-->

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
- `Kernel#exit` was using status 0 when a number or a generic object was provided, now accepts numbers and tries to convert objects with `#to_int` (#1898).
