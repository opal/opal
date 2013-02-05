require 'opal'
require 'sprockets'

module Opal
  class Processor < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      true
    end

    def initialize_engine
      require_template_library 'opal'
    end

    def prepare
      # ...
    end

    def evaluate(scope, locals, &block)
      Opal.parse data
    end
  end
end

# Add corelib to assets path
Opal.append_path Opal.core_dir

# Register templates for .rb and .opal extensions
Tilt.register 'rb',               Opal::Processor
Sprockets.register_engine '.rb',  Opal::Processor

Tilt.register 'opal',               Opal::Processor
Sprockets.register_engine '.opal',  Opal::Processor
