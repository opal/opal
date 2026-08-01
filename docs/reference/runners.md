# CLI Runners

A *runner* is what Opal hands the compiled JavaScript to. Select one with `-R NAME` /
`--runner NAME`:

```console
$ opal -R deno app.rb
```

The default is `nodejs`. Runners are registered in `lib/opal/cli_runners.rb` and implemented in
`lib/opal/cli_runners/*.rb`.

## The available set is platform-dependent

`Opal::CliRunners` registers a different set of runners depending on the host OS, so `opal --help`
prints a different `-R` list on macOS, Linux, and Windows. An unrecognised name raises
`OptionParser::InvalidArgument`.

| Runner | macOS | Linux/BSD | Windows |
|---|---|---|---|
| `nodejs` / `node` | yes | yes | yes |
| `bun` | yes | yes | yes |
| `deno` | yes | yes | yes |
| `quickjs` | yes | yes | yes |
| `chrome` | yes | yes | yes |
| `firefox` | yes | yes | yes |
| `server` | yes | yes | yes |
| `compiler` | yes | yes | yes |
| `gjs` | — | yes | — |
| `miniracer` | yes | yes | — |
| `applescript` / `osascript` | yes | — | — |
| `safari` | yes | — | — |

## JavaScript engine runners

| Name | Prerequisite | Env overrides | Notes |
|---|---|---|---|
| `nodejs` (**default**) | `node` on `PATH` | `NODE_OPTS`, `NODE_FLAME` | Sets `NODE_PATH` to Opal's bundled `stdlib/nodejs/node_modules`. Installs Node source-map support. Raises `MissingNodeJS` if `node` is absent. |
| `node` | — | — | Alias of `nodejs`. |
| `bun` | `bun` on `PATH` | `BUN_OPTS` | Raises `MissingBun` if absent. |
| `deno` | `deno` on `PATH` | `DENO_OPTS` | Raises `MissingDeno` if absent. |
| `quickjs` | `qjs` binary | `QJS_PATH`, `QJS_OPTS` | `QJS_PATH` overrides the executable name. Raises `MissingQuickjs` if absent. |
| `gjs` | `gjs` (GNOME JS) binary | `GJS_PATH`, `GJS_OPTS` | Linux/BSD only. Raises `MissingGjs` if absent. |
| `miniracer` | `mini_racer` gem | — | In-process V8, no subprocess. Sets the V8 `harmony` flag. `ARGV` is accepted but not yet forwarded to the program (marked `TODO` in source). Not available on Windows. |
| `applescript` | macOS Yosemite or later, `osalang` on `PATH` | — | JavaScript for Automation. Raises `MissingJavaScriptSupport` if `osalang` is missing, `MissingAppleScript` off macOS. |
| `osascript` | — | — | Alias of `applescript`. macOS only. |

All the subprocess-based engine runners share `lib/opal/cli_runners/system_runner.rb`, which is a
helper and is not itself registered as a runner.

## Browser runners

These drive a real browser headlessly. `chrome` and `firefox` speak the Chrome DevTools Protocol via
the shared `cdp_interface.rb`. See also [headless browsers](../how-to/headless_browsers.html) and
[CDP common options](cdp_common.html).

| Name | Prerequisite | Default host:port | Env overrides |
|---|---|---|---|
| `chrome` | Chrome or Chromium | `localhost:9222` | `GOOGLE_CHROME_BINARY`, `CHROME_HOST`, `CHROME_PORT`, `CHROME_OPTS`, or the generic `OPAL_CDP_HOST` / `OPAL_CDP_PORT` |
| `firefox` | Firefox 130 or later | `localhost:9333` | `MOZILLA_FIREFOX_BINARY`, `FIREFOX_HOST`, `FIREFOX_PORT`, `FIREFOX_OPTS`, or `OPAL_CDP_HOST` / `OPAL_CDP_PORT` |
| `safari` | macOS, Safari, `safaridriver` | `localhost:9444` | `SAFARI_DRIVER_HOST`, `SAFARI_DRIVER_PORT`, `SAFARI_DRIVER_OPTS` |

Notes:

- **`ARGV` is not supported** by `chrome`, `firefox`, or `safari`. Passing program arguments prints
  e.g. `warning: ARGV is not supported by the Chrome runner ["foo"]` and the arguments are dropped.
