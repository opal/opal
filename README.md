<h1 align="center">
  <img src="https://secure.gravatar.com/avatar/88298620949a6534d403da2e356c9339?s=420"
  align="center" alt="Opal logo" title="Opal logo by Elia Schito" width="105" height="105" />
  <br/>
  Opal
</h1>

<p align="center">
  <strong>Opal is a Ruby to JavaScript source-to-source compiler, shipping with an implementation of the Ruby corelib and stdlib.</strong>
</p>

<p align="center">
  <a href="https://rubygems.org/gems/opal"><img src="https://img.shields.io/gem/v/opal.svg?style=flat" alt="Gem Version" /></a>
  <a href="https://github.com/opal/opal/actions?query=workflow%3Abuild"><img src="https://github.com/opal/opal/workflows/build/badge.svg" alt="Build Status" /></a>
  <a href="https://opalrb.com/docs"><img src="https://img.shields.io/badge/docs-opalrb.com-blue.svg" alt="Documentation" /></a>
  <a href="https://slack.opalrb.com/"><img src="https://img.shields.io/badge/slack-join%20chat-46BC99?logo=slack&style=flat" alt="Slack" /></a>
</p>

Write Ruby, run it anywhere JavaScript runs — the browser, Node.js, Deno, Bun, QuickJS.

## Why Opal

- **A real Ruby implementation.** Opal ships its own corelib and stdlib and is
  validated against [ruby/spec][ruby-spec], the same suite CRuby uses. A JavaScript
  host imposes limits — those are catalogued in
  [Unsupported Features](docs/reference/unsupported_features.md).
- **Source-to-source, no runtime interpreter.** Ruby compiles to plain JavaScript
  ahead of time, so there is no VM to download and no interpreter loop at runtime.
- **Two-way JavaScript interop.** Call JS from Ruby and Ruby from JS, and treat
  native JS classes as Ruby ones. See [Interfacing with JavaScript][js-interface].
- **Share code between server and client.** The same gem, the same objects, the
  same specs, on both sides of the wire.
- **It compiles itself.** The compiler is written in Ruby and builds to
  `opal-parser.js`, so it also runs inside the browser.

## Installation

Opal needs Ruby. The gemspec declares `>= 2.3`; CI exercises Ruby 3.0 through 4.0
and JRuby, so 3.x or newer is the sensible choice.

```bash
gem install opal
```

Or in your `Gemfile`:

```ruby
gem 'opal'
```

This installs the latest release, from the 1.8 series. The `master` branch is
`2.0.0dev` and is not yet released; to track it:

```ruby
gem 'opal', github: 'opal/opal'
```

Then check it:

```bash
opal -v
opal -e "puts 'Hello from Opal'"
```

The second command prints `Hello from Opal` — it compiled the Ruby and ran the
result on Node.js.

## Documentation

