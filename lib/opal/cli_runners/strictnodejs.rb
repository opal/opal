# frozen_string_literal: true

require 'opal/paths'
require 'opal/cli_runners/nodejs'

module Opal
  module CliRunners
    class Strictnodejs
      def self.call(data)
        data[:options] ||= {}
        data[:options][:env] ||= {}
        data[:options][:env]['NODE_OPTIONS'] += ' --use_strict '

        Nodejs.call(data)
      end
    end
  end
end
