# frozen_string_literal: true

module Opal
  module Nodes
    class JsFragments < Base
      handle :js_fragments

      def compile
        push(*@sexp)
      end
    end
  end
end
