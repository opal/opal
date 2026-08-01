# Migrating from Opal 1.x to 2.0

Reference of every breaking and deprecating change between Opal 1.8.1 and 2.0.

Changes are split into **hard breaks** (no compatibility shim — your code stops working) and **soft
breaks** (a shim keeps old code working, usually with a warning). Start with the hard breaks.

Before you begin, turn Ruby-side deprecations into failures so nothing is missed:

```ruby
Opal.raise_on_deprecation = true   # default: false
```

## Quick checklist

| Change | Severity | Action |
|---|---|---|
| ES target is now ES2021 | **hard, silent** | Verify your target engine supports ES2021 |
| `-R nashorn` and `require 'nashorn'` removed | **hard** | Pick another runner |
| `Kernel#taint` / `#untaint` / `#tainted?` removed | **hard** | Delete the calls |
| `Opal::Builder#preload` / `#prerequired` removed | **hard** | Use `build_require` / `stubs` |
| `opal/builder_processors`, `opal/builder_scheduler` moved | **hard** | Update require paths and constants |
| `Opal.prepend` runtime helper renamed | **hard** | Use `Opal.prepend_ary` |
| `opal/corelib/runtime.js` path gone | **hard** (by path) | Point tooling at `opal/runtime/` |
| `bin/opal-mspec` removed | **hard** (contributors only) | Use `bin/test` |
| `JS` → `Opal::Raw` | soft, **removal in 2.1** | Rename now |
| `JS::Error` → `Opal::Raw::Error` | soft, **removal in 2.1** | Rename now |
| Backtick / `%x{}` JavaScript | soft | Add `# backtick_javascript: true` |
| `Opal.hash2`, `Opal.hash_init` | soft | Use `$hash_new` / `$hash_new2` |
| `Opal::Server` | soft (pre-dates 2.0) | Use `Opal::Sprockets::Server` |
| `Compiler#requires <<` | soft | Use `Compiler#track_require` |
| Various corelib behaviour fixes | **hard, silent** | Re-run your test suite |

---

## Hard breaks

### ECMAScript target raised from ES3 to ES2021

**There is no warning for this change at all.** Opal's compiled output and its own JavaScript runtime
now assume an ES2021-capable engine. The linting target moved from `ecmaVersion: 3` to
`ecmaVersion: 2021` (`eslint.config.mjs`).

If you target an old JavaScript engine — an embedded engine, an old JVM engine, IE, or anything
pre-2021 — 2.0 output will not run there. There is no fallback and no transpilation step provided.
This is also the underlying reason Nashorn was dropped.

**Action**: confirm your deployment target supports ES2021, or stay on Opal 1.x.

### The Nashorn runner and stdlib were removed

Three separate things went away:

| Removed | Detection |
|---|---|
| CLI runner `-R nashorn` | `OptionParser::InvalidArgument` — `invalid argument: -R nashorn` |
| `require 'nashorn'` (and `nashorn/file`, `nashorn/io`) | A missing-require build error |
| `OPAL_PLATFORM == 'nashorn'` | **Silent** — the platform dispatch branch is gone, so it falls through to the browser default |

Old:

```console
$ opal -R nashorn app.rb
```

New — pick any other runner:

```console
$ opal -R nodejs app.rb    # or bun, deno, quickjs, gjs, miniracer, chrome, firefox, safari, server
```

No shim, no deprecation period. Nashorn was ES5.1-only, unmaintained, and removed from recent JDKs.
See [runners](runners.html).

### `Kernel#taint`, `#untaint`, `#tainted?` removed

These were previously defined as no-ops in `opal/corelib/unsupported.rb` and routed through
`handle_unsupported_feature`. They have been deleted, matching CRuby, which removed them in 3.2.

Old behaviour: a warning (`Object tainting is not supported by Opal`) or `NotImplementedError`
depending on `Opal.config.unsupported_features_severity`, then a return value.

New behaviour — a plain `NoMethodError` via `method_missing`:

```console
$ opal -e 'p "a".taint'
-e:1:6:in `undefined': undefined method `taint' for "a" (NoMethodError)
```

**Action**: delete the calls. This is intentional and permanent.

### `Opal::Builder#preload` and `#prerequired` removed

Old:

```ruby
builder = Opal::Builder.new
builder.preload << 'some_file'
builder.prerequired << 'other_file'
```

New:

```ruby
builder = Opal::Builder.new
builder.build_require('some_file')   # replaces preload
builder.stubs << 'other_file'        # closest replacement for prerequired
```

Detection: `NoMethodError: undefined method 'preload' for #<Opal::Builder...>`.

**Note the asymmetry**: the CLI's `-p` / `--preload` flag still exists and still works. It is now
implemented as `preload.each { |path| builder.build_require(path) }` in `lib/opal/cli.rb`. Only the
`Builder` attribute was removed, not the flag.

