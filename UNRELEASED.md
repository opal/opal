### Added

- Support for multiple arguments in Hash#{merge, merge!, update} (#2187)
- Support for Ruby 3.0 forward arguments: `def a(...) puts(...) end` (#2153)
- Support for beginless and endless ranges: `(1..)`, `(..1)` (#2150)
- Preliminary support for `**nil` argument - see #2240 to note limitations (#2152)
- Support for `Random::Formatters` which add methods `#{hex,base64,urlsafe_base64,uuid,random_float,random_number,alphanumeric}` to `Random` and `SecureRandom` (#2218)
- Basic support for ObjectSpace finalizers and ObjectSpace::WeakMap (#2247)

### Fixed

- Encoding lookup was working only with uppercase names, not giving any errors for wrong ones (#2181, #2183, #2190)
- Fix `Number#to_i` with huge number (#2191)
- Add regexp support to `String#start_with` (#2198)
- `String#bytes` now works in strict mode (#2194)
- Fix nested module inclusion (#2053)
- SecureRandom is now cryptographically secure on most platforms (#2218, #2170)
- Fix performance regression for `Array#unshift` on v8 > 7.1 (#2116)
- String subclasses now call `#initialize` with multiple arguments correctly (with a limitation caused by the String immutability issue, that a source string must be the first argument and `#initialize` can't change its value) (#2238, #2185)
- Number#step is moved to Numeric (#2100)
- Fix class Class < superclass for invalid superclasses (#2123)


### Changed

- `if RUBY_ENGINE == "opal"` and friends are now outputing less JS code (#2159, #1965)
- `Array`: `to_a`, `slice`/`[]`, `uniq`, `*`, `difference`/`-`, `intersection`/`&`, `union`/`|`, flatten now return Array, not a subclass, as Ruby 3.0 does (#2237)
- `Array`: `difference`, `intersection`, `union` now accept multiple arguments (#2237)

### Deprecated

- Stopped testing Opal on Ruby 2.5 since it reached EOL.

### Removed
