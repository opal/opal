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
- REPL improvements: (#2285)
  - Colored output & history support
  - `ls` to show available constants and variable
- Add `Method#===` as an alias to `Method#call`, works the same as `Proc#===` (#2305)
- Add `IO#gets` and `IO#read_proc` along with other supporting methods (#2309)
  - Support `#gets` on most platforms, including browsers (via `prompt`)
  - Move the REPL to a `--repl` CLI option of the main executable
  - Completely refactor IO, now supporting 
  - Add a runner for MiniRacer (as `miniracer`)
  - Support Windows on the Chrome runner 
  - Support Windows on the REPL
  - Platforms an IO implementations should either set `IO#read_proc` or overwrite `IO#sysread`

### Fixed

- Fixed multiple line `Regexp` literal to not generate invalid syntax as JavaScript (#1616)
- Fix `Kernel#{try,catch}` along with `UncaughtThrowError` (#2264)
- Update source-map-support to fix an off-by-one error (#2264)
- Source map: lines should start from 1, not 0 (#2273)
- Allow for multiple underscored args with the same name in strict mode (#2292)
- Show instance variables in `Kernel#inspect` (#2285)
- `0.digits` was returning an empty array in strict mode (#2301)
- Non Integer numbers were responding to `#digits` (#2301)
- Correctly delete hash members when dealing with boxed strings (#2306)
- Escape string components in interpolated strings (`dstrs`) correctly (#2308)
- Don't try to return the JS `debugger` statement, just return `nil` (#2307)
- Retain the `-` while stringifying `-0.0` (#2304)
- Fix super support for rest args and re-assignments with implicit arguments (#2315)

### Changed

- Fast-track bad constant names passed to `Struct.new` (#2259)
- Renamed internal `super` related helpers,
  `find_super_dispatcher` is now `find_super`, `find_iter_super_dispatcher` is now `find_block_super` (#2090)
- The `opal-repl` CLI now requires files to be passed with `--require` (or `-r`) instead of the bare filename (#2309)


### Deprecated

### Removed

### Internal

- Switch from jshint to ESLint (#2289)