### Builder files and constants moved under `Opal::Builder`

| Old require path | New require path |
|---|---|
| `opal/builder_processors` | `opal/builder/processor` |
| `opal/builder_scheduler` | `opal/builder/scheduler` |
| `opal/builder_scheduler/prefork` | `opal/builder/scheduler/prefork` |
| `opal/builder_scheduler/sequential` | `opal/builder/scheduler/sequential` |

The constants moved too — they are now nested inside `Opal::Builder`:

| Old constant | New constant |
|---|---|
| `Opal::BuilderProcessors` | `Opal::Builder::Processor` |
| `Opal::BuilderScheduler` | `Opal::Builder::Scheduler` |
| `Opal::BuilderScheduler::Prefork` | `Opal::Builder::Scheduler::Prefork` |
| `Opal::BuilderScheduler::Sequential` | `Opal::Builder::Scheduler::Sequential` |

Detection: `LoadError: cannot load such file -- opal/builder_processors`, then `NameError`. No
compatibility files or constant aliases were added.

### Runtime helper `$prepend` renamed to `$prepend_ary`

The internal runtime helper and its public alias were renamed to disambiguate from `Module#prepend`.

| Old | New |
|---|---|
| `Opal.prepend(x, args)` | `Opal.prepend_ary(x, args)` |
| `# helpers: prepend` | `# helpers: prepend_ary` |

Detection: `TypeError: Opal.prepend is not a function`, or a compile-time failure to resolve the
helper named in a `# helpers:` magic comment.

No alias was retained. This only affects code reaching into runtime internals or hand-written
`%x{}` blocks that request helpers — rare, but easy to miss.

### The runtime moved out of `opal/corelib/runtime.js`

The monolithic `opal/corelib/runtime.js` is gone. The runtime now lives in `opal/runtime/`, split
across modules (`boot.js`, `hash.rb`, `send.rb`, `string.rb`, `array.rb`, and many more), with
`opal/runtime/runtime.rb` as the entry point.

- `require`-level access is shimmed: `opal/corelib/runtime.rb` is a one-line file requiring the new
  location, so `require 'opal/corelib/runtime'` still works.
- **Path-level access is a hard break.** Any build script, vendoring step, patch, or source-map
  config that names `opal/corelib/runtime.js` will fail with file-not-found.

Detection: file-not-found in a build script, or source maps pointing at a nonexistent file.

> Beyond `$prepend` → `$prepend_ary`, this guide does not claim that every other `Opal.*` runtime
> export kept its name through the split. If you depend on undocumented `Opal.*` internals, diff the
> export surface yourself before upgrading.

### `bin/opal-mspec` replaced by `bin/test`

**Contributors only.** This script lives in `bin/`, not `exe/`, so it is not installed by the gem —
it affects people working in an Opal git checkout, not gem consumers.

Old:

```console
$ bin/opal-mspec spec/opal/core/array/compact_spec.rb
```

New:

```console
$ bin/test spec/opal/core/array/compact_spec.rb
```

`bin/test` dispatches on the path and handles all four suites — RSpec (`spec/lib/...`), MSpec/Ruby
(`spec/ruby/...`), MSpec/Opal (`spec/opal/...`), and Minitest (`test/opal/...`) — and tolerates a
missing `spec/` or `test/` prefix.

Detection: `No such file or directory: bin/opal-mspec`.

---

## Soft breaks (shim present, warning emitted)

### `JS` module renamed to `Opal::Raw`

The `JS` module — `typeof`, `instanceof`, `new`, `delete`, `void`, `in`, `global`, `call` — is now
`Opal::Raw`, and the require path moved from `js` to `opal/raw`.

Old:

```ruby
require 'js'

JS.typeof(x)
JS.new(`Date`)
```

New:

```ruby
require 'opal/raw'

Opal::Raw.typeof(x)
Opal::Raw.new(`Date`)
```

`stdlib/js.rb` still exists and defines `module JS; extend Opal::Raw; include Opal::Raw; end`, so old
code keeps working in 2.0. Requiring it warns:

```text
[Opal] JS module has been renamed to Opal::Raw and will change semantics in Opal 2.1. In addition, you will need to require "opal/raw" instead of "js". To ensure forward compatibility, please update your calls.
```

**The hard removal lands in Opal 2.1, not 2.0.** The shim is present and functional throughout 2.0.
Rename now so 2.1 is a no-op for you.

See [the JavaScript interface](js_interface.html).

### `JS::Error` renamed to `Opal::Raw::Error`

Old:

```ruby
begin
  do_something
rescue JS::Error => e
  handle(e)
end
```

New:

```ruby
begin
  do_something
rescue Opal::Raw::Error => e
  handle(e)
end
```

