# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class PatternMatching < Base
      def initialize
        @depth = 0
        super
      end

      # a => b
      def on_match_pattern(node)
        from, pat = *node

        s(:begin,
          s(:lvasgn, :"$pmvar", from),
          s(:if,
            convert_full_pattern(from, pat),
            nil,
            raise_no_matching_pattern_error(:"$pmvar")
          )
        )
      end

      # a in b
      def on_match_pattern_p(node)
        from, pat = *node

        s(:if,
          convert_full_pattern(from, pat),
          s(:true),
          s(:false)
        )
      end

      # case a; in b; end
      def on_case_match(node)
        @depth += 1

        cmvar = :"$cmvar#{@depth}"

        from, *cases, els = *node

        if els
          process els
        else
          els = raise_no_matching_pattern_error(cmvar)
        end

        s(:begin,
          s(:lvasgn, cmvar, from),
          single_case_match(cmvar, *cases, els)
        )
      end

      private

      # raise NoMatchingPatternError, from
      def raise_no_matching_pattern_error(from)
        s(:send, nil, :raise,
          s(:const, nil, :NoMatchingPatternError),
          s(:lvar, from)
        )
      end

      # in b
      def single_case_match(from, *cases, els)
        cas = cases.shift
        pat, if_guard, body = *cas

        pat = convert_full_pattern(from, pat)
        if if_guard
          guard, = *if_guard
          case if_guard.type
          when :if_guard
            pat = s(:and, pat, guard)
          when :unless_guard
            pat = s(:and, pat, s(:send, guard, :!))
          end
        end

        s(:if,
          pat,
          process(body),
          if !cases.empty?
            single_case_match(from, *cases, els)
          elsif els != s(:empty_else)
            els
          end
        )
      end

      def convert_full_pattern(from, pat)
        if from.class == Symbol
          from = s(:lvar, from)
        end

        converter = PatternConverter.new(pat)
        converter.run!

        # a, b, c = ::PatternMatching.(from, [...])
        s(:masgn,
          s(:mlhs,
            *converter.variables
          ),
          s(:send,
            s(:const, s(:cbase), :PatternMatching),
            :call,
            from,
            converter.pattern,
          )
        )
      end

      class PatternConverter < ::Opal::Rewriters::Base
        def initialize(pat)
          @pat = pat
          @variables = []
        end

        def run!
          @outpat = process(@pat)
        end

        def pattern
          @outpat
        end

        def variables
          @variables.map { |i| s(:lvasgn, i) }
        end

        # a
        def on_match_var(node)
          var, = *node

          @variables << var

          s(:sym, :var)
        end

        # [...] => a
        def on_match_as(node)
          pat, save = *node

          process(save)
          array(s(:sym, :save), process(pat))
        end

        def on_literal(node)
          array(s(:sym, :lit), node)
        end

        alias on_int on_literal
        alias on_float on_literal
        alias on_complex on_literal
        alias on_rational on_literal
        alias on_array on_literal
        alias on_str on_literal
        alias on_dstr on_literal
        alias on_xstr on_literal
        alias on_sym on_literal
        alias on_irange on_literal
        alias on_erange on_literal
        alias on_const on_literal
        alias on_regexp on_literal
        alias on_lambda on_literal
        alias on_begin on_literal

        # ^a
        def on_pin(node)
          on_literal(node.children.first)
        end

        # *
        def on_match_rest(node)
          if node.children.empty?
            array(s(:sym, :rest))
          else
            array(s(:sym, :rest), process(node.children.first))
          end
        end

        # {} | []
        def on_match_alt(node)
          array(s(:sym, :any), *node.children.map(&method(:process)))
        end

        # MyStructName
        def on_const_pattern(node)
          array(s(:sym, :all), *node.children.map(&method(:process)))
        end

        # [0, 1, 2] or [*, 0, 1] or [0, 1, *]
        def on_array_pattern(node, tail = false)
          children = *node
          children << s(:match_rest) if tail

          fixed_size = true
          array_size = 0

          children = children.each do |i|
            case i.type
            when :match_rest
              fixed_size = false
            else
              array_size += 1
            end
          end

          array(
            s(:sym, :array),
            to_ast(fixed_size),
            to_ast(array_size),
            to_ast(children.map(&method(:process)))
          )
        end

        # [0, 1, 2,]
        def on_array_pattern_with_tail(node)
          on_array_pattern(node, true)
        end

        # {a:, b:}
        def on_hash_pattern(node)
          children = *node

          any_size = children.empty? ? to_ast(false) : to_ast(true)

          children = children.map do |i|
            case i.type
            when :pair
              array(i.children[0], process(i.children[1]))
            when :match_var
              array(s(:sym, i.children[0]), process(i))
            when :match_nil_pattern
              any_size = to_ast(false)
              nil
            when :match_rest
              # Capturing rest?
              if i.children.first
                any_size = process(i.children.first)
              else
                any_size = to_ast(true)
              end
              nil
            end
          end.compact

          array(s(:sym, :hash), any_size, array(*children))
        end

        # [*, a, b, *]
        def on_find_pattern(node)
          children = *node

          children = children.map(&method(:process))

          array(s(:sym, :find), array(*children))
        end

        private

        def array(*args)
          to_ast(args)
        end

        def to_ast(val)
          case val
          when Array
            s(:array, *val)
          when Integer
            s(:int, val)
          when true
            s(:true)
          when false
            s(:false)
          when nil
            s(:nil)
          end
        end
      end
    end
  end
end
