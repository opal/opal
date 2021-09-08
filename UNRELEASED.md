### Added

- Add support for `retry` (#2264)
- Modernize Exceptions (#2264)
  - Add `#cause`, `#backtrace_locations`, `#full_message` to `Exception`
  - Normalize backtraces across platforms
  - Add `Thread::Backtrace::Location`
  - Output Exception#full_message on uncaught exceptions (#2269)
- TracePoint `:class` support (#2049)
- Implement the Flip-Flop operators (#2261)
- Add `JS[]` to access properties on the global object (#2259)
- Add `ENV.fetch` to the Nodejs implementation of `ENV` (#2259)
- [experimental] Opal::Cache, an optional compiler cache (#2242, #2278)
- Alias for gvars, alias on main (#2270)
- Support for GJS (GNOME's JavaScript runtime) runner (#2280)
- Scope variables support for `eval()` (#2256)
- Add support for `Kernel#binding` (#2256)
- A (mostly) correct support for refinements (#2256)
- [CI] Performance regression check (#2276, #2282)
- Add support for ECMAScript modules with an `--esm` CLI option (#2286)
- Implement `Regexp#names` and add named captures support (#2272)

### Fixed

- Fixed multiple line `Regexp` literal to not generate invalid syntax as JavaScript (#1616)
- Fix `Kernel#{try,catch}` along with `UncaughtThrowError` (#2264)
- Update source-map-support to fix an off-by-one error (#2264)
- Source map: lines should start from 1, not 0 (#2273)
- Allow for multiple underscored args with the same name in strict mode (#2292)

### Changed

- Fast-track bad constant names passed to `Struct.new` (#2259)

### Deprecated

### Removed

### Internal

- Switch from jshint to ESLint (#2289)
