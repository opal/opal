# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/regexp_transpiler'

module Opal
  module Nodes
    class ValueNode < Base
      handle :true, :false, :nil

      def compile
        push type.to_s
      end

      def self.truthy_optimize?
        true
      end
    end

    class SelfNode < Base
      handle :self

      def compile
        push scope.self
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

        unless value.valid_encoding?
          helper :binary
          wrap "$binary(", ")"
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
        helper :regexp

        push '$regexp(['
        value.children.each_with_index do |v, index|
          push ', ' unless index.zero?
          push expr(v)
        end
        push ']'
        push ", '#{flags.join}'" if flags.any?
        push ")"
      end

      include Opal::RegexpTranspiler

      def compile_static_regexp
        value = self.value.children[0]
        case value
        when ''
          helper :empty_regexp
          push("$empty_regexp(#{flags.join.inspect})")
        when /\(\?[(<>#]|[*+?]\+|\\G/
          # Safari/WebKit will not execute javascript code if it contains a lookbehind literal RegExp
          # and they fail with "Syntax Error". This tricks their parser by disguising the literal RegExp
          # as string for the dynamic $regexp helper. Safari/Webkit will still fail to execute the RegExp,
          # but at least they will parse and run everything else.
          #
          # Also, let's compile a couple of more patterns into $regexp calls, as there are many syntax
          # errors in RubySpec when ran in reverse, while there shouldn't be (they should be catchable
          # errors) - at least since Node 17.
          static_as_dynamic(value)
        else
          regexp_content = Regexp.new(value).inspect[1..-2]
          old_flags = flags.join
          new_regexp, new_flags = transform_regexp(regexp_content, old_flags)
          push "/#{new_regexp}/#{new_flags}"

          # Annotate the source regexp and flags, so it can be used to redo transforming while doing
          # unions etc.
          if regexp_content != new_regexp || old_flags != new_flags
            helper :annotate_regexp
            wrap '$annotate_regexp(', ", #{regexp_content != new_regexp ? regexp_content.inspect : 'null'}" \
              "#{old_flags != new_flags ? ", #{old_flags.inspect}" : ''})"
          end
        end
      end

      def static_as_dynamic(value)
        helper :regexp

        push '$regexp(["'
        push value.gsub('\\', '\\\\\\\\').gsub('"', '\"')
        push '"]'
        push ", '#{flags.join}'" if flags.any?
        push ")"
      end

      def extract_flags_and_value
        *values, flags_sexp = *children
        self.flags = flags_sexp.children.map(&:to_s)

        self.value = if values.empty?
                       # empty regexp, we can process it inline
                       s(:str, '')
                     elsif single_line?(values)
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
      end

      def raw_value
        self.value = @sexp.loc.expression.source
      end

      private

      def single_line?(values)
        return false if values.length > 1

        value = values[0]
        # JavaScript doesn't support multiline regexp
        value.type != :str || !value.children[0].include?("\n")
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
        if children.length > 1 && children.first.type == :str
          skip_empty = true
        else
          push '""'
        end

        children.each do |part|
          if skip_empty
            skip_empty = false
          else
            push ' + '
          end

          if part.type == :str
            push expr(part)
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
        push "#{top_scope.absolute_const}('Rational').$new(#{value.numerator}, #{value.denominator})"
      end
    end

    # 0b1110i -> s(:complex, (0+14i))
    # -0b1110i -> s(:complex, (0-14i))
    class ComplexNode < Base
      handle :complex

      children :value

      def compile
        push "#{top_scope.absolute_const}('Complex').$new(#{value.real}, #{value.imag})"
      end
    end
  end
end
