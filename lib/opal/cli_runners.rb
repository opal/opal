# frozen_string_literal: true
module Opal
  # `Opal::CliRunners` is the namespace in which JavaScript runners can be
  # defined for use by `Opal::CLI`. The API for classes defined under
  # `CliRunners` is the following.
  #
  # - The #initialize method takes an `Hash` containing an `output:` object.
  #   Additional keys can be safely ignored and can be specific to a particular
  #   runner, e.g. the `CliRunners::Server` runner will accepts a `port:`
  #   option.
  # - The runner instance will then be called via `#run(compiled_source, argv)`:
  #   - `compiled_source` is a string of JavaScript code
  #   - `argv` is the arguments vector coming from the CLI that is being
  #     forwarded to the program
  #
  module CliRunners
    class RunnerError < StandardError
    end
  end
end

require 'opal/cli_runners/applescript'
require 'opal/cli_runners/nodejs'
require 'opal/cli_runners/server'
require 'opal/cli_runners/nashorn'
require 'opal/cli_runners/chrome'
