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

  class Parser::Builders::Default
    def check_lvar_name(name, loc)
      # https://javascript.info/regexp-unicode
      if name =~ `new RegExp('^[\\p{Ll}|_][\\p{L}\\p{Nl}\\p{Nd}_]*$', 'u')`
        # OK
      else
        diagnostic :error, :lvar_name, { name: name }, loc
      end
    end

    # Taken From:
    # https://github.com/whitequark/parser/blob/a7c638b7b205db9213a56897b41a8e5620df766e/lib/parser/builders/default.rb#L388
    def dedent_string(node, dedent_level)
      if !dedent_level.nil?
        dedenter = Lexer::Dedenter.new(dedent_level)

        case node.type
        when :str
          str = node.children.first
          dedenter.dedent(str)
        when :dstr, :xstr
          children = node.children.map do |str_node|
            if str_node.type == :str
              str = str_node.children.first
              dedenter.dedent(str)
              next nil if str.empty?
            else
              dedenter.interrupt
            end
            str_node
          end

          node = node.updated(nil, children.compact)
        end
      end

      node
    end
  end

  class Parser::Lexer::Dedenter
    # Taken From:
    # https://github.com/whitequark/parser/blob/6337d7bf676f66d80e43bd9d33dc17659f8af7f3/lib/parser/lexer/dedenter.rb#L36
    def dedent(string)
      original_encoding = string.encoding
      # Prevent the following error when processing binary encoded source.
      # "\xC0".split # => ArgumentError (invalid byte sequence in UTF-8)
      lines = string.force_encoding(Encoding::BINARY).split("\\\n")
      if lines.length == 1
        # If the line continuation sequence was found but there is no second
        # line, it was not really a line continuation and must be ignored.
        lines = [string.force_encoding(original_encoding)]
      else
        lines.map! {|s| s.force_encoding(original_encoding) }
      end

      if @at_line_begin
        lines_to_dedent = lines
      else
        _first, *lines_to_dedent = lines
      end

      lines_to_dedent.each do |line|
        left_to_remove = @dedent_level
        remove = 0

        line.each_char do |char|
          break if left_to_remove <= 0
          case char
          when ?\s
            remove += 1
            left_to_remove -= 1
          when ?\t
            break if TAB_WIDTH * (remove / TAB_WIDTH + 1) > @dedent_level
            remove += 1
            left_to_remove -= TAB_WIDTH
          else
            # no more spaces or tabs
            break
          end
        end

        line.slice!(0, remove)
      end

      string.replace(lines.join)

      @at_line_begin = string.end_with?("\n")
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
