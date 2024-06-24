# frozen_string_literal: true

module Opal
  module Deprecations
    attr_accessor :raise_on_deprecation

    def deprecation(message)
      message = "DEPRECATION WARNING: #{message}"
      if defined?(@raise_on_deprecation) && @raise_on_deprecation
        raise message
      else
        warn message
      end
    end

    DEPRECATED_CONSTANTS = {
      Cache: 'Builder::Cache',
      Hike: 'Builder::Hike',
      PathReader: 'Builder::PathReader',
      BuilderScheduler: 'Builder::Scheduler',
      BuilderProcessors: 'Builder::Processor'
    }.freeze

    # Raise deprecations when an old name of a class is issued
    def const_missing(const)
      if DEPRECATED_CONSTANTS.include? const
        new_const = DEPRECATED_CONSTANTS[const]
        deprecation "Use of a class/module that has been renamed. Used #{const}, use #{new_const} instead."
        Opal.const_set(const, Opal.const_get(new_const))
      else
        super
      end
    end
  end

  extend Deprecations
  self.raise_on_deprecation = false
end