- If a browser is already listening on the configured CDP port, the runner attaches to it instead of
  launching its own. Launching its own is only possible when the host is `localhost`.
- Firefox 130+ requires the remote protocols to be explicitly enabled in the profile prefs; the
  runner writes those prefs into a throwaway profile for you.
- The Safari runner also starts a local HTTP server (on `safari_driver_port + 1`) to serve the build.

### Chrome executable auto-discovery

The Chrome runner honours `GOOGLE_CHROME_BINARY` first. Otherwise it probes, in order
(`lib/opal/cli_runners/chrome.rb:193-223`):

| Platform | Probed paths |
|---|---|
| macOS | `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`, then `/Applications/Chromium.app/Contents/MacOS/Chromium` |
| Windows | `C:/Program Files/Google/Chrome Dev/Application/chrome.exe`, then `C:/Program Files/Google/Chrome/Application/chrome.exe` |
| other | `google-chrome-stable`, `chromium`, `chromium-freeworld`, `chromium-browser` on `PATH`; raises `Cannot find chrome executable` if none is found |

The macOS behaviour surprises people: **the runner looks in `/Applications` by absolute path, not on
`PATH`.** A Chrome installed under `~/Applications`, or via a package manager that only puts it on
`PATH`, will not be found — set `GOOGLE_CHROME_BINARY` explicitly.

Firefox does the equivalent, probing `/Applications/Firefox.app/Contents/MacOS/Firefox` and the
lowercase `firefox` variant on macOS.

If the browser cannot be started within 30 seconds the runner prints `Failed to start chrome server`
and exits with status 1.

## Non-executing runners

| Name | Prerequisite | Notes |
|---|---|---|
| `compiler` | none | Does not execute anything — writes the compiled JavaScript to `-o` or stdout. Selected implicitly by `-c`, `-L`, and `--compile-to-exe`, so you rarely name it directly. |
| `server` | a Rack-capable environment and a browser | Serves the build over HTTP so you can open it yourself. |

### The `server` runner

| Setting | Source, in order of precedence | Default |
|---|---|---|
| port | `runner_options[:port]` (via `--server-port` or `--runner-options`), `OPAL_CLI_RUNNERS_SERVER_PORT` | `3000` |
| static folder | `runner_options[:static_folder]`, `OPAL_CLI_RUNNERS_SERVER_STATIC_FOLDER` | none (if set to `true`, becomes `public`) |

Program arguments are rejected: passing them raises
`ArgumentError: Program arguments are not supported on the Server runner`.

```console
$ opal -R server --server-port 4000 app.rb
```

## Removed runners

| Name | Removed in | Replacement |
|---|---|---|
| `nashorn` | 2.0 | Any other runner. Nashorn was ES5.1-only, unmaintained, and dropped from recent JDKs. See [Migrating to Opal 2.0](migration_2_0.html). |

`require 'nashorn'` and the `'nashorn'` value of `OPAL_PLATFORM` were removed at the same time.

## Registering a custom runner

```ruby
Opal::CliRunners.register_runner(:my_runner, MyRunner)
```

Or with autoloading, which is how the built-in runners are declared:

```ruby
Opal::CliRunners.register_runner(:my_runner, :MyRunner, 'path/to/my_runner')
```

The runner must respond to `.call(data)`, where `data` is a Hash with:

| Key | Value |
|---|---|
| `:options` | Hash of runner options (from `--runner-options`, `--server-port`, etc.) |
| `:output` | An IO-like object responding to `#write` and `#puts` |
| `:argv` | Arguments forwarded from the CLI to the program |
| `:builder` | A **proc** returning a fresh `Opal::Builder`, so it can be re-created to pick up the newest sources |

Call `data[:builder].call` to get the builder — this is what makes `--watch` work.

Alias an existing name:

```ruby
Opal::CliRunners.alias_runner(:my_alias, :my_runner)
```

Re-registering an existing name warns `Overwriting Opal CLI runner: NAME`.

`Opal::CliRunners::RunnerError < StandardError` is the base class for runner failures; the
"missing engine" errors above all subclass it.

To make a custom runner available to the `opal` executable, load it with `-q`:

```console
$ opal -q ./my_runner -R my_runner app.rb
```

## See also

- [CLI reference](cli.html)
- [Headless browsers](../how-to/headless_browsers.html)
- [Migrating to Opal 2.0](migration_2_0.html)
