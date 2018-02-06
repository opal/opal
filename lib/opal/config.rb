# frozen_string_literal: true

require 'set'

module Opal
  module Config
    extend self

    private

    def config_options
      @config_options ||= {}
    end

    # Defines a new configuration option
    #
    # @param [String] name the option name
    # @param [Object] default_value the option's default value
    # @!macro [attach] property
    #   @!attribute [rw] $1
    def config_option(name, default_value, options = {})
      compiler      = options.fetch(:compiler_option, nil)
      valid_values  = options.fetch(:valid_values , [true, false])

      config_options[name] = {
        default: default_value,
        compiler: compiler,
      }

      define_singleton_method(name) { config.fetch(name, default_value) }
      define_singleton_method("#{name}=") do |value|
        unless valid_values.any? { |valid_value| valid_value === value }
          raise ArgumentError, "Not a valid value for option #{self}.#{name}, provided #{value.inspect}. "\
                               "Must be #{valid_values.inspect} === #{value.inspect}"
        end

        config[name] = value
      end
    end

    public

    # @return [Hash] the default configuration
    def default_config
      default_config = {}
      config_options.each do |name, options|
        default_value = options.fetch(:default)
        default_value = Proc === default_value ? default_value.call : default_value
        default_config[name] = default_value
      end
      default_config
    end

    # @return [Hash] the configuration for Opal::Compiler
    def compiler_options
      compiler_options = {}
      config_options.each do |name, options|
        compiler_option_name = options.fetch(:compiler)
        compiler_options[compiler_option_name] = config.fetch(name)
      end
      compiler_options
    end

    # @return [Hash] the current configuration, defaults to #default_config
    def config
      @config ||= default_config
    end

    # Resets the config to its default value
    #
    # @return [void]
    def reset!
      @config = nil
    end

    # Enable method_missing support.
    #
    # @return [true, false]
    config_option :method_missing_enabled, true, compiler_option: :method_missing

    # Enable const_missing support.
    #
    # @return [true, false]
    config_option :const_missing_enabled, true, compiler_option: :const_missing

    # Enable arity check on the arguments passed to methods, procs and lambdas.
    #
    # @return [true, false]
    config_option :arity_check_enabled, false, compiler_option: :arity_check

    # Add stubs for methods related to freezing objects (for compatibility).
    #
    # @return [true, false]
    config_option :freezing_stubs_enabled, true, compiler_option: :freezing

    # Add stubs for methods related to tainting objects (for compatibility).
    #
    # @return [true, false]
    config_option :tainting_stubs_enabled, true, compiler_option: :tainting

    # Set the error severity for when a require can't be solved at compile time.
    #
    # - `:error` will raise an error at compile time
    # - `:warning` will print a warning on stderr at compile time
    # - `:ignore` will skip the require silently at compile time
    #
    # @return [:error, :warning, :ignore]
    config_option :dynamic_require_severity, :warning, compiler_option: :dynamic_require_severity, valid_values: [:error, :warning, :ignore]

    # Enable IRB support for making local variables across multiple compilations.
    #
    # @return [true, false]
    config_option :irb_enabled, false, compiler_option: :irb

    # Enable for inline operators optimizations.
    #
    # @return [true, false]
    config_option :inline_operators_enabled, true, compiler_option: :inline_operators

    # Enable source maps support.
    #
    # @return [true, false]
    config_option :source_map_enabled, true

    # A set of stubbed files that will be marked as loaded and skipped during
    # compilation. The value is expected to be mutated but it's ok to replace
    # it.
    #
    # @return [Set]
    config_option :stubbed_files, -> { Set.new }, valid_values: [Set]
  end
end
