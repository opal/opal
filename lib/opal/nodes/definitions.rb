# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class UndefNode < Base
      handle :undef

      children :value

      def compile
        helper :udef

        children.each do |child|
          push dce_def_begin(child.children.first) if child.type == :sym
          line "$udef(#{scope.self}, '$' + ", expr(child), ');'
          push dce_def_end(child.children.first) if child.type == :sym
        end
      end
    end

    class AliasNode < Base
      handle :alias

      children :new_name, :old_name

      def compile
        # We only need to check one type, because parser otherwise denies invalid expressions
        case new_name.type
        when :gvar # This is a gvar alias: alias $a $b
          helper :alias_gvar
          new_name_str = new_name.children.first.to_s[1..-1].inspect
          old_name_str = old_name.children.first.to_s[1..-1].inspect
          push '$alias_gvar(', new_name_str, ', ', old_name_str, ')'
        when :dsym, :sym # This is a method alias: alias a b
          helper :alias
          if old_name.type == :sym
            compiler.record_method_call old_name.children.last
            if new_name.type == :sym
              push dce_def_begin(new_name.children.first)
            end
            push dce_use(old_name.children.first)
          end
          push "$alias(#{scope.self}, ", expr(new_name), ', ', expr(old_name), ')'
          if old_name.type == :sym && new_name.type == :sym
            push dce_def_end(new_name.children.first)
          end
        else # Nothing else is available, but just in case, drop an error
          error "Opal doesn't know yet how to alias with #{new_name.type}"
        end
      end
    end

    class BeginNode < ScopeNode
      handle :begin

      def compile
        return push 'nil' if children.empty?

        if stmt?
          compile_children(children, @level)
        elsif simple_children?
          compile_inline_children(children, @level)
          wrap '(', ')' if children.size > 1
        elsif children.size == 1
          compile_inline_children(returned_children, @level)
        else
          in_closure do
            compile_children(returned_children, @level)
          end

          if scope.parent&.await_encountered
            wrap '(await (async function() {', '})())'
          else
            wrap '(function() {', '})()'
          end
        end
      end

      def returned_children
        @returned_children ||= begin
          *rest, last_child = *children
          if last_child
            rest + [compiler.returns(last_child)]
          else
            [s(:nil)]
          end
        end
      end

      def compile_children(children, level)
        children.each do |child|
          line process(child, level), fragment(';', loc: false)
        end
      end

      COMPLEX_CHILDREN = %i[while while_post until until_post js_return].freeze

      def simple_children?
        children.none? do |child|
          COMPLEX_CHILDREN.include?(child.type)
        end
      end

      def compile_inline_children(children, level)
        processed_children = children.map do |child|
          process(child, level)
        end

        processed_children.reject(&:empty?).each_with_index do |child, idx|
          push fragment(', ', loc: false) unless idx == 0
          push child
        end
      end
    end

    class KwBeginNode < BeginNode
      handle :kwbegin
    end
  end
end
