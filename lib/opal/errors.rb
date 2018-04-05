# frozen_string_literal: true

module Opal
  # Generic Opal error
  class Error < StandardError
  end

  # raised if Gem not found in Opal#use_gem
  class GemNotFound < Error
    # name of gem that not found
    attr_reader :gem_name

    # @param gem_name [String] name of gem that not found
    def initialize(gem_name)
      @gem_name = gem_name
      super("can't find gem #{gem_name}")
    end
  end

  class CompilationError < Error
    attr_accessor :location
  end

  class ParsingError < CompilationError
  end

  class RewritingError < ParsingError
  end

  class SyntaxError < ::SyntaxError
  end
end
