# frozen_string_literal: true

require 'opal/os'

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
  # - `builder`: a proc returning a new instance of Opal::Builder so it
  #     can be re-created and pick up the most up-to-date sources
  #
  # Runners can be registered using `#register_runner(name, runner)`.
  #
  module CliRunners
    class RunnerError < StandardError
    end

    @runners = []

    def self.registered_runners
      @runners
    end

    @register = {}

    def self.[](name)
      @register[name.to_sym]&.call
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
    # @param path [nil,String] a path for setting up autoload on the constant
    def self.register_runner(name, runner, path = nil)
      autoload runner, path if path

      @runners.push(runner.to_s)

      if runner.respond_to? :call
        self[name] = -> { runner }
      else
        self[name] = -> { const_get(runner) }
      end

      nil
    end

    # Alias a runner name
    def self.alias_runner(new_name, old_name)
      self[new_name.to_sym] = -> { self[old_name.to_sym] }

      nil
    end

    # running on all OS
    register_runner :bun,         :Bun,         'opal/cli_runners/bun'
    register_runner :chrome,      :Chrome,      'opal/cli_runners/chrome'
    register_runner :compiler,    :Compiler,    'opal/cli_runners/compiler'
    register_runner :deno,        :Deno,        'opal/cli_runners/deno'
    register_runner :edge,        :Edge,        'opal/cli_runners/edge'
    register_runner :firefox,     :Firefox,     'opal/cli_runners/firefox'
    register_runner :nodejs,      :Nodejs,      'opal/cli_runners/nodejs'
    register_runner :safari,      :Safari,      'opal/cli_runners/safari' if OS.macos?
    register_runner :server,      :Server,      'opal/cli_runners/server'

    alias_runner :node, :nodejs
  end
end
