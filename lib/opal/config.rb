require 'set'

module Opal
  module Config
    def self.default_config
      {
        method_missing_enabled:    true,
        arity_check_enabled:       false,
        freezing_stubs_enabled:    true,
        tainting_stubs_enabled:    true,
        const_missing_enabled:     true,
        dynamic_require_severity:  :error, # :error, :warning or :ignore
        irb_enabled:               false,
        inline_operators_enabled:  true,
        source_map_enabled:        true,
        stubbed_files:             Set.new,
      }
    end

    def self.config
      @config ||= default_config
    end

    def self.reset!
      @config = nil
    end

    COMPILER_KEYS = {
      method_missing:           :method_missing_enabled,
      arity_check:              :arity_check_enabled,
      freezing:                 :freezing_stubs_enabled,
      tainting:                 :tainting_stubs_enabled,
      const_missing:            :const_missing_enabled,
      dynamic_require_severity: :dynamic_require_severity,
      irb:                      :irb_enabled,
      inline_operators:         :inline_operators_enabled,
    }

    def self.compiler_options
      config = self.config
      compiler_options = {}
      COMPILER_KEYS.each do |compiler_option_name, option_name|
        compiler_options[compiler_option_name] = config[option_name]
      end
      compiler_options
    end

    default_config.keys.each do |config_option|
      define_singleton_method(config_option) { config[config_option] }
      define_singleton_method("#{config_option}=") { |value| config[config_option] = value }
    end
  end
end
