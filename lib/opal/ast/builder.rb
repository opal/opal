# frozen_string_literal: true

require 'opal/ast/node'
require 'parser/ruby32'

module Opal
  module AST
    class Builder < ::Parser::Builders::Default
      self.emit_lambda = true
      self.emit_kwargs = true

      def n(type, children, location)
        ::Opal::AST::Node.new(type, children, location: location)
      end
    end
  end
end
