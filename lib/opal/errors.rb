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
    attr_accessor :location
  end

  def self.opal_location_from_error(error)
    opal_location = OpalBacktraceLocation.new
    opal_location.location = error.location if error.respond_to?(:location)
    opal_location.diagnostic = error.diagnostic if error.respond_to?(:diagnostic)
    opal_location
  end

  def self.add_opal_location_to_error(opal_location, error)
    backtrace = error.backtrace.to_a
    backtrace.unshift opal_location.to_s
    error.set_backtrace backtrace
    error
  end

  # Loosely compatible with Thread::Backtrace::Location
  class OpalBacktraceLocation
    attr_accessor :path, :lineno, :label

    def initialize(path = nil, lineno = nil, label = nil)
      @path, @lineno, @label = path, lineno, label
    end

    def to_s
      string = path
      string += ":#{lineno}" if lineno
      string += ':in '
      if label
        string += "`#{label}'"
      else
        string += 'unknown'
      end
      string
    end

    alias line lineno

    def diagnostic=(diagnostic)
      return unless diagnostic
      self.location = diagnostic.location
    end

    def location=(location)
      return unless location
      self.lineno = location.line
      if location.respond_to?(:source_line)
        self.label = location.source_line
      elsif location.respond_to?(:expression)
        self.label = location.expression.source_line
      end
    end
  end
end
