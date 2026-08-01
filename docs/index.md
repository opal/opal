# Opal Guides

Opal is a Ruby to JavaScript source-to-source compiler, shipping with an implementation of
the Ruby corelib and stdlib.

These guides are organised by what you are trying to do:

| If you want to… | Go to |
|---|---|
| Learn Opal by building something | **[Tutorial](#tutorial)** |
| Accomplish a specific task | **[How-to guides](#how-to-guides)** |
| Look up a flag, option, or API | **[Reference](#reference)** |
| Understand how Opal works | **[Explanation](#explanation)** |
| Contribute to Opal itself | **[Contributing](#contributing)** |

Upgrading from Opal 1.x? Start with the **[2.0 migration guide](reference/migration_2_0.html)**.

---

## Tutorial

Start here if you are new. Learning-oriented, meant to be followed start to finish.

### [Getting Started with Opal](tutorial/getting_started.html)

Install Opal, compile your first Ruby file, and run it in a browser and on Node.js.

---

## How-to guides

Task-oriented recipes. Each one solves a single problem and assumes you already know the basics.

### Building and deploying

#### [Static Applications](how-to/static_applications.html)

The most basic setup for a static Opal powered website that can be hosted anywhere.

#### [Directory Mode](how-to/directory_mode.html)

Build your project into a directory of ES modules — the recommended way to build an Opal project.

#### [Adjusting Load Paths with Opalfile](how-to/opalfile.html)

Define where Opal should look for Ruby files at build time.

#### [Enabling Source Maps](how-to/source_maps.html)

Debug your Ruby sources directly in the browser devtools.

### Frameworks and servers

#### [Rails](how-to/rails.html)

Use `opal-rails` to make Opal your JavaScript compiler.

#### [Sinatra](how-to/sinatra.html)

Serve Opal applications through Sinatra and `opal-sprockets`.

#### [Roda + Sprockets](how-to/roda_sprockets.html)

Serve Opal applications from Roda.

#### [Using Sprockets](how-to/using_sprockets.html)

Configure the long-lasting asset handler to work with Opal.

### Testing and tooling

#### [RSpec](how-to/rspec.html)

Write specs for your Opal code and run them on Node.js or in a browser.

#### [Headless Browsers](how-to/headless_browsers.html)

Run your Opal application in a headless browser from the CLI instead of Node.js.

#### [Working with ERB and Haml Templates](how-to/templates.html)

Work with template libraries in Opal, including sharing templates with the server.

#### [Using the Opal parser in a JavaScript environment](how-to/opal_parser.html)

Parse and run Ruby scripts inside a browser or any supported JavaScript environment.

### Publishing gems

#### [Configuring Gems](how-to/configuring_gems.html)

Make your gem work in Opal and differentiate code for the JavaScript environment.

#### [jQuery](how-to/jquery.html)

The `opal-jquery` wrapper around the popular library.

---

## Reference

Information-oriented. Dry, complete, and meant for looking things up.

### [CLI Reference](reference/cli.html)

Every `opal` command-line flag, what it does, and its default.

### [Configuration Reference](reference/config.html)

Every `Opal::Config` option, its type, and its default.

### [Runners](reference/runners.html)

Every available CLI runner, how to select it, and what it requires.

### [Migrating to Opal 2.0](reference/migration_2_0.html)

Every breaking change between Opal 1.x and 2.0, with old and new code side by side.

### [Compiled Ruby and Raw JavaScript Interfaces](reference/compiled_ruby.html)

How each part of Ruby maps to JavaScript internally, and how to cross the boundary in both
directions using raw interfaces.

### [Interfacing with JavaScript](reference/js_interface.html)

How to reach the JavaScript environment from Ruby code.

### [Compiler File Loading Directives](reference/compiler_directives.html)

Special directives that optimize or enhance the compiled output.

### [Unsupported Features](reference/unsupported_features.html)

Things that are difficult, impossible, or outright incompatible with a JavaScript environment.

### [Chrome DevTools Protocol notes](reference/cdp_common.html)

Implementation notes on the CDP interface shared by the browser runners.

---

## Explanation

Understanding-oriented. Background and design rationale, no step-by-step instructions.

### [How the Compiler Works](explanation/compiler.html)

The stages a Ruby file passes through on its way to JavaScript.

### [Bridging Ruby and JavaScript Classes](explanation/bridging.html)

How Opal makes native JavaScript classes behave like Ruby ones.

### [Async and Await](explanation/async.html)

How Opal supports JavaScript `async`/`await`, and how it lets you avoid explicit callbacks.

### [Promises](explanation/promises.html)

How Opal's promise implementations relate to native JavaScript promises.

### [Encoding](explanation/encoding.html)

(WIP) How encoding is handled in Opal, in the browser and in the compiler.

---

## Contributing

For people working on Opal itself. See also [HACKING.md](https://github.com/opal/opal/blob/master/HACKING.md)
for development environment setup, and
[CONTRIBUTING.md](https://github.com/opal/opal/blob/master/CONTRIBUTING.md) for the process.

### [Releasing Instructions](contributing/releasing.html)

A step-by-step guide to releasing a new version of Opal.

---

Guides for earlier releases are [available here](/docs). You are encouraged to help improve
these guides — if you spot a typo, a factual error, or something missing, please
[open a pull request](https://github.com/opal/opal/tree/master/docs).

> **Pages moved.** These guides were previously a flat list; they now live under
> `tutorial/`, `how-to/`, `reference/`, `explanation/` and `contributing/`. If you followed a
> link to a page that no longer resolves, find it in the index above. Guides published under a
> released version keep their original addresses, so only links to the `master` guides are
> affected. `upgrading.html`, which only covered v0.8 → v0.9, was replaced by the
> [2.0 migration guide](reference/migration_2_0.html).
