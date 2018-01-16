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
    register_runner :compiler, -> data {
      options  = data[:options] || {}
      builder  = data.fetch(:builder)
      map_file = options[:map_file]
      output   = data.fetch(:output)

      output.puts builder.to_s
      File.write(map_file, builder.source_map) if map_file

      0
    }

    # Legacy runners

    def self.register_legacy_runner(klass_name, *names)
      runner = -> data {
        klass = const_get(klass_name)
        runner = klass.new((data[:options] || {}).merge(output: data[:output]))
        runner.run(data[:builder].to_s, data[:argv])
        runner.exit_status
      }
      names.each { |name| self[name] = runner }
    end

    require 'opal/cli_runners/cmd'

    autoload :Applescript, 'opal/cli_runners/applescript'
    autoload :Chrome,      'opal/cli_runners/chrome'
    autoload :Nashorn,     'opal/cli_runners/nashorn'
    autoload :Nodejs,      'opal/cli_runners/nodejs'
    autoload :Server,      'opal/cli_runners/server'

    register_legacy_runner :Applescript, :applescript, :osascript
    register_legacy_runner :Chrome,      :chrome
    register_legacy_runner :Nashorn,     :nashorn
    register_legacy_runner :Nodejs,      :nodejs, :node
    register_legacy_runner :Server,      :server

    # @elia Is this what you had in mind ?
=begin
    node_runner = -> data {

      NODE_PATH = File.expand_path('../stdlib/nodejs/node_modules', ::Opal.gem_dir)
      paths = ENV['NODE_PATH'].to_s.split(':')
      paths << NODE_PATH unless paths.include? NODE_PATH
      node_modules = paths.join(':')

      command_options = {:name => 'nodejs', :env => {'NODE_PATH' => node_modules}, :cmd => 'node'}
      command_options[:options] = data[:options] || {}
      cmd = Cmd.new(command_options)

      cmd.run(data[:builder].to_s, data[:argv])
      cmd.exit_status
    }
    register_runner :nodejs, node_runner
    register_runner :node, node_runner
=end

  end
end
