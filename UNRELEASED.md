<!--
### Deprecated
-->

### Added

- Support JRuby in the builder scheduler and system runner ([#2686](https://github.com/opal/opal/pull/2686))
- Allow `BUN_OPTS` and `DENO_OPTS` to pass extra options to the Bun and Deno runners ([#2695](https://github.com/opal/opal/pull/2695))

### Changed

- Refresh bundled npm dependencies and migrate development linting to ESLint 9 ([#2685](https://github.com/opal/opal/pull/2685))
- Update unsupported `String` method definitions ([#2717](https://github.com/opal/opal/pull/2717))

### Removed

- Drop `bin/opal-mspec` in favor of the generic `bin/test` helper ([#2735](https://github.com/opal/opal/pull/2735))

### Fixed

- Detect Chromium on macOS when running Chrome-based specs ([#2681](https://github.com/opal/opal/pull/2681))
- Fix the Firefox runner ([#2694](https://github.com/opal/opal/pull/2694))
- Fix browser runner failures with `INVERT_RUNNING_MODE` and `PATTERN` ([#2696](https://github.com/opal/opal/pull/2696), [#2711](https://github.com/opal/opal/pull/2711))
- Require `::Math` for mspec compatibility ([#2708](https://github.com/opal/opal/pull/2708))
- Fix `Module#include` behavior after `#prepend` ([#2722](https://github.com/opal/opal/pull/2722))
- Require the `Thread` shim from `if` node compilation support ([#2727](https://github.com/opal/opal/pull/2727))
- Fix `Array#flatten` maximum call stack errors ([#2729](https://github.com/opal/opal/pull/2729))
- Fix `Kernel#frozen?` for singleton classes ([#2731](https://github.com/opal/opal/pull/2731))
- Fix `defined?` for constants set to `0` ([#2744](https://github.com/opal/opal/pull/2744))
- Fix Terser invocation ([#2749](https://github.com/opal/opal/pull/2749))
- Fix `Enumerable#first` return values ([#2753](https://github.com/opal/opal/pull/2753))
- Support keyword arguments when initializing Logger ([#2772](https://github.com/opal/opal/pull/2772))
- Avoid an additional boot error when `$stderr` is unavailable ([#2703](https://github.com/opal/opal/pull/2703))

### Performance

- Reduce RSpec runtime overhead ([#2781](https://github.com/opal/opal/pull/2781))

### Internal

- Rename and sort Ruby CI jobs ([#2752](https://github.com/opal/opal/pull/2752))
- Add Ruby LSP to the development Gemfile ([#2724](https://github.com/opal/opal/pull/2724))
- Backport JRuby and TruffleRuby lint follow-ups ([#2690](https://github.com/opal/opal/pull/2690))
- Restore the stable ES3 generated-JS lint contract after the ESLint 9 backport.
- Update CI coverage for Ruby 3.4 and Ruby 4.0 ([#2779](https://github.com/opal/opal/pull/2779))
- Add the `ostruct` development dependency needed by the test harness on Ruby 4 ([#2786](https://github.com/opal/opal/pull/2786))
