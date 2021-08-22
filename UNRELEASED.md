### Added

- Add support for `retry` (#2264)
- Modernize Exceptions (#2264)
  - Add `#cause`, `#backtrace_locations`, `#full_message` to `Exception`
  - Normalize backtraces across platforms
  - Add `Thread::Backtrace::Location`
- TracePoint `:class` support (#2049)
- Implement the Flip-Flop operators (#2261)
- Add `JS[]` to access properties on the global object (#2259)
- Add `ENV.fetch` to the Nodejs implementation of `ENV` (#2259)
- [experimental] Opal::Cache, an optional compiler cache (#2242)
- Alias for gvars, alias on main (#2270)

### Fixed

- Fixed multiple line `Regexp` literal to not generate invalid syntax as JavaScript (#1616)
- Fix `Kernel#{try,catch}` along with `UncaughtThrowError` (#2264)
- Update source-map-support to fix an off-by-one error (#2264)

### Changed

- Fast-track bad constant names passed to `Struct.new` (#2259)

### Deprecated

### Removed
