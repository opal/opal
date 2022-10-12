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

### Added

- Add CLI support for ESM, at least for Chrome, NodeJS, QuickJS and GJS (#2435)
- Support exit in Chrome CLI Runner, both sync and async (#2439)
- Make sure the Server CLI Runner can pick up changes in sources (#2436)
- Delegate and ruby2_keywords (#2446)
- Source code can now be embedded in the compiled file to improve development/debugging, e.g. RSpec reports, `Proc#source_location` (#2440)
- Added `Proc#source_location` (#2440)
- Added `Kernel#caller_locations` (#2440)

### Fixed

- Fix an edge case of if in the most complex form not returning (#2433)
- `String#length` is now available when using `opal/mini` (#2438)
- Auto-await produced invalid code (#2440)
- Fix `Enumerable#collect_concat` and `#flat_map` implementation (#2440)
- Improved await support for PromiseV1 (#2440)

### Internal

- GitHub Workflows security hardening (#2432)
