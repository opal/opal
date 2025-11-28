# frozen_string_literal: true

module Opal
  class Builder
    class PostProcessor
      @postprocessors = []
      def self.register(klass)
        @postprocessors << klass
      end

      def self.call(processed, builder)
        @postprocessors.each do |postprocessor|
          processed = postprocessor.new(processed, builder).call
        end

        processed
      end

      def self.postprocessing_enabled?(builder)
        @postprocessors.any? do |postprocessor|
          postprocessor.enabled?(builder)
        end
      end

      # For spec use
      def self.with_postprocessors(postprocessors)
        prev_postprocessors = @postprocessors
        @postprocessors = Array(postprocessors)
        result = yield
        @postprocessors = prev_postprocessors
        result
      end

      # If any postprocessor is enabled, we need to cache fragments
      # and source.
      def self.enabled?(_builder)
        true
      end

      def initialize(processed, builder)
        @processed = processed
        @builder = builder
      end

      attr_reader :processed, :builder

      # descendants override

      def call
        processed
      end

      class Directive
        attr_accessor :name, :params

        def initialize(name, **params)
          @name = name
          @params = params
        end

        # Unhandled post-processor directive
        def code
          ''
        end
      end

      module NodeSupport
        def post_processor_directive(name, **kwargs)
          Directive.new(name, **kwargs)
        end
      end
    end
  end
end

require 'opal/builder/post_processor/dce'
