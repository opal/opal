require 'opal/compiler'

module Opal
  # A parser which collects all require() statments for dependency building
  class DependencyCompiler < Compiler
    def self.compile source, options = {}
      self.new.compile source, options
    end

    # Holds an array of paths which this file 'requires'.
    # @return Array<String>
    attr_reader :requires

    def compile(source, options = {})
      @requires = []
      @dynamic_require_severity = (options[:dynamic_require_severity] || :error)
      super source, options
    end

    def handle_call(sexp)
      case sexp[2]
      when :require
        return handle_require(sexp[3][1])
      when :autoload
        if @scope.class_scope?
          return handle_require(sexp[3][2])
        end
      else
        super sexp
      end
    end

    def handle_require(sexp)
      str = handle_require_sexp sexp
      @requires << str unless str.nil? if @requires
      fragment("", sexp)
    end

    def handle_require_sexp(sexp)
      type = sexp.shift

      if type == :str
        return sexp[0]
      elsif type == :call
        recv, meth, args = sexp
        parts = args[1..-1].map { |s| handle_require_sexp s }

        if recv == [:const, :File]
          if meth == :expand_path
            return handle_expand_path(*parts)
          elsif meth == :join
            return handle_expand_path parts.join("/")
          elsif meth == :dirname
            return handle_expand_path parts[0].split("/")[0...-1].join("/")
          end
        end
      end


      case @dynamic_require_severity
      when :error
        error "Cannot handle dynamic require"
      when :warning
        warning "Cannot handle dynamic require"
      end
    end

    def handle_expand_path(path, base = '')
      "#{base}/#{path}".split("/").inject([]) do |p, part|
        if part == ''
          # we had '//', so ignore
        elsif part == '..'
          p.pop
        else
          p << part
        end

        p
      end.join "/"
    end
  end
end
