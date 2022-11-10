<!--
### Internal
### Changed
### Added
### Removed
### Deprecated
### Performance
### Fixed
-->

### Changed

- No longer truncate stacktraces to 15 lines (#2440)

### Performance

- Improve method block performance for runtime (#2449)
- Uninline non-typical argument handling (#2419)
- Logic optimization of runtime.js (#2415)
- Windows support for `performance:compare` CI check (#2450)
- Improve block performance for even more cases (#2465)

### Added

- Added support for `#freeze` and `#frozen?` (#2444, #2468)
- Add CLI support for ESM, at least for Chrome, NodeJS, QuickJS and GJS (#2435)
- Support exit in Chrome CLI Runner, both sync and async (#2439)
- Make sure the Server CLI Runner can pick up changes in sources (#2436)
- Delegate and ruby2_keywords (#2446)
- Source code can now be embedded in the compiled file to improve development/debugging, e.g. RSpec reports, `Proc#source_location` (#2440)
- Added `Kernel#caller_locations` (#2440)
- `Opal::Builder::Prefork` for blazingly fast multicore compilation times (#2263, #2462, #2454)

### Fixed

- Fix an edge case of if in the most complex form not returning (#2433)
- `String#length` is now available when using `opal/mini` (#2438)
- Auto-await produced invalid code (#2440)
- Fix `Enumerable#collect_concat` and `#flat_map` implementation (#2440)
- Improved await support for PromiseV1 (#2440)
- Compilation error occurs while compiling `being/end` returning a `case/when` (#2459)
- Ensure UTF-8 encoding of `.sourcesContent` of source maps (#2451)
- Benchmarks require string/unpack (#2453)

### Internal

- GitHub Workflows security hardening (#2432)
- Retry if file cache write operation exits with Zlib::BufError (#2463)
- Eliminate redundant `var constructor` in `allocate_class` (#2452)
- Fix `performance:compare` asset size calculation (#2457)
