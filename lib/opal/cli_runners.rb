module Opal
  module CliRunners
    class RunnerError < StandardError
    end
  end
end

require 'opal/cli_runners/applescript'
require 'opal/cli_runners/phantomjs'
require 'opal/cli_runners/nodejs'
require 'opal/cli_runners/server'
require 'opal/cli_runners/nashorn'
