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

    # @private
    def self.[]=(name, runner)
      warn "Overwriting Opal CLI runner: #{name}" if @register.key? name.to_sym

      @register[name.to_sym] = runner
    end
    private_class_method :[]=

    def self.to_h
      @register
    end

    # @param name [Symbol] the name at which the runner can be reached
    # @param runner [#call] a callable object that will act as the "runner"
    # @param runner [Symbol] a constant name that once autoloaded will point to
    #                        a callable.
    def self.register_runner(name, runner)
      if runner.respond_to?(:call)
        self[name] = runner
      else
        self[name] = ->(data) { const_get(runner).call(data) }
      end

      nil
    end

    # Alias a runner name
    def self.alias_runner(new_name, old_name)
      self[new_name.to_sym] = self[old_name.to_sym]

      nil
    end

    autoload :Applescript, 'opal/cli_runners/applescript'
    autoload :Compiler,    'opal/cli_runners/compiler'
    autoload :Chrome,      'opal/cli_runners/chrome'
    autoload :Nashorn,     'opal/cli_runners/nashorn'
    autoload :Nodejs,      'opal/cli_runners/nodejs'
    autoload :Server,      'opal/cli_runners/server'

    register_runner :applescript, :Applescript
    register_runner :chrome,      :Chrome
    register_runner :nashorn,     :Nashorn
    register_runner :nodejs,      :Nodejs
    register_runner :server,      :Server
    register_runner :compiler,    :Compiler

    alias_runner :osascript, :applescript
    alias_runner :node, :nodejs
  end
end
