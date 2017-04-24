# frozen_string_literal: true
module Opal
  module Deprecations
    attr_accessor :raise_on_deprecation

    def deprecation message
      message = "DEPRECATION WARNING: #{message}"
      if @raise_on_deprecation
        raise message
      else
        warn message
      end
    end
  end

  extend Deprecations
  self.raise_on_deprecation = false
end
