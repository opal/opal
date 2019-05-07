# frozen_string_literal: true

module Opal
  # `Opal::CliRunners` is the register in which JavaScript runners can be
  # defined for use by `Opal::CLI`. Runners will be called via the `#call`
  # method and passed a Hash containing the following keys:
  #
  #
  # - `options`: a hash of options for the runner
  # - `output`: an IO-like object responding to `#write` and `#puts`
  # - `argv`: is the arguments vector coming from the CLI that is being
  #     forwarded to the program
  # - `builder`: the current instance of Opal::Builder
  #
  # Runners can be registered using `#register_runner(name, runner)`.
  #
  module CliRunners
    class RunnerError < StandardError
    end

    @register = {}

    def self.[](name)
      @register[name.to_sym]
    end

    def self.[]=(name, runner)
      warn "Overwriting Opal CLI runner: #{name}" if @register.key? name.to_sym
      @register[name.to_sym] = runner
    end

    def self.to_h
      @register
    end

    # @param name [Symbol] the name at which the runner can be reached
    # @param runner [#call] a callable object that will act as the "runner"
    def self.register_runner(name, runner)
      self[name] = runner
      nil
    end

    # The compiler runner will just output the compiled JavaScript
    register_runner :compiler, ->(data) {
      options  = data[:options] || {}
      builder  = data.fetch(:builder)
      map_file = options[:map_file]
      output   = data.fetch(:output)

      compiled_source = builder.to_s + "\n" + builder.source_map.to_data_uri_comment
      output.puts compiled_source
      File.write(map_file, builder.source_map.to_json) if map_file

      0
    }

    # Legacy runners

    def self.register_legacy_runner(klass_name, *names)
      runner = ->(data) {
        klass = const_get(klass_name)
        runner = klass.new((data[:options] || {}).merge(output: data[:output]))
        builder = data[:builder]
        compiled_source = builder.to_s + "\n" + builder.source_map.to_data_uri_comment
        runner.run(compiled_source, data[:argv])
        runner.exit_status
      }
      names.each { |name| self[name] = runner }
    end

    autoload :Applescript,  'opal/cli_runners/applescript'
    autoload :Chrome,       'opal/cli_runners/chrome'
    autoload :Nashorn,      'opal/cli_runners/nashorn'
    autoload :Nodejs,       'opal/cli_runners/nodejs'
    autoload :Strictnodejs, 'opal/cli_runners/strictnodejs'
    autoload :Server,       'opal/cli_runners/server'

    register_legacy_runner :Applescript,  :applescript, :osascript
    register_legacy_runner :Chrome,       :chrome
    register_legacy_runner :Nashorn,      :nashorn
    register_legacy_runner :Nodejs,       :nodejs, :node
    register_legacy_runner :Strictnodejs, :strictnodejs
    register_legacy_runner :Server,       :server
  end
end
