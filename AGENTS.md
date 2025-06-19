# AGENTS Instructions

## Setup
- Run `bin/setup` once after cloning to install gems, yarn packages and git submodules.

## Running tests
- Running `bin/rake` executes every suite on both Chrome and Node.js but is slow and requires a browser.
- For day-to-day work rely on the Node.js tasks and ensure they pass before committing:
  - `bin/rake rspec` runs the RSpec suite covering Opal compiler and runtime internals.
  - `bin/rake mspec_nodejs` runs the entire ruby/spec compatibility suite (use `PATTERN=<glob>` to limit the run).
  - `bin/rake mspec_opal_nodejs` executes the Opal-specific specs under `spec/opal`.
  - `bin/rake minitest_nodejs` runs the vendored CRuby tests and Opal's stdlib additions from `test/opal`.
  - `bin/rake minitest_node_nodejs` runs integration tests in `test/nodejs`.

## Linting
- Run `bin/rake lint` to check code style. This builds the corelib and stdlib then executes RuboCop and ESLint.

## Notes
- The list of MSpec files is in `spec/ruby_specs` and filters live in `spec/filters`.
- Tests depend on initialized submodules (`spec/mspec`, `spec/ruby`, `test/cruby`).
