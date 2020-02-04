# frozen_string_literal: true

module Opal
  module Parser
    class SourceBuffer < ::Parser::Source::Buffer
      def self.recognize_encoding(string)
        super || Encoding::UTF_8
      end

      # Skip encoding while compiling from a JavaScript runtime
      if RUBY_PLATFORM == 'opal'
        def self.reencode_string(input)
          input
        end
      end
    end
  end
end
