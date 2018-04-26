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

    # Not redefining #backtrace because of https://bugs.ruby-lang.org/issues/14693
    def self.with_opal_backtrace(error, path)
      new_error = new(error.message)
      backtrace = error.backtrace.to_a
      backtrace.unshift OpalBacktraceLocation.new(error, path).to_s
      new_error.set_backtrace backtrace
      new_error
    end
  end

  # Loosely compatible with Thread::Backtrace::Location
  class OpalBacktraceLocation
    attr_reader :error, :path

    def initialize(error, path)
      @error = error
      @path = path
    end

    def location
      if error.respond_to? :location
        error.location
      elsif error.respond_to?(:diagnostic) && error.diagnostic.respond_to?(:location)
        error.diagnostic.location
      end
    end

    def lineno
      location.line if location
    end

    # Use source code as the label
    def label
      case
      when location.respond_to?(:source_line)
        location.source_line
      when location.respond_to?(:expression)
        location.expression.source_line
      end
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
  end
end
