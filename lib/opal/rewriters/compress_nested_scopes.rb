# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    # This rewriter rewrites a common idiom of doing a nested class/module
    # structure in separate files, like the following:
    #
    #     module Opal
    #       module AST
    #         class Node
    #         end
    #       end
    #     end
    #
    # This rewrites it to a pseudo code like:
    #
    #     class Node
    #       (parent Node (parent AST))
    #     end
    #
    # By itself it doesn't fully handle the compression, but it provides
    # the necessary data for the ModuleNode.
    class CompressNestedScopes < Base
      def on_module(node)
        *pre, child = *node

        # Abort compressing if child is not a single class or module.
        if !child || !%i[class module].include?(child.type)
          return super
        end

        # Abort compressing if the superclass needs $nesting, eg.
        # module A
        #   class B < String
        #   end
        # end
        if child.type == :class
          _, superclass, _ = *child
          return super unless superclass.nil?
        end

        # Also abort compressing if your child doesn't have a relative
        # base, eg.:
        # module Foo
        #   module Bar::Baz
        #   end
        # end
        name_and_base, * = *child
        base, _ = *name_and_base

        if name_and_base.type != :const || !base.nil?
          return super
        end

        parents = node.meta[:parent_scopes].dup || []
        parents.unshift(node.updated(nil, [*pre, nil], meta: { **node.meta, compressed: true }))
        process(child.updated(nil, nil, meta: { parent_scopes: parents }))
      end

      alias on_class on_module
    end
  end
end
