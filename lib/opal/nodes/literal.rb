require 'opal/nodes/base'

module Opal
  module Nodes
    class ValueNode < Base
      handle :true, :false, :self, :nil

      def compile
        push type.to_s
      end

      def self.truthy_optimize?
        true
      end
    end

    class NumericNode < Base
      handle :int, :float

      children :value

      def compile
        push value.to_s
        wrap '(', ')' if recv?
      end

      def self.truthy_optimize?
        true
      end
    end

    class StringNode < Base
      handle :str

      children :value

      ESCAPE_CHARS = {
        ?a => '\\u0007',
        ?e => '\\u001b'
      }

      ESCAPE_REGEX = /(\\+)([#{ ESCAPE_CHARS.keys.join('') }])/

      def translate_escape_chars(inspect_string)
        inspect_string.gsub(ESCAPE_REGEX) do |original|
          if $1.length.even?
            original
          else
            $1.chop + ESCAPE_CHARS[$2]
          end
        end
      end

      def compile
        push translate_escape_chars(trimmed_value.inspect)
      end

      # Some unicode characters are too big,
      # MRI uses "\u{hex}" to display them
      # (which is invalid for JS)
      # There's no way to display them,
      # so we can simply trim them
      def trimmed_value
        value.each_char.map do |char|
          if char.valid_encoding? && char.ord > 65535
            @compiler.warning("Ignoring unsupported character #{char}", @sexp.line)
            ""
          else
            char
          end
        end.join
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

      attr_accessor :value, :flags

      def initialize(*)
        super
        extract_flags_and_value
      end

      def compile
        case value.type
        when :dstr, :begin
          compile_dynamic_regexp
        when :str
          compile_static_regexp
        end
      end

      def compile_dynamic_regexp
        if flags.any?
          push "new RegExp(", expr(value), ", '#{flags.join}')"
        else
          push "new RegExp(", expr(value), ')'
        end
      end

      def compile_static_regexp
        value = self.value.children[0]
        case value
        when ''
          push('/(?:)/')
        when %r{\?<\w+\>}
          message = "named captures are not supported in javascript: #{value.inspect}"
          push "self.$raise(new SyntaxError('#{message}'))"
        else
          print "/*regex value #{value} with flags #{flags.join} Source line : #{self.source_line}*/"

          push "#{Regexp.new(value).inspect}#{flags.join}"
        end
      end

      def extract_flags_and_value
        *values, flags_sexp = *children
        self.flags = flags_sexp.children.map(&:to_s)

        case values.length
        when 0
          # empty regexp, we can process it inline
          self.value = s(:str, '')
        when 1
          # simple plain regexp, we can put it inline
          self.value = values[0]
        else
          self.value = s(:dstr, *values)
        end

        # trimming when //x provided
        # required by parser gem, but JS doesn't support 'x' flag
        if flags.include?('x')
          parts = value.children.map do |part|
            if part.is_a?(::Parser::AST::Node) && part.type == :str
              trimmed_value = part.children[0].gsub(/\A\s*\#.*/, '').gsub(/\s/, '')
              s(:str, trimmed_value)
            else
              part
            end
          end

          self.value = value.updated(nil, parts)
          flags.delete('x')
        end

        if value.type == :str
          # Replacing \A -> ^, \z -> $, required for the parser gem
          self.value = s(:str, value.children[0].gsub("\\A", "^").gsub("\\z", "$"))
        end
      end

      def raw_value
        self.value = @sexp.loc.expression.source
      end
    end

    # $_ = 'foo'; call if /foo/
    # s(:if, s(:match_current_line, /foo/, true))
    class MatchCurrentLineNode < Base
      handle :match_current_line

      children :regexp

      # Here we just convert it to
      # ($_ =~ regexp)
      # and let :send node to handle it
      def compile
        gvar_sexp = s(:gvar, :$_)
        send_node = s(:send, gvar_sexp, :=~, regexp)
        push expr(send_node)
      end
    end

    class XStringNode < Base
      handle :xstr

      def compile
        children.each do |child|
          case child.type
          when :str
            value = child.loc.expression.source
            push Fragment.new(value, nil)
          when :begin
            push expr(child)
          when :gvar, :ivar
            push expr(child)
          when :js_return
            # A case for manually created :js_return statement in Compiler#returns
            # Since we need to take original source of :str
            # we have to use raw source
            # so we need to combine "return" with "raw_source"
            push "return "
            str = child.children.first
            value = str.loc.expression.source
            push Fragment.new(value, nil)
          else
            raise "Unsupported xstr part: #{child.type}"
          end
        end

        wrap '(', ')' if recv?
      end
    end

    class DynamicStringNode < Base
      handle :dstr

      def compile
        push '""'

        children.each_with_index do |part, idx|
          push " + "

          if part.type == :str
            push part.children[0].inspect
          else
            push "(", expr(part), ")"
          end

          wrap '(', ')' if recv?
        end
      end
    end

    class DynamicSymbolNode < DynamicStringNode
      handle :dsym
    end

    class RangeNode < Base
      children :start, :finish

      SIMPLE_CHILDREN_TYPES = [:int, :float, :str, :sym]

      def compile
        if compile_inline?
          helper :range
          compile_inline
        else
          compile_range_initialize
        end
      end

      def compile_inline?
        start.type == finish.type &&
          SIMPLE_CHILDREN_TYPES.include?(start.type) &&
          SIMPLE_CHILDREN_TYPES.include?(finish.type)
      end

      def compile_inline
        raise NotImplementedError
      end

      def compile_range_initialize
        raise NotImplementedError
      end
    end

    class InclusiveRangeNode < RangeNode
      handle :irange

      def compile_inline
        push '$range(', expr(start), ', ', expr(finish), ', false)'
      end

      def compile_range_initialize
        push 'Opal.Range.$new(', expr(start), ', ', expr(finish), ', false)'
      end
    end

    class ExclusiveRangeNode < RangeNode
      handle :erange

      def compile_inline
        push '$range(', expr(start), ', ', expr(finish), ', true)'
      end

      def compile_range_initialize
        push 'Opal.Range.$new(', expr(start), ',' , expr(finish), ', true)'
      end
    end

    # 0b1111r -> s(:rational, (15/1))
    # -0b1111r -> s(:rational, (-15/1))
    class RationalNode < Base
      handle :rational

      children :value

      def compile
        push "Opal.Rational.$new(#{value.numerator}, #{value.denominator})"
      end
    end

    # 0b1110i -> s(:complex, (0+14i))
    # -0b1110i -> s(:complex, (0-14i))
    class ComplexNode < Base
      handle :complex

      children :value

      def compile
        push "Opal.Complex.$new(#{value.real}, #{value.imag})"
      end
    end
  end
end
