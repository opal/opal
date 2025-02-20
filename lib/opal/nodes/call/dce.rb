# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    class CallNode
      def dce_matcher(methods)
        case methods.length
        when 0
        when 1
          methods.first
        else
          methods
        end
      end

      def dce_symbol_arguments_matcher
        if arglist.children.all? { |c| c.type == :sym }
          methods = arglist.children.map { |c| c.children[0] }
          methods = yield(methods) if block_given?
          matcher = dce_matcher(methods)

          placeholder = methods.to_json unless stmt?
        end
        [matcher, placeholder]
      end

      # Add additional awareness for certain calls.
      add_special :attr_reader do |default|
        matcher, placeholder = dce_symbol_arguments_matcher

        push dce_def_begin(matcher, placeholder: placeholder) if matcher
        default.call
        push dce_def_end(matcher) if matcher
      end

      add_special :attr_writer do |default|
        matcher, placeholder = dce_symbol_arguments_matcher do |ary|
          ary.map { |i| :"#{i}=" }
        end

        push dce_def_begin(matcher, placeholder: placeholder) if matcher
        default.call
        push dce_def_end(matcher) if matcher
      end

      add_special :attr_accessor do |default|
        matcher, placeholder = dce_symbol_arguments_matcher do |ary|
          ary.map { |i| [i, :"#{i}="] }.flatten
        end

        push dce_def_begin(matcher, placeholder: placeholder) if matcher
        default.call
        push dce_def_end(matcher) if matcher
      end

      add_special :alias_method do |default|
        if arglist.children.all? { |c| c.type == :sym } &&
           arglist.children.length == 2

          new_func, old_func = arglist.children.map { |c| c.children[0] }

          placeholder = new_func.to_s.to_json unless stmt?

          push dce_def_begin(new_func, placeholder: placeholder)
          push dce_use(old_func)
          default.call
          push dce_def_end(new_func)
        else
          default.call
        end
      end

      def dce_make_constant_definition(default, const_node, const_type, const_child)
        if const_node&.type == const_type
          name = const_node.children[const_child]

          push dce_def_begin(name, placeholder: 'false', type: :const)
          default.call
          push dce_def_end(name, type: :const)
        else
          default.call
        end
      end

      # In const mode, calls like: `::Rational === string` can be
      # marked as definition.
      # This is to allow stripping of such calls if there's no
      # class to begin with.
      add_special :=== do |default|
        dce_make_constant_definition(default, recvr, :const, 1)
      end

      add_special :autoload do |default|
        dce_make_constant_definition(default, arglist.children.first, :sym, 0)
      end
    end
  end
end
