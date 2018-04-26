# frozen_string_literal: true

module Opal
  module Parser
    class SourceBuffer < ::Parser::Source::Buffer
      def self.recognize_encoding(string)
        super || Encoding::UTF_8
      end
    end
  end
end
