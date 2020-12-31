# frozen_string_literal: true

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
        'a' => '\\u0007',
        'e' => '\\u001b'
      }.freeze

      ESCAPE_REGEX = /(\\+)([#{ ESCAPE_CHARS.keys.join('') }])/.freeze

      def translate_escape_chars(inspect_string)
        inspect_string.gsub(ESCAPE_REGEX) do |original|
          if Regexp.last_match(1).length.even?
            original
          else
            Regexp.last_match(1).chop + ESCAPE_CHARS[Regexp.last_match(2)]
          end
        end
      end

      def compile
        string_value = value

        sanitized_value = string_value.inspect.gsub(/\\u\{([0-9a-f]+)\}/) do
          code_point = Regexp.last_match(1).to_i(16)
          to_utf16(code_point)
        end
        push translate_escape_chars(sanitized_value)

        if RUBY_ENGINE != 'opal'
          encoding = string_value.encoding

          unless encoding == Encoding::UTF_8
            helper :enc
            wrap "$enc(", ", \"#{encoding.name}\")"
          end
        end
      end

      # http://www.2ality.com/2013/09/javascript-unicode.html
      def to_utf16(code_point)
        ten_bits = 0b1111111111
        u = ->(code_unit) { '\\u' + code_unit.to_s(16).upcase }

        return u.call(code_point) if code_point <= 0xFFFF

        code_point -= 0x10000

        # Shift right to get to most significant 10 bits
        lead_surrogate = 0xD800 + (code_point >> 10)

        # Mask to get least significant 10 bits
        tail_surrogate = 0xDC00 + (code_point & ten_bits)

        u.call(lead_surrogate) + u.call(tail_surrogate)
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

      # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp
      SUPPORTED_FLAGS = /[gimuy]/.freeze

      def initialize(*)
        super
        extract_flags_and_value
      end

      def compile
        flags.select! do |flag|
          if SUPPORTED_FLAGS =~ flag
            true
          else
            compiler.warning "Skipping the '#{flag}' Regexp flag as it's not widely supported by JavaScript vendors."
            false
          end
        end

        if value.type == :str
          compile_static_regexp
        else
          compile_dynamic_regexp
        end
      end

      def compile_dynamic_regexp
        push 'Opal.regexp(['
        value.children.each_with_index do |v, index|
          push ', ' unless index.zero?
          push expr(v)
        end
        push ']'
        push ", '#{flags.join}'" if flags.any?
        push ")"
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
          push "#{Regexp.new(value).inspect}#{flags.join}"
        end
      end

      def extract_flags_and_value
        *values, flags_sexp = *children
        self.flags = flags_sexp.children.map(&:to_s)

        self.value = case values.length
                     when 0
                       # empty regexp, we can process it inline
                       s(:str, '')
                     when 1
                       # simple plain regexp, we can put it inline
                       values[0]
                     else
                       s(:dstr, *values)
                     end

        # trimming when //x provided
        # required by parser gem, but JS doesn't support 'x' flag
        if flags.include?('x')
          parts = value.children.map do |part|
            if part.is_a?(::Opal::AST::Node) && part.type == :str
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
          self.value = s(:str, value.children[0].gsub('\A', '^').gsub('\z', '$'))
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

    class DynamicStringNode < Base
      handle :dstr

      def compile
        push '""'

        children.each do |part|
          push ' + '

          if part.type == :str
            push part.children[0].inspect
          else
            push '(', expr(part), ')'
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

      SIMPLE_CHILDREN_TYPES = %i[int float str sym].freeze

      def compile
        if compile_inline?
          helper :range
          compile_inline
        else
          compile_range_initialize
        end
      end

      def compile_inline?
        (
          !start || (start.type && SIMPLE_CHILDREN_TYPES.include?(start.type))
        ) && (
          !finish || (finish.type && SIMPLE_CHILDREN_TYPES.include?(finish.type))
        )
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
        push '$range(', expr_or_nil(start), ', ', expr_or_nil(finish), ', false)'
      end

      def compile_range_initialize
        push 'Opal.Range.$new(', expr_or_nil(start), ', ', expr_or_nil(finish), ', false)'
      end
    end

    class ExclusiveRangeNode < RangeNode
      handle :erange

      def compile_inline
        push '$range(', expr_or_nil(start), ', ', expr_or_nil(finish), ', true)'
      end

      def compile_range_initialize
        push 'Opal.Range.$new(', expr_or_nil(start), ',', expr_or_nil(finish), ', true)'
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