The shim is a `JS.const_missing` hook in **corelib** (`opal/corelib/error.rb`), so it is active even
without `require 'js'`. It handles only `:Error`; any other constant on `JS` falls through to `super`
and raises `NameError`. Resolving `JS::Error` warns:

```text
[Opal] JS::Error class has been renamed to Opal::Raw::Error and will change semantics in Opal 2.1. To ensure forward compatibility, please update your rescue clauses.
```

**Again: the hard removal is scheduled for Opal 2.1, not 2.0.**

### Backtick / `%x{}` JavaScript needs a magic comment

Not new in 2.0 — this deprecation shipped in 1.8.0 — but it is the one 1.x users hit most, and its
warning names 2.0 explicitly. Any file using `` `...` `` or `%x{...}` to embed JavaScript should
declare it:

```ruby
# backtick_javascript: true

def now
  `Date.now()`
end
```

Without the magic comment, compiling warns once per compiler instance:

```text
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- app.rb:1
```

> The warning says "will break in Opal 2.0". At 2.0.0dev the default has **not** in fact been flipped
> — the code still compiles and only warns. Treat the exact release in which this becomes an error as
> unsettled, and add the magic comment regardless: it silences the warning today and is required
> whenever the flip happens.

See [compiler directives](compiler_directives.html).

### `Opal.hash2` and `Opal.hash_init` deprecated

Both are JavaScript-side runtime functions. Warnings go to `console.warn`, so they appear in the JS
console or the runner's stderr — **not** through Ruby's `Kernel#warn`, and so `Opal.raise_on_deprecation`
does not catch them.

| Function | Status | Warning |
|---|---|---|
| `Opal.hash2(keys, smap)` | Still functional; builds a `Map` | ``DEPRECATION: `Opal.hash2` is deprecated and will be removed in Opal 2.0. Use $hash_new for primitive keys or $hash_new2 for complex keys instead.`` |
| `Opal.hash_init(_hash)` | **Now a no-op** | `DEPRECATION: Opal.hash_init is deprecated and is now a no-op.` |

`Opal.hash_init` becoming a no-op is a silent behaviour change for anyone who relied on it doing
something.

**Action**: replace `Opal.hash2` with `$hash_new` for primitive keys or `$hash_new2` for complex
keys. Delete `Opal.hash_init` calls.

> The `hash2` warning text says "will be removed in Opal 2.0", but the function is still present at
> 2.0.0dev. The text and the code disagree; do not read the message as an authoritative removal date.

### `Opal::Server` deprecated

This deprecation pre-dates 1.8.1 and is still not removed in 2.0. Listed here because 1.x users
upgrading are likely to encounter it.

Old:

```ruby
require 'opal/server'
Opal::Server.new { |s| ... }
```

New:

```ruby
require 'opal/sprockets/server'
Opal::Sprockets::Server.new { |s| ... }
```

Warning:

```text
DEPRECATION WARNING: `require 'opal/server` and `Opal::Server` are deprecated in favor of `require 'opal/sprockets/server'` and `Opal::Sprockets::Server` (now part of the opal-sprockets gem).
```

`Opal::Server` remains assigned as an alias, so old code still works. `Opal::Sprockets::Server` now
lives in the **opal-sprockets** gem. For local development without Sprockets, consider
`Opal::SimpleServer` (`lib/opal/simple_server.rb`), a dependency-light Rack server, or the
[`server` runner](runners.html).

### `Compiler#requires <<` superseded by `Compiler#track_require`

Affects compiler plugins and custom `CallNode` specials.

Old:

```ruby
compiler.requires << 'some/path'
```

New:

```ruby
compiler.track_require 'some/path'
```

`track_require` is currently defined as `def track_require(mod); requires << mod; end` and `requires`
is still readable, so the old pattern still functions. This is a change of preferred API, not a
removal — but use `track_require` so future changes to require tracking do not break you.

---

## Silent behaviour changes

These are bug fixes rather than removals, but they change results for existing code. None of them
warn. **Re-run your test suite.**

