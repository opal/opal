### Added

- Support for multiple arguments in Hash#{merge, merge!, update} (#2187)
- Support for Ruby 3.0 forward arguments: `def a(...) puts(...) end` (#2153)
- Support for beginless and endless ranges: `(1..)`, `(..1)` (#2150)
- Preliminary support for **nil argument - see #2240 to note limitations (#2152)

### Fixed

- Encoding lookup was working only with uppercase names, not giving any errors for wrong ones (#2181, #2183, #2190)
- Fix `Number#to_i` with huge number (#2191)
- Add regexp support to `String#start_with` (#2198)
- `String#bytes` now works in strict mode (#2194)
- Fix nested module inclusion (#2053)

### Changed

- `if RUBY_ENGINE == "opal"` and friends are now outputing less JS code (#2159, #1965)
- `Array`: `to_a`, `slice`/`[]`, `uniq`, `*`, `difference`/`-`, `intersection`/`&`, `union`/`|`, flatten now return Array, not a subclass, as Ruby 3.0 does (#2237)
- `Array`: `difference`, `intersection`, `union` now accept multiple arguments (#2237)

### Deprecated

- Stopped testing Opal on Ruby 2.5 since it reached EOL.

### Removed
