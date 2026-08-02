# Opal CLI Reference

Complete reference for the `opal` executable, as of Opal 2.0.

```text
Usage: opal [options] -- [programfile]
```

Options are defined in `lib/opal/cli_options.rb`. Anything after `--` is passed to the compiled
program as `ARGV`.

## Gotchas

Read this first. Several short flags do not mean what their letter suggests.

| Flag | What you might expect | What it actually is |
|---|---|---|
| `-O` | output | `--no-opal` — disables the implicit `require "opal"`. **Output is lowercase `-o`.** |
| `-P` | (unclear) | `--map FILE` — write the source map to FILE |
| `-M` | map | `--no-method-missing` |
| `-D` | debug | `--dynamic-require LEVEL`. Debug is lowercase `-d`. |
| `-q` | quiet | `--rbrequire` — require a library in the *Ruby* (compiler host) context |
| `-V` | version | Deprecated and inert. `--version` has no short form. |
| `-v` | verbose | Prints the version first, and **exits** if no other arguments follow |
| `-c` | sets a "compile" option | Selects the `compiler` runner; does not set `options[:compile]` |
| `-L` | (unclear) | Compound flag; sets four options at once (see below) |

## General

| Long | Short | Argument | Effect |
|---|---|---|---|
| `--repl` | — | — | Start the Opal REPL. |
| `--compile-to-exe RUNTIME` | — | required, constrained | Build a standalone executable. Also forces the runner to `compiler` and, unless `-o` was already given, sets the output filename to `opal_<RUNTIME>_exe`. |
| `--verbose` | `-v` | — | Print the version, then enable verbose mode. **Exits immediately if nothing else is on the command line.** |
| `--debug` | `-d` | — | Turn on debug mode (sets `$DEBUG`). |
| `--version` | — | — | Print `Opal v<VERSION>` and exit. |
| `--help` | `-h` | — | Print usage and exit. |

Valid `--compile-to-exe` runtimes come from `Opal::ExeCompiler::RUNTIMES`: `bun`, `deno`, `node`,
`quickjs`, plus `osascript` **on macOS only**.

> Known source issue: `--verbose` is registered twice in `cli_options.rb` (once with `-v`, once
> alone) with differing behaviour — the `-v` form prints the version and may exit. Treat the long
> form's behaviour as unspecified until this is fixed.

## Basic options

| Long | Short | Argument | Repeatable | Effect |
|---|---|---|---|---|
| `--eval SOURCE` | `-e` | String | yes | One line of script. Omit `[programfile]`. |
| `--require LIBRARY` | `-r` | String | yes | Require LIBRARY **inside the compiled Opal program**. |
| `--rbrequire LIBRARY` | `-q` | String | yes | Require LIBRARY **in the Ruby compiler host** — this is how you load a compiler plugin. |
| `--include DIR` | `-I` | DIR | yes | Append a load path. |
| `--stub FILE` | `-s` | String | yes | Compile FILE as an empty file (mark it as loaded and skip it). |
| `--preload FILE` | `-p` | String | yes | Prepare FILE for dynamic requires. |
| `--gem GEM_NAME` | `-g` | String | yes | Add GEM_NAME's load paths to Opal's load path. |

`-r` vs `-q` is the most common mix-up: `-r` affects the program you are compiling, `-q` affects the
compiler process itself.

## Running options

| Long | Short | Argument | Default | Effect |
|---|---|---|---|---|
| `--runner RUNNER` | `-R` | constrained to registered runner names | `nodejs` | Choose the JavaScript runner. See [runners](runners.html). |
| `--server-port PORT` | — | integer | 3000 | Port for the `server` runner. Sets `runner_options[:port]`. |
| `--runner-options JSON` | — | JSON string | — | Merge arbitrary options into `runner_options`. Parsed with `symbolize_names: true`. |

The set of valid `-R` values is **platform-dependent** — `opal --help` prints a different list on
macOS, Linux, and Windows. An unrecognised name raises `OptionParser::InvalidArgument`:

```console
$ opal -R bogus -e 'puts 1'
invalid argument: -R bogus (OptionParser::InvalidArgument)
```

Malformed `--runner-options` JSON raises an uncaught `JSON::ParserError`.

## Builder options

