# AGENTS Instructions

This file explains how automation and human contributors should operate in this
repository.  Follow the steps below to get a working development environment,
run the test suites and keep the repository in a healthy state.


## Setup
- Run `bin/setup` once after cloning to install gems, yarn packages and git submodules.

## Directory overview
- `lib/` & `opal/` hold the compiler and runtime sources.
- `stdlib/` contains Opal's standard library implementation.
- `spec/` and `test/` host RSpec and Minitest suites.
- `examples/` shows sample applications.
- `docs/` provides documentation for contributors and users.
- `tasks/` defines Rake tasks used by `bin/rake`.

## Running tests
- Running `bin/rake` executes every suite on both Chrome and Node.js but is slow and requires a browser.
- For day-to-day work rely on the Node.js tasks and ensure they pass before committing:
  - `bin/rake rspec` runs the RSpec suite covering Opal compiler and runtime internals.
  - `bin/rake mspec_ruby_nodejs` runs the ruby/spec compatibility suite (use `PATTERN=<glob>` to limit the run).
  - `bin/rake mspec_opal_nodejs` executes the Opal-specific specs under `spec/opal`.
  - `bin/rake mspec_nodejs` runs both of the above suites in sequence.
  - `bin/rake minitest_cruby_nodejs` runs the vendored CRuby tests and Opal's stdlib additions from `test/opal` (set `FILES=<glob>` to limit).
  - `bin/rake minitest_node_nodejs` runs integration tests in `test/nodejs`.
  - `bin/rake minitest_nodejs` runs both Minitest suites on Node.js.

## Linting
- Run `bin/rake lint` to check code style. This builds the corelib and stdlib then executes RuboCop and ESLint.

## Notes
- The list of MSpec files is in `spec/ruby_specs` and filters live in `spec/filters`.
- Tests depend on initialized submodules (`spec/mspec`, `spec/ruby`, `test/cruby`).
- If an agent discovers information that required significant setup time, condense
  the result into a short bullet in this file so later agents can skip the same
  work.
- See `HACKING.md` and `CONTRIBUTING.md` for more detailed guides on
  collaborating on Opal.
