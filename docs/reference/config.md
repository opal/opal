# Opal::Config Reference

`Opal::Config` is a process-global singleton holding compiler and builder defaults. It is defined in
`lib/opal/config.rb`. Every option is read and written as a singleton attribute:

```ruby
Opal::Config.arity_check_enabled          # => false
Opal::Config.arity_check_enabled = true
```

`Opal::Config` is the *global* layer. Per-build overrides are passed directly to
`Opal::Compiler.new` / `Opal::Builder.new`, and the CLI passes its flags that way rather than
mutating the global config.

## Options

Type "Boolean" means the writer accepts only `true` or `false`.

| Option | Type | Default | Compiler option | CLI flag | Effect |
|---|---|---|---|---|---|
| `method_missing_enabled` | Boolean | `true` | `:method_missing` | `-M` disables | Emit `method_missing` dispatch stubs. |
| `const_missing_enabled` | Boolean | `true` | `:const_missing` | none | Emit `const_missing` support. |
| `arity_check_enabled` | Boolean | `false` | `:arity_check` | `-A` | Runtime arity checks on methods, procs, and lambdas. |
| `freezing_stubs_enabled` | Boolean | `true` | `:freezing` | none | Add freeze-related method stubs for compatibility. |
| `esm` | Boolean | `false` | `:esm` | `--esm` | Emit ECMAScript modules instead of legacy JS. |
| `directory` | Boolean | `false` | `:directory` | `--directory` | Build as a directory of JS files instead of one bundle. |
| `dynamic_require_severity` | `:error`, `:warning`, `:ignore` | `:warning` | `:dynamic_require_severity` | `-D` | Severity when a `require` cannot be resolved at compile time (e.g. `require "foo" + x`). |
| `missing_require_severity` | `:error`, `:warning`, `:ignore` | `:error` | — (builder) | `--missing-require` | Severity when a required file is not found at build time. |
| `irb_enabled` | Boolean | `false` | `:irb` | `--irb` | Persist local variables across compilations (REPL mode). |
| `inline_operators_enabled` | Boolean | `true` | `:inline_operators` | `-V` (deprecated, inert) | Inline-operator optimisation. |
| `source_map_enabled` | Boolean | `true` | — (builder) | `--no-source-map` | Generate source maps. |
| `enable_source_location` | Boolean | `false` | `:enable_source_location` | `--enable-source-location` | Embed source location for methods and procs. |
| `enable_file_source_embed` | Boolean | `false` | `:enable_file_source_embed` | `--enable-file-source-embed` | Embed file source text for runtime access. |
| `stubbed_files` | `Set` | empty `Set` | — (builder) | `-s` | Files marked as loaded and skipped during compilation. |

### Compiler options vs. builder options

Eleven options carry a `compiler_option:` name and are forwarded to `Opal::Compiler` by
`Opal::Config.compiler_options`. Three do **not**:

- `missing_require_severity` — consumed by `Opal::Builder` when resolving requires
- `source_map_enabled` — consumed by the builder / CLI runner layer
- `stubbed_files` — consumed by `Opal::Builder`

> Known source issue: because all three declare `compiler_option: nil`,
> `Opal::Config.compiler_options` emits a hash where all three collide on a single `nil` key and the
> last one wins. Not user-facing, but do not rely on the shape of that hash.

### `stubbed_files` is meant to be mutated

The default value is created lazily by a `Proc`, and the documented usage (per the comment in
`config.rb`) is in-place mutation:

```ruby
Opal::Config.stubbed_files << 'some/heavy/dependency'
```

Replacing it with another `Set` is also permitted, but any other type raises (see below).

## Validation

Every writer validates its argument against the option's `valid_values` list using `===`. Boolean
options accept exactly `[true, false]`; the severity options accept their three symbols;
`stubbed_files` accepts anything that is a `Set`.

An invalid assignment raises:

```text
ArgumentError: Not a valid value for option Opal::Config.NAME, provided VALUE. Must be VALID_VALUES === VALUE
```

Note this means truthy-but-not-`true` values are rejected:

```ruby
Opal::Config.esm = 1
# ArgumentError: Not a valid value for option Opal::Config.esm, provided 1. Must be [true, false] === 1
```

## Resetting

```ruby
Opal::Config.reset!
```

Discards all overrides and restores every option to its default. Useful between test cases.

## Options with no `Opal::Config` counterpart

These are accepted by the CLI and by `Opal::Compiler` directly, but have no global config option:

| Compiler option | CLI flag |
|---|---|
| `:parse_comments` | `--parse-comments` |
| `:await` | `--await` |
| `:use_strict` | `--use-strict` |

## Runtime (JavaScript-side) configuration

Separate from `Opal::Config`, the compiled runtime exposes `Opal.config` in JavaScript. The one
option a Ruby author is likely to care about:

| Key | Default | Valid values | Effect |
|---|---|---|---|
| `unsupported_features_severity` | `'warning'` | `'error'`, `'warning'`, `'ignore'` | How the runtime reacts when unsupported functionality is invoked (e.g. the mutable-`String` stubs). |

Set it from Ruby before the affected code runs:

```ruby
# backtick_javascript: true
`Opal.config.unsupported_features_severity = 'error'`
```

See [unsupported features](unsupported_features.html).

## Deprecation behaviour

Not part of `Opal::Config`, but adjacent and useful in CI:

```ruby
Opal.raise_on_deprecation = true   # default: false
```

When enabled, Ruby-side `Opal.deprecation` calls raise instead of printing
`DEPRECATION WARNING: ...`. Recommended for CI while migrating — see
[Migrating to Opal 2.0](migration_2_0.html).

## See also

- [CLI reference](cli.html)
- [Compiler directives](compiler_directives.html) — per-file magic comments
- [Unsupported features](unsupported_features.html)
