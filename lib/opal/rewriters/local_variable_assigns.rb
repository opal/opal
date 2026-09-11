# frozen_string_literal: true

require 'set'
require 'opal/rewriters/base'

module Opal
  module Rewriters
    # Collects the names of local variables assigned anywhere inside a node.
    #
    # Ruby exposes a local variable to the rest of the enclosing scope as soon
    # as the parser sees an assignment to it, even when that assignment never
    # runs. Rewriters that move or drop code need those names so the compiler
    # still declares them and reading one yields nil instead of a JavaScript
    # ReferenceError.
    #
    # Assignments inside a def, class, module or sclass body belong to a new
    # Ruby scope and stay invisible outside it, so those subtrees are skipped.
    # Blocks do not open a new scope for this purpose and are traversed.
    class LocalVariableAssigns < Base
      SCOPE_BOUNDARIES = %i[def defs class module sclass].freeze

      def self.find(node)
        processor = new
        processor.process(node)
        processor.result.to_a
      end

      attr_reader :result

      def initialize
        @result = Set.new
      end

      def on_lvasgn(node)
        name, _ = *node
        result << name
        super
      end

      SCOPE_BOUNDARIES.each do |type|
        define_method(:"on_#{type}") { |node| node }
      end
    end
  end
end
