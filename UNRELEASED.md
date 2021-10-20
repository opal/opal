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
- Opal::Cache, an optional compiler cache (enabled by default) (#2242, #2278, #2329)
- Alias for gvars, alias on main (#2270)
- Support for GJS (GNOME's JavaScript runtime) runner (#2280)
- Scope variables support for `eval()` (#2256)
- Add support for `Kernel#binding` (#2256)
- A (mostly) correct support for refinements (#2256)
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
- [experimental] Add support for JavaScript async/await (#2221)
  - Enable the feature by adding a magic comment: `# await: true`
  - The magic comment can be also used to mark specific method patterns to be awaited
    (e.g. `# await: *_await, sleep` will make any method ending in `_await` or named `sleep` to be awaited)
  - Add `Kernel#__await__` as a bridge to the `await` keyword (inspired by CoffeeScript await support)
  - Require `opal/await` to get additional support
  - Read more on the newly added documentation page
- Better interoperability between legacy Promise (v1) and native Promise (v2) (#2221)
  - Add `PromiseV1` as an alias to the original (legacy) Promise class
  - Add `#to_v1` and `#to_v2` to both classes
  - `Promise#to_n` will convert it to a native Promise (v2)
- Add `Opal::Config.esm` to enable/disable ES modules (#2316)
  - If Config.esm is enabled, SimpleServer does type="module"
  - Add new rack-esm example
- Add a QuickJS (https://bellard.org/quickjs/) runner (#2331)
- Add `IO#fileno`, `Method#curry`, `Buffer#to_s`, `Pathname.pwd` (#2332)
- Add NodeJS support for `ARGF`, `ENV.{inspect,to_h,to_hash,merge}`, `File.{delete,unlink}`, `Kernel#system`, <code>Kernel#`</code>, `Process::Status` (#2332)
- Introduce `__dir__` support (#2323)
- Full autoload support (#2323)
  - Now compatible with `opal-zeitwerk` and `isomorfeus`
  - Allow toplevel autoloads
  - Allow dynamic autoloads (e.g. can be hooked to fetch a URL upon autoload with a custom loader)
  - Allow overwriting `require` (e.g. like rubygems does)
  - Allow autoloading trees with `require_tree "./foo", autoload: true`
  - Add Module#autoload?
- Autoload parts of the corelib (#2323)

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
- Fix calling `Regexp#last_match` when `$~` is nil (#2328)
- Windows support for chrome runner (#2324)
  - Use correct node separator for NODE_PATH on Windows
  - Pass dir and emulate exec a bit on Windows
  - Use Gem.win_platform?, match supported platform to ruby, simplify run
- NodeJS: Drop the first `--` argument in `ARGV` (#2332)
- Fix `Object#require` not pointing to `Kernel#require` (#2323)

### Changed

- Fast-track bad constant names passed to `Struct.new` (#2259)
- Renamed internal `super` related helpers,
  `find_super_dispatcher` is now `find_super`, `find_iter_super_dispatcher` is now `find_block_super` (#2090)
- The `opal-repl` CLI now requires files to be passed with `--require` (or `-r`) instead of the bare filename (#2309)
- `Process` is now a Module, not a Class - just like in MRI (#2332)

### Deprecated

### Removed

### Internal

- Switch from jshint to ESLint (#2289)
- Switch from UglifyJS to Terser (#2318)
- [CI] Performance regression check (#2276, #2282)
