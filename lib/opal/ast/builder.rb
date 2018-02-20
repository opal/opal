# frozen_string_literal: true

require 'opal/ast/node'
require 'parser/ruby25'

module Opal
  module AST
    class Builder < ::Parser::Builders::Default
      def n(type, children, location)
        ::Opal::AST::Node.new(type, children, location: location)
      end
    end
  end
end
