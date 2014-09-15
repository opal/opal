require 'opal/nodes/base'

module Opal
  module Nodes
    class ValueNode < Base
      handle :true, :false, :self, :nil

      def compile
        push type.to_s
      end
    end

    class NumericNode < Base
      handle :int, :float

      children :value

      def compile
        push value.to_s
        wrap '(', ')' if recv?
      end
    end

    class StringNode < Base
      handle :str

      children :value

      def compile
        push value.inspect
      end
    end

    class SymbolNode < Base
      handle :sym

      children :value

      def compile
        push value.to_s.inspect
      end
    end

    class RegexpNode < Base
      handle :regexp

      children :value, :flags

      def compile
        if value == ''
          push('/^/')
        else
          escaped = value.dup
          escaped.gsub!("\n", "\\n\\\n")
          escaped.gsub!("'", "\\\\'")
          escaped.gsub!("\\", "\\\\\\\\")
          unsupported = /[^imx]/.match flags
          raise SyntaxError, "unknown  regexp option - unsupported[0]" if unsupported
          options = 0
          if flags
            options = options | Regexp::IGNORECASE if flags.include?("i")
            options = options | Regexp::EXTENDED if flags.include?("x")
            options = options | Regexp::MULTILINE if flags.include?("m")
          end
          push "$scope.Regexp.$new('#{escaped}', #{options})"
        end
      end
    end

    module XStringLineSplitter
      def compile_split_lines(value, sexp)
        idx = 0
        value.each_line do |line|
          if idx == 0
            push line
          else
            line_sexp = s()
            line_sexp.source = [sexp.line + idx, 0]
            frag = Fragment.new(line, line_sexp)
            push frag
          end

          idx += 1
        end
      end
    end

    class XStringNode < Base
      include XStringLineSplitter

      handle :xstr

      children :value

      def needs_semicolon?
        stmt? and !value.to_s.include?(';')
      end

      def compile
        compile_split_lines(value.to_s, @sexp)

        push ';' if needs_semicolon?

        wrap '(', ')' if recv?
      end

      def start_line
        @sexp.line
      end
    end

    class DynamicStringNode < Base
      handle :dstr

      def compile
        children.each_with_index do |part, idx|
          push " + " unless idx == 0

          if String === part
            push part.inspect
          elsif part.type == :evstr
            push "("
            push expr(part[1])
            push ")"
          elsif part.type == :str
            push part[1].inspect
          elsif part.type == :dstr
            push "("
            push expr(part)
            push ")"
          else
            raise "Bad dstr part #{part.inspect}"
          end

          wrap '(', ')' if recv?
        end
      end
    end

    class DynamicSymbolNode < Base
      handle :dsym

      def compile
        children.each_with_index do |part, idx|
          push " + " unless idx == 0

          if String === part
            push part.inspect
          elsif part.type == :evstr
            push expr(s(:call, part.last, :to_s, s(:arglist)))
          elsif part.type == :str
            push part.last.inspect
          else
            raise "Bad dsym part"
          end
        end

        wrap '(', ')'
      end
    end

    class DynamicXStringNode < Base
      include XStringLineSplitter

      handle :dxstr

      def requires_semicolon(code)
        stmt? and !code.include?(';')
      end

      def compile
        needs_semicolon = false

        children.each do |part|
          if String === part
            compile_split_lines(part.to_s, @sexp)

            needs_semicolon = true if requires_semicolon(part.to_s)
          elsif part.type == :evstr
            push expr(part[1])
          elsif part.type == :str
            compile_split_lines(part.last.to_s, part)
            needs_semicolon = true if requires_semicolon(part.last.to_s)
          else
            raise "Bad dxstr part"
          end
        end

        push ';' if needs_semicolon
        wrap '(', ')' if recv?
      end
    end

    class DynamicRegexpNode < Base
      handle :dregx

      def compile
        children.each_with_index do |part, idx|
          push " + " unless idx == 0

          if String === part
            push part.inspect
          elsif part.type == :str
            push part[1].inspect
          else
            push expr(part[1])
          end
        end

        wrap '(new RegExp(', '))'
      end
    end

    class InclusiveRangeNode < Base
      handle :irange

      children :start, :finish

      def compile
        helper :range

        push '$range(', expr(start), ', ', expr(finish), ', false)'
      end
    end

    class ExclusiveRangeNode < Base
      handle :erange

      children :start, :finish

      def compile
        helper :range

        push '$range(', expr(start), ', ', expr(finish), ', true)'
      end
    end
  end
end
