### Added

- Introduce timezone support for Time (#2394)
- DateTime and Date refactor (#2398)
- Implement `Number#prev_float`/`#next_float` (#2404)
- Support `binding.irb` anywhere in the code, for both browsers and node (#2392)
- Added `URI.decode_www_form` (#2387)

### Changed

- Move Math IE11-supporting polyfills to a separate file (#2395)
- String methods always return Strings even when overloaded (#2413)
- `alias` calls will not add the "old name" method to the list of stubs for method missing (#2414)
- Optimize writer/setter methods, up to 4% performance gain (#2402)

### Performance

- Improve performance of argument coertion, fast-track `Integer`, `String`, and calling the designed coertion method (#2383)
- Optimize `Array#[]=` by moving the implementation to JavaScript and inlining type checks (#2383)
- Optimize internal runtime passing of block-options (#2383)
- Compile `case` statements as `switch` whenever possible (#2411)
- Improve performance with optimized common method/iter implementation shortcuts (#2401)

### Fixed

- Fix `Regexp.new`, previously `\A` and `\z` didn't match beginning and end of input (#2079)
- Fix exception during `Hash#each` and `Hash#each_key` if keys get deleted during the loop (#2403)
- Fix defining multiple methods with the same block (#2397)
- A few edge cases of conditional calls combined with setters, e.g. `foo&.bar = 123` (#2402)
- Correct String#to_proc and method_missing compatibility (#2418)
- Exit REPL respecting the exit status number (#2396)

### Internal

- Rewriters refactor, fix interaction between cache and iverted runner (#2400)

<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
-->
