# frozen_string_literal: true

require 'shellwords'
require 'socket'
require 'timeout'
require 'tmpdir'
require 'rbconfig'
require 'opal/os'
require 'net/http'
require 'webrick'

module Opal
  module CliRunners
    class Safari
      EXECUTION_TIMEOUT = 600 # seconds
      DEFAULT_SAFARI_DRIVER_HOST = 'localhost'
      DEFAULT_SAFARI_DRIVER_PORT = 9444 # in addition safari_driver_port + 1 is used for the http server

      def self.call(data)
        runner = new(data)
        runner.run
      end

      def initialize(data)
        argv = data[:argv]
        if argv && argv.any?
          warn "warning: ARGV is not supported by the Safari runner #{argv.inspect}"
        end

        options  = data[:options]
        @output  = options.fetch(:output, $stdout)
        @builder = data[:builder].call
      end

      attr_reader :output, :exit_status, :builder

      def run
        mktmpdir do |dir|
          with_http_server(dir) do |http_port, server_thread|
            with_safari_driver do
              prepare_files_in(dir)

              # Safaridriver commands are very limitied, for supported commands see:
              # https://developer.apple.com/documentation/webkit/macos_webdriver_commands_for_safari_12_and_later
              Net::HTTP.start(safari_driver_host, safari_driver_port) do |con|
                con.read_timeout = EXECUTION_TIMEOUT
                res = con.post('/session', { capabilities: { browserName: 'Safari' } }.to_json, 'Content-Type' => 'application/json')
                session_id = JSON.parse(res.body).dig('value', 'sessionId')
                if session_id
                  session_path = "/session/#{session_id}"
                  con.post("#{session_path}/url", { url: "http://#{safari_driver_host}:#{http_port}/index.html" }.to_json, 'Content-Type' => 'application/json')
                  server_thread.join(EXECUTION_TIMEOUT)
                else
                  STDERR.puts "Could not create session: #{res.body}"
                end
              end
              0
            end
          end
        end
      end

      private

      def prepare_files_in(dir)
        # The safaridriver is very limited in capabilities, basically it can trigger visiting sites
        # and interact a bit with the page. So this runner starts its own server, overwrites the
        # console log, warn, error functions of the browser and triggers a request after execution
        # to exit. Certain exceptions cannot be caught that way and everything may fail in between,
        # thats why execution is timed out after EXECUTION_TIMEOUT (10 minutes).
        # As a side effect, console messages may arrive out of order and timing anything may be inaccurate.

        builder.build_str <<~RUBY, '(exit)', no_export: true
        %x{
          var req = new XMLHttpRequest();
          req.open("GET", '/exit');
          req.send();
        }
        RUBY

        js = builder.to_s
        map = builder.source_map.to_json
        ext = builder.output_extension
        module_type = ' type="module"' if builder.esm?

        File.binwrite("#{dir}/index.#{ext}", js)
        File.binwrite("#{dir}/index.map", map)
        File.binwrite("#{dir}/index.html", <<~HTML)
          <html><head>
            <meta charset='utf-8'>
            <link rel="icon" href="data:;base64,=">
          </head><body>
            <script>
              var orig_log = console.log;
              var orig_err = console.error;
              var orig_warn = console.warn;
              function send_log_request(args) {
                var req = new XMLHttpRequest();
                req.open("POST", '/log');
                req.setRequestHeader("Content-Type", "application/json");
                req.send(JSON.stringify(args));
              }
              console.log = function() {
                orig_log.apply(null, arguments);
                send_log_request(arguments);
              }
              console.error = function() {
                orig_err.apply(null, arguments);
                send_log_request(arguments);
              }
              console.warn = function() {
                orig_warn.apply(null, arguments);
                send_log_request(arguments);
              }

            </script>
            <script src='./index.#{ext}'#{module_type}></script>
          </body></html>
        HTML

        # <script src='./index.#{ext}'#{module_type}></script>
      end

      def safari_driver_host
        ENV['SAFARI_DRIVER_HOST'] || DEFAULT_SAFARI_DRIVER_HOST
      end

      def safari_driver_port
        ENV['SAFARI_DRIVER_PORT'] || DEFAULT_SAFARI_DRIVER_PORT
      end

      def with_http_server(dir)
        port = safari_driver_port.to_i + 1
        server_thread = Thread.new do
          server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: dir, Logger: WEBrick::Log.new('/dev/null'), AccessLog: [])
          server.mount_proc('/log') do |req, res|
            if req.body
              par = JSON.parse(req.body)
              par.each_value do |value|
                print value.to_s
              end
            end
            res.header['Content-Type'] = 'text/plain'
            res.body = ''
          end
          server.mount_proc('/exit') do
            server_thread.kill
          end
          server.start
        end

        yield port, server_thread
      rescue
        exit(1)
      ensure
        server_thread.kill if server_thread
      end

      def with_safari_driver
        if safari_driver_running?
          yield
        else
          run_safari_driver { yield }
        end
      end

      def run_safari_driver
        raise 'Safari driver can be started only on localhost' if safari_driver_host != DEFAULT_SAFARI_DRIVER_HOST

        started = false

        safari_driver_cmd = %{/usr/bin/safaridriver \
          -p #{safari_driver_port} \
          #{ENV['SAFARI_DRIVER_OPTS']}}

        safari_driver_pid = Process.spawn(safari_driver_cmd, in: OS.dev_null, out: OS.dev_null, err: OS.dev_null)

        Timeout.timeout(30) do
          loop do
            break if safari_driver_running?
            sleep 0.5
          end
        end

        started = true

        yield
      rescue Timeout::Error => e
        puts started ? 'Execution timed out' : 'Failed to start Safari driver'
        raise e
      ensure
        Process.kill('HUP', safari_driver_pid) if safari_driver_pid
      end

      def safari_driver_running?
        puts "Connecting to #{safari_driver_host}:#{safari_driver_port}..."
        TCPSocket.new(safari_driver_host, safari_driver_port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
        false
      end

      def mktmpdir(&block)
        Dir.mktmpdir('safari-opal-', &block)
      end
    end
  end
end
