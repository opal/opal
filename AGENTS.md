# AGENTS Instructions

## Setup
- Run `bin/setup` once after cloning to install gems, yarn packages and git submodules.

## Running tests
- Use `bin/rake` to run the full suite (RSpec, MSpec and Minitest).
- RSpec covers Opal compiler and runtime internals. Run with `bin/rake rspec`.
- MSpec executes the ruby/spec suite for language compatibility. Run with `bin/rake mspec` or `bin/rake mspec_nodejs`. Use `PATTERN=<glob>` to run a subset.
- The Opal specific specs under `spec/opal` run via `bin/rake mspec_opal_nodejs` (or `mspec_opal_chrome` for browsers).
- Minitest contains the CRuby tests we vendor for additional coverage. Run with `bin/rake minitest`.
- Tests for Opal's own stdlib additions live in `test/opal` and are executed with `bin/rake minitest_nodejs`.
- Node.js integration tests in `test/nodejs` run with `bin/rake minitest_node_nodejs`.
- Always ensure `bin/rake` passes before committing changes. If Chrome is unavailable, run the Node.js variants instead.

## Notes
- The list of MSpec files is in `spec/ruby_specs` and filters live in `spec/filters`.
- Tests depend on initialized submodules (`spec/mspec`, `spec/ruby`, `test/cruby`).