| Long | Short | Argument | Effect |
|---|---|---|---|
| `--compile` | `-c` | — | Compile to JavaScript instead of running. Selects the `compiler` runner. |
| `--output FILE` | `-o` | FILE | Write JavaScript to FILE. A **directory** when `--directory` is enabled. |
| `--map FILE` | `-P` | FILE | Write the source map to FILE. |
| `--no-source-map` | — | — | Do not append a source map to the compiled file. |
| `--watch` | — | — | Stay in the foreground and recompile on every filesystem change. |
| `--no-cache` | — | — | Disable the filesystem compile cache. |
| `--library` | `-L` | — | Compile only required libraries. Omit `[programfile]` and `-e`. Help text says "Assumed `[-cOE]`". |
| `--no-opal` | `-O` | — | Disable the implicit `require "opal"`. |
| `--no-exit` | `-E` | — | Do not append a trailing `Kernel#exit`. |
| `--dce [OPTIONS]` | — | **optional**, comma-separated | EXPERIMENTAL dead code elimination. Bare `--dce` means `method`. Documented values: `method`, `const`. |

`-L` is compound: it sets `lib_only`, `no_exit`, `compile`, and `skip_opal_require`. It is the only
place `options[:compile]` is assigned — `-c` does not set it.

`--dce` takes an **optional** argument, so `opal --dce foo.rb` consumes `foo.rb` as the option value
rather than as the program file. Put `--dce` last, or use `--dce=method`. Values are not validated:
`--dce bogus` silently yields `[:bogus]`.

## Compiler options

| Long | Short | Argument | Default | Effect |
|---|---|---|---|---|
| `--use-strict` | — | — | off | Add a `'use strict';` statement to the output. |
| `--esm` | — | — | off | Wrap the compiled bundle as an ES6 module. |
| `--directory` | — | — | off | Build the program as a directory of JS files. Pairs with `-o`. See [directory mode](../how-to/directory_mode.html). |
| `--arity-check` | `-A` | — | off | Enable runtime arity checks on methods, procs, and lambdas. |
| `--dynamic-require LEVEL` | `-D` | `error`, `warning`, `ignore` | **`warning`** | Severity when a `require` cannot be resolved at compile time. |
| `--missing-require LEVEL` | — | `error`, `warning`, `ignore` | `error` | Severity when a required file is not found at build time. |
| `--enable-source-location` | — | — | off | Compile source location for each method definition. |
| `--parse-comments` | — | — | off | Compile comments for each method definition. |
| `--enable-file-source-embed` | — | — | off | Embed file sources so applications can read them. |
| `--irb` | — | — | off | Enable IRB var mode (locals persist across compilations). |
| `--await` | — | — | off | Enable async/await support. See [async](../explanation/async.html). |
| `--no-method-missing` | `-M` | — | on | Disable `method_missing` dispatch. |
| `--file FILE` | `-F` | FILE | — | Set the *reported* filename for the compiled code. |
| — | `-V` | — | — | **Deprecated, no effect.** Warns `* -V is deprecated and has no effect`. |

> `-D`'s help text says "(default: error)". This is wrong — `Opal::Config.dynamic_require_severity`
> defaults to `:warning` (`lib/opal/config.rb:117`). The help string is a known source bug.

`--parse-comments`, `--await`, and `--use-strict` have no `Opal::Config` counterpart; they are
CLI-only compiler options. Everything else maps onto a config option — see
[config reference](config.html).

## Debug options

| Long | Argument | Effect |
|---|---|---|
| `--sexp` | — | Print the S-expressions instead of compiling. |
| `--debug-source-map` | — | Debug source map generation. |

## Common invocations

All of these were run against Opal 2.0.0dev.

Run a one-liner on Node:

```console
$ opal -e 'puts "hi #{RUBY_ENGINE}"'
hi opal
```

Compile to stdout:

```console
$ opal -c -e 'puts 1' | head -2
(function(global_object) {
  "use strict";
```

Compile to a file:

```console
$ opal -c -e 'puts 1' -o app.js
```

Compile without the corelib (`-O`), producing a much smaller fragment:

```console
$ opal -c -O -e 'puts 1' | head -2
Opal.queue(function(Opal) {/* Generated by Opal 2.0.0dev */
  var self = Opal.top, nil = Opal.nil;
```

Load a compiler plugin in the Ruby host, then compile:

```console
$ opal -q json -e 'puts 2'
2
```

Compile a library bundle only:

```console
$ opal -L -r my_library -o my_library.js
```

Serve a build over HTTP for browser testing:

```console
$ opal -R server --server-port 4000 app.rb
```

Compile with a separate source map file:

```console
$ opal -c app.rb -o app.js -P app.js.map
```

Build a standalone executable:

```console
$ opal --compile-to-exe node app.rb
```

## See also

- [Runners](runners.html) — every `-R` target
- [Configuration reference](config.html) — `Opal::Config` equivalents
- [Compiler directives](compiler_directives.html) — magic comments
- [Migrating to Opal 2.0](migration_2_0.html)
