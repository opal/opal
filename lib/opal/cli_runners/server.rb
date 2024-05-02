# frozen_string_literal: true

require 'opal/simple_server'

module Opal
  module CliRunners
    class Server
      def self.call(data)
        runner = new(data)
        runner.run
        runner.exit_status
      end

      def initialize(data)
        options = data[:options] || {}
        @builder = data[:builder]

        @argv = data[:argv] || []

        @output = data[:output] || $stdout

        @port = options.fetch(:port, ENV['OPAL_CLI_RUNNERS_SERVER_PORT'] || 3000).to_i

        @static_folder = options[:static_folder] || ENV['OPAL_CLI_RUNNERS_SERVER_STATIC_FOLDER']
        @static_folder = @static_folder == true ? 'public' : @static_folder
        @static_folder = File.expand_path(@static_folder) if @static_folder
      end

      attr_reader :output, :port, :server, :static_folder, :builder, :argv

      def run
        unless argv.empty?
          raise ArgumentError, 'Program arguments are not supported on the Server runner'
        end

        require 'rack'
        require 'logger'

        app = build_app(builder)

        @server = Rack::Server.start(
          app:       app,
          Port:      port,
          AccessLog: [],
          Logger:    Logger.new(output),
        )
      end

      def exit_status
        nil
      end

      def build_app(builder)
        app = Opal::SimpleServer.new(builder: builder, main: 'cli-runner')

        if static_folder
          not_found = [404, {}, []]
          app = Rack::Cascade.new(
            [
              Rack::Static.new(->(_) { not_found }, urls: [''], root: static_folder),
              app
            ],
          )
        end

        app
      end
    end
  end
end