- **[Guides](docs/index.md)** — tutorial, how-to guides, reference, and
  explanation, also rendered at [opalrb.com/docs](https://opalrb.com/docs).
- **[Getting Started](docs/tutorial/getting_started.md)** — the tutorial to follow first.
- **[Migrating to Opal 2.0](docs/reference/migration_2_0.md)** — every breaking
  change from 1.x, with old and new code side by side.
- **[CLI Reference](docs/reference/cli.md)** and
  **[Runners](docs/reference/runners.md)** — every flag and every execution target.
- Framework integrations: [Rails](docs/how-to/rails.md),
  [Sinatra](docs/how-to/sinatra.md), [Roda](docs/how-to/roda_sprockets.md),
  [static apps](docs/how-to/static_applications.md).

## Usage

### Compiling Ruby with the CLI

Contents of `app.rb`:

```ruby
puts 'Hello world!'
```

Then from the terminal:

```bash
opal --compile app.rb > app.js
```

The Opal runtime is included by default; skip it with `--no-opal`.

The resulting JavaScript file runs from an HTML page. Set the page encoding to
`UTF-8` — Opal's string handling depends on it:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <script src="app.js"></script>
  </head>
  <body>
  </body>
</html>
```

Open the page in a browser and check the JavaScript console.

### Compiling Ruby from Ruby

`Opal.compile` compiles a string of Ruby into a string of JavaScript:

```ruby
require 'opal'

Opal.compile("puts 'wow'")
# => "Opal.queue(function(Opal) { ... return self.$puts(\"wow\") ... });\n"
```

That output alone is not runnable — it needs the Opal runtime/corelib.
`Opal::Builder` builds the runtime:

```ruby
Opal::Builder.build('opal')  # => "(function() { ... })()"
```

or an entire app, resolving `require` dependencies:

```ruby
builder = Opal::Builder.new
builder.build_str('require "opal"; puts "wow"', '(inline)')
File.binwrite 'app.js', builder.to_s  # must use binary mode for writing
```

### Compiling Ruby from HTML

`opal-parser` evaluates Ruby directly from your HTML files, with no build step:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <script src="https://cdn.opalrb.com/opal/current/opal.js"></script>
    <script src="https://cdn.opalrb.com/opal/current/opal-parser.js" onload="Opal.load('opal-parser')"></script>

    <script type="text/ruby">
      puts "hi"
    </script>
  </head>
  <body>
  </body>
</html>
```

Open the page and check the JavaScript console.

**NOTE**: this ships the compiler to the client. It is a fast way to try Opal, not
a way to deploy it.

## Runtime support

The upcoming 2.0 targets **ES2021**: compiled output and the Opal runtime assume an
ES2021-capable engine, and there is no transpilation fallback. If you need to
support an older engine, stay on Opal 1.x. See the
[migration guide](docs/reference/migration_2_0.md) for the full rationale.

That means:

* Firefox, Chrome, Safari, Edge — current and previous stable versions
* Node.js, Deno, Bun, QuickJS, and more — see [Runners](docs/reference/runners.md)

Internet Explorer is **not** supported. Problems on any engine listed above
should be reported as bugs.

## Contributing

`HACKING.md` is the contributor guide — prerequisites, `bin/setup`, running the
spec suites, benchmarking, and profiling:

- **[HACKING.md](HACKING.md)** — development environment and test suites
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — how to file issues and open pull requests

The short version, once you have cloned the repo:

```bash
bin/setup
bundle exec rake
```

### Code layout

* `lib/` — the Opal parser and compiler. Runs in your Ruby environment, and is
  also built for the browser as `opal-parser.js`.
* `opal/` — the runtime and corelib, written in Ruby and JavaScript. Runs in the
  JavaScript environment.
* `stdlib/` — Opal's implementation of Ruby's stdlib (`StringScanner`, `Date`,
  `Observable`, …). Optional, runs in the JavaScript environment.

## Versioning

Opal will broadly follow semver as a version policy, trying to bump the major version when introducing breaking changes.
Being a language implementation we're also aware that there's a fine line between what can be considered breaking and what is expected to be "safe" or just "additive". Moving forward we'll attempt to better clarify what interfaces are meant to be public and what should be considered private.

The `master` branch is currently `2.0.0dev` — unreleased. The latest released gem
is on [RubyGems](https://rubygems.org/gems/opal).

## Community

* [Slack](https://slack.opalrb.com/) — chat with maintainers and users
* [Stack Overflow `#opalrb`](https://stackoverflow.com/questions/ask?tags=opalrb) — questions
* [Issues](https://github.com/opal/opal/issues) — bugs and feature requests

## Contributors

This project exists thanks to all the people who contribute. [![contributors](https://opencollective.com/opal/contributors.svg?width=890&button=false")](https://github.com/opal/opal/graphs/contributors)

## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/opal#backer)]

<a href="https://opencollective.com/opal#backers" target="_blank"><img src="https://opencollective.com/opal/backers.svg?width=890" alt="Become a Backer Button" /></a>
<a href="https://opencollective.com/opal/sponsor/1/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/1/avatar.svg" alt="Sponsor 1"></a>
<a href="https://opencollective.com/opal/sponsor/2/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/2/avatar.svg" alt="Sponsor 2"></a>
<a href="https://opencollective.com/opal/sponsor/3/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/3/avatar.svg" alt="Sponsor 3"></a>
<a href="https://opencollective.com/opal/sponsor/4/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/4/avatar.svg" alt="Sponsor 4"></a>
<a href="https://opencollective.com/opal/sponsor/5/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/5/avatar.svg" alt="Sponsor 5"></a>
<a href="https://opencollective.com/opal/sponsor/6/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/6/avatar.svg" alt="Sponsor 6"></a>
<a href="https://opencollective.com/opal/sponsor/7/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/7/avatar.svg" alt="Sponsor 7"></a>
<a href="https://opencollective.com/opal/sponsor/8/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/8/avatar.svg" alt="Sponsor 8"></a>
<a href="https://opencollective.com/opal/sponsor/9/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/9/avatar.svg" alt="Sponsor 9"></a>

## Sponsors

### Donations

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/opal#sponsor)]

<a href="https://opencollective.com/opal/sponsor/0/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/0/avatar.svg" alt="Become a Sponsor Button"></a>

### Sponsored Contributions

<a href="https://nebulab.it/?utm_source=github&utm_medium=sponsors" target="_blank"><img src=".github/sponsors/nebulab-logo.svg" alt="Nebulab Logo"></a>

<a href="https://www.testmu.ai/?utm_source=github&utm_medium=sponsors" target="_blank"><img src=".github/sponsors/testmu-ai-black.svg" alt="TestMu AI Logo" width="200"></a>

## License

Opal is released under the MIT License. See [LICENSE](LICENSE) for the full text.

[ruby-spec]: https://github.com/ruby/spec#readme
[js-interface]: docs/reference/js_interface.md
