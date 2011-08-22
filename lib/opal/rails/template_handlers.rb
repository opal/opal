require 'sprockets'
require 'tilt/opal'

module Opal::Rails

  class Resolver

    attr_accessor :context

    def initialize(context)
      @context = context
    end

    def resolve(path, content_type = :self)
      options = {}
      options[:content_type] = content_type unless content_type.nil?
      context.resolve(path, options)
    rescue Sprockets::FileNotFound, Sprockets::ContentTypeMismatch
      nil
    end

    def public_path(path, scope)
      context.asset_paths.compute_public_path(path, scope)
    end

    def process(path)
      context.environment[path].to_s
    end
  end

end

Sprockets::Engines #invoke autoloading
Sprockets.register_engine '.opal', Tilt::OpalTemplate
