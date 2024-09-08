# frozen_string_literal: true

module Opal
  class Builder
    class Import
      def initialize(from:, relative:, what: :none, import_condition: nil)
        @from = from
        @what = what
        @relative = relative
        @import_condition = import_condition
      end

      attr_reader :from, :what, :relative, :import_condition

      alias relative? relative
    end
  end
end
