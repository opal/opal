module Opal
  module CliRunners
    class RunnerError < StandardError
    end
  end
end

require 'opal/cli_runners/apple_script'
require 'opal/cli_runners/phantomjs'
require 'opal/cli_runners/nodejs'
require 'opal/cli_runners/server'
