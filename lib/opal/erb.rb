require 'opal/parser'

module Opal
  module ERB
    def self.parse(str, name='(erb)')
      body = str.gsub('"', '\\"').gsub(/<%=([\s\S]+?)%>/) do
        inner = $1.gsub(/\\'/, "'").gsub(/\\"/, '"')
        "\")\nout.<<(#{ inner })\nout.<<(\""
      end.gsub(/<%([\s\S]+?)%>/) do
        "\")\n#{ $1 }\nout.<<(\""
      end

      code = "ERB.new('#{name}') do\nout = []\nout.<<(\"#{ body }\")\nout.join\nend\n"
      Opal.parse code
    end

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
        Opal::ERB.parse data, scope.logical_path.sub(/^templates\//, '')
      end
    end
  end
end

Tilt.register 'opalerb',               Opal::ERB::Processor
Sprockets.register_engine '.opalerb',  Opal::ERB::Processor

