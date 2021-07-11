# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  class Parser::Lexer
    def source_buffer=(source_buffer)
      @source_buffer = source_buffer

      if @source_buffer
        source = @source_buffer.source
        # Force UTF8 unpacking even if JS works with UTF-16/UCS-2
        # See: https://mathiasbynens.be/notes/javascript-encoding
        @source_pts = source.unpack('U*')
      else
        @source_pts = nil
      end
    end
  end

  class Parser::Lexer::Literal
    undef :extend_string

    def extend_string(string, ts, te)
      @buffer_s ||= ts
      @buffer_e = te

      # Patch for opal-parser, original:
      # @buffer << string
      @buffer += string
    end
  end

  class Parser::Source::Buffer
    def source_lines
      @lines ||= begin
        lines = @source.lines.to_a
        lines << '' if @source.end_with?("\n")
        lines.map { |line| line.chomp("\n") }
      end
    end
  end
end

module AST::Processor::Mixin
  undef process
  # This patch to #process removes a bit of dynamic abilities (removed
  # call to node.to_ast) and it tries to optimize away the string
  # operations and method existence check by caching them inside a
  # processor.
  #
  # This is the second most inefficient call in the compilation phase
  # so an optimization may be warranted.
  def process(node)
    return if node.nil?

    @_on_handler_cache ||= {}
    type = node.type

    on_handler = @_on_handler_cache[type] ||= begin
      handler = :"on_#{type}"
      handler = :handler_missing unless respond_to?(handler)
      handler
    end

    send(on_handler, node) || node
  end
end

class Parser::Builders::Default
  # string_value raises on invalid UTF-8 strings, like "\x80",
  # otherwise it's the same as value.
  undef string_value
  def string_value(token)
    value(token)
  end
end
