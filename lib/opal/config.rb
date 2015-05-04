module Opal
  module Config
    def self.default_config
      {
        method_missing_enabled:    true,
        arity_check_enabled:       false,
        const_missing_enabled:     true,
        dynamic_require_severity:  :error, # :error, :warning or :ignore
        irb_enabled:               false,
        inline_operators_enabled:  true,
        source_map_enabled:        true,
      }
    end

    def self.config
      @config ||= default_config
    end

    def self.reset!
      @config = nil
    end

    COMPILER_KEYS = Set.new %i[
      method_missing
      arity_check
      const_missing
      dynamic_require_severity
      irb
      inline_operators
    ]

    def self.compiler_options
      compiler_keys = COMPILER_KEYS
      config.select { |k,_v| compiler_keys.include? k }
    end

    default_config.keys.each do |config_option|
      define_singleton_method(config_option) { config[config_option] }
      define_singleton_method("#{config_option}=") { |value| config[config_option] = value }
    end
  end
end