| Change | Effect |
|---|---|
| `Enumerable#first` on an empty collection | Now returns `nil`. Previously returned the `each` return value. |
| `Array#include?` | Now respects a `nil` return from `==`; results can flip for objects with unusual `==`. |
| `Module#include` after `#prepend` | Ancestor order corrected. |
| `String#strip`, `#lstrip`, `#rstrip` | Now MRI-compatible for non-breaking whitespace; strings that previously kept a NBSP now differ. |
| `Hash#to_n` | Returns a JS object again (fixes a 1.8.0 regression). |
| `String#chars`, Regexp astral planes | Surrogate-pair handling changed, and a `u` flag is now always added to the generated JS `RegExp`. Existing regexps can match differently. |
| `#hash` | Values differ from 1.x. Never persist Ruby hash values across Opal versions. |
| `defined?(CONST)` where the constant is `0` | Now correctly reports `"constant"`. |
| `Time.at` gained a `unit` argument | Additive, but changes arity expectations for wrappers. |
| String interpolation (`$dstr`) | Now routes through `String#+` and returns an unfrozen String; frozen-ness of interpolation results changed. |
| `Opal.bridge` with JS subclasses | Identifies Classes/Modules in more forms; bridges that previously failed now succeed. |
| `Object#method` for `method_missing` methods | Returns a `Method` where it previously raised. |
| `Kernel#freeze` on singleton classes | `frozen?` now also consults (singleton) classes. |
| `Array#compact`, `Hash#compact` | Now also remove JS `null` and `undefined`, not just Ruby `nil`. |

Dependency change: the `glob` npm package was replaced by `picomatch`. This may matter if you bundle
Opal's Node-side dependencies yourself.

## New in 2.0

Not breaking, but worth knowing while you upgrade.

| Feature | Docs |
|---|---|
| `--dce` — experimental dead code elimination | [CLI reference](cli.html) |
| `--compile-to-exe` — standalone executables | [CLI reference](cli.html) |
| `--directory` — directory-mode builds | [directory mode](../how-to/directory_mode.html) |
| `--await` — async/await support | [async](../explanation/async.html) |
| `Opal::Project` and the `Opalfile` DSL | [Opalfile](../how-to/opalfile.html) |
| `bun` and `deno` runners | [runners](runners.html) |
| Threaded build scheduler; JRuby and TruffleRuby support | — |
| Builder postprocessor subsystem | — |
| `Module#deprecate_constant`, `IO::Buffer`, EUC-JP/JIS/Shift_JIS encodings, float `pack`/`unpack`, `fork()` on Node, `nodejs/tmpdir`, BigDecimal `power`/`fix`/`trunc` | — |

## Full deprecation-warning inventory

Every deprecation message a 1.x user may encounter, with its channel.

### Ruby-side, via `Opal.deprecation`

Prefixed with `DEPRECATION WARNING:` and a space. Set `Opal.raise_on_deprecation = true` to raise instead.

| Message |
|---|
| ``` `require 'opal/server` and `Opal::Server` are deprecated in favor of `require 'opal/sprockets/server'` and `Opal::Sprockets::Server` (now part of the opal-sprockets gem). ``` |

### Compiler warnings

Prefixed with `warning:` and a space, suffixed with `-- file:line`.

| Message |
|---|
| ``` Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` ``` |
| `Both \A or \z and ^ or $ used in a regexp ... In Opal this will cause undefined behavior.` |

### CLI warnings

| Message |
|---|
| `* -V is deprecated and has no effect` |
| `Overwriting Opal CLI runner: NAME` |
| `warning: ARGV is not supported by the Chrome runner [...]` |
| `warning: ARGV is not supported by the Safari runner [...]` |
| ``` Opal: paths for gems are not available in JavaScript. The directive `use_gem NAME` has been ignored. ``` |
| `Warning: <message>` (missing require, when `missing_require_severity` is `:warning`) |
| `Couldn't find a writable path to store Opal cache. ...` |

### Runtime, via JavaScript `console.warn`

| Message |
|---|
| ``` DEPRECATION: `Opal.hash2` is deprecated and will be removed in Opal 2.0. Use $hash_new for primitive keys or $hash_new2 for complex keys instead. ``` |
| `DEPRECATION: Opal.hash_init is deprecated and is now a no-op.` |

### Corelib and stdlib, from Opal-compiled code

| Message |
|---|
| `[Opal] JS module has been renamed to Opal::Raw and will change semantics in Opal 2.1. In addition, you will need to require "opal/raw" instead of "js". To ensure forward compatibility, please update your calls.` |
| `[Opal] JS::Error class has been renamed to Opal::Raw::Error and will change semantics in Opal 2.1. To ensure forward compatibility, please update your rescue clauses.` |
| `DEPRECATION: math is now part of the core library, requiring it is deprecated` |
| `DEPRECATION: encoding is now part of the core library, requiring it is deprecated` |
| `Including ::Native is deprecated. Please include Native::Wrapper instead.` |
| `BigDecimal.new is deprecated; use BigDecimal() method instead.` |
| `Requiring nodejs/stacktrace has been deprecated, if you use the default ...` |

Opal's `matrix` and `optparse` stdlib files also emit deprecations (`Matrix#determinant_e`,
`Matrix#rank_e`, `Matrix#elements_to_*`, `Vector#elements_to_*`). These are inherited verbatim from
MRI's stdlib and are not Opal-specific migration items.

## See also

- [CLI reference](cli.html)
- [Configuration reference](config.html)
- [Runners](runners.html)
