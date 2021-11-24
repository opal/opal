# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class OpalEngineCheck < Base
      def initialize
        @canceled = {}
      end

      # Don't traverse defined? nodes.
      def on_defined?(node)
        node
      end

      def on_if(node)
        test, true_body, false_body = *node.children

        test = process(test)

        check_type = platform_check_type(test)

        case check_type
        when nil
          return super
        when true
          cut_parts = [false_body, test].compact
          out = process(true_body) if true_body
        when false
          cut_parts = [true_body, test].compact
          out = process(false_body) if false_body
        end

        add_captured_variables(out, cut_parts)
      end

      def on_js_tmp(node)
        var_name, = *node.children

        if @canceled.key? var_name
          @canceled[var_name]
        else
          node
        end
      end

      private

      # Returns true if a check is for Opal
      # Returns false if a check is for NOT Opal
      # Returns nil if it's not a platform check
      def platform_check_type(test)
        case test.type
        # The true and false cases of course clean up some code,
        # but for us it's mostly to reduce the cases.
        when :true
          true
        when :false
          false
        when :begin
          if test.children.length == 1
            platform_check_type(test.children.first)
          end
        when :send
          lhs, method, rhs = *test.children
          return nil unless INTERESTING_METHODS.include?(method)

          if method == :!
            ret = platform_check_type(lhs)
            return ret if ret.nil?
            return !ret
          end

          lhs_opal = can_be_statically_resolved_to_str_opal?(lhs)
          rhs_opal = can_be_statically_resolved_to_str_opal?(rhs)

          return nil if !lhs_opal && !rhs_opal

          check = lhs_opal == rhs_opal

          method == :!= ? !check : check
        when :lvasgn
          var_name, rval = *test.children
          return nil unless var_name.start_with? '$'
          type = platform_check_type(rval)
          unless type.nil?
            @canceled[var_name] = LVAR_VALUES[type]
            type
          end
        else
          nil
        end
      end

      def can_be_statically_resolved_to_str_opal?(node)
        case node.type
        when :lvasgn
          var_name, rval = *node.children
          is_str_opal = can_be_statically_resolved_to_str_opal?(rval)
          return false unless is_str_opal
          @canceled[var_name] = s(:str, 'opal')
          return true
        when :str
          return true if node == s(:str, 'opal')
        when :js_tmp
          var_name, = *node.children
          return @canceled[var_name] == s(:str, 'opal')
        when :const
          scope, const_name = *node.children

          return false unless [nil, s(:cbase)].include? scope

          RUBY_ENGINE_CHECK_CONSTS.include? const_name
        else
          false
        end
      end

      def add_captured_variables(out, removed)
        vars = removed.map { |i| capture_variables(i) }.flatten.compact.uniq

        unless vars.empty?
          varsexp = s(:if,
            s(:false),
            begin_with_stmts(
              vars.map do |i|
                s(:lvasgn, i.to_sym, s(:nil))
              end
            ),
            nil
          )
        end

        begin_with_stmts([varsexp, out].compact) || s(:nil)
      end

      def capture_variables(node, accum=[])
        if AST::Node === node
          case node.type
          when :lvasgn
            name, = *node.children
            accum << name unless name.start_with? '$'
          when :def, :iter, :block, :class, :module
            # Scope barrier
            return accum
          end
          node.children.each { |i| capture_variables(i, accum) }
        end
        accum
      end

      RUBY_ENGINE_CHECK_CONSTS = %i[RUBY_ENGINE RUBY_PLATFORM]

      LVAR_VALUES = {true => s(:true), false => s(:false)}

      INTERESTING_METHODS = %i[! == === !=]
    end
  end
end
