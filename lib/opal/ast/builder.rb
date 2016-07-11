require 'opal/ast/node'
require 'parser/ruby23'

module Opal
  module AST
    class Builder < ::Parser::Builders::Default
      def string_value(token)
        token[0]
      end

      def n(type, children, location)
        ::Opal::AST::Node.new(type, children, location: location)
      end
    end
  end
end
