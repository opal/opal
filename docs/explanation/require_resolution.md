# How Requires Are Resolved

A require in Opal is resolved twice: once at compile time, to find the file on
disk, and once at runtime, to find the module that file became. The two happen
in different languages, in different processes, possibly on different machines —
and they have to agree on one string, the module name.

## The two halves

**Compile time.** `Opal::PathReader#expand` turns a require string into a path on
disk, searching the load path (`Opal.paths`) and, for a leading `./`, an
optional working directory — see below. Absolute paths and paths starting with
`../` are returned verbatim, since the load path cannot express them.

**Runtime.** `Opal.normalize` in `opal/runtime/boot.js` takes the same require
string, strips a leading `./` and any `.rb`/`.opal`/`.js` extension, then
resolves `..` by popping segments. The result is used to look up
`Opal.modules[...]`.

**The bridge** is `Opal::Compiler.module_name`, which produces the key a module
is emitted under. It truncates the basename at the *first* dot, so `foo.rb`,
`foo.js` and `foo.js.rb` all collapse to `foo`.

The crucial detail: `module_name` is applied to the **require string**, not to
the resolved path on disk. `module_name('./foo')` cleanpaths to `foo`, which is
exactly what `Opal.normalize('./foo')` produces. So however the compiler located
the file, the emitted key still matches the runtime lookup.

## A leading `./`

MRI resolves `require './foo'` against the process working directory. Opal only
does this when it has been told what that directory is.

`Builder#cwd` defaults to `nil`. With no cwd, a leading `./` is stripped and
looked up in the load path, so `require './foo'` finds the same asset as
`require 'foo'`. With a cwd set, `./foo` resolves against it first, as in MRI,
and falls back to the load path when the file is not there.

Only entry points with a meaningful working directory set one. The CLI does,
because running a file happens *somewhere*. A build task, a Rake task or
Sprockets does not: their output should not depend on the directory the build
was invoked from.

Because the module key comes from the require string, setting a cwd changes
which file is read but never what it is called — compile time and runtime still
agree.

### Consequences

- A `./foo` inside a **nested** file does not pick up that file's sibling. It is
  resolved against the cwd or the load path, never against the requiring file's
  own directory. `require_relative` is the way to reach a sibling.
- Without a cwd, a `./foo` that exists only in the working directory and not on
  the load path raises `MissingRequire`, where MRI would load it.
- A cwd lookup accepts an extension-less file, as a load path lookup does, so
  `require './foo'` can find a plain `foo`. MRI would not: it only tries its
  own known extensions.
- With a cwd, `./foo` (in the cwd) and `foo` (a different file on the load path)
  both key to the module `foo`, and whichever is required first wins. MRI has no
  equivalent, since it keys `$LOADED_FEATURES` by absolute path and would load
  both.

`require_relative` is separate from all of this: it is resolved at compile time
against `File.dirname(compiler.file)` and cleanpathed, so it never produces a
leading `./`.

## Deduplication

Anything that deduplicates requires has to key on `module_name`, not on the raw
require string, or the same module gets emitted more than once — `foo`, `foo.rb`
and `./foo` are three spellings of one module.

`Builder#already_processed?` and `#mark_as_processed` own that dedupe. The
sequential, threaded and prefork schedulers each track requires separately, so a
change to dedupe semantics has to be applied to all three.

The compile cache is keyed on the file contents as well as its name
(`Builder::Processor#cache_key`), so two different files that share a module name
cannot serve each other's compiled output.
