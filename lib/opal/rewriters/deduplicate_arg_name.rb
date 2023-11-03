# frozen_string_literal: true

module Opal
  module Rewriters
    # Ruby allows for args with the same name, if the arg starts with a '_', like:
    #   def funny_method_name(_, _)
    #     puts _
    #   end
    # but JavaScript in strict mode does not allow for args with the same name
    # Ruby assigns the value of the first arg given
    #   funny_method_name(1, 2) => 1
    # leave the first appearance as it is and rename the other ones
    # compiler result:
    #   function $$funny_method_name(_, __$2)
    class DeduplicateArgName < Base
      def on_args(node)
        @arg_name_count = Hash.new(0)

        children = node.children.map do |arg|
          rename_arg(arg)
        end

        super(node.updated(nil, children))
      end

      def rename_arg(arg)
        case arg.type
        when :arg, :restarg, :kwarg, :kwrestarg, :blockarg
          name = arg.children[0]
          name ? arg.updated(nil, [unique_name(name)]) : arg
        when :optarg, :kwoptarg
          name, value = arg.children
          arg.updated(nil, [unique_name(name), value])
        when :mlhs
          new_children = arg.children.map { |child| rename_arg(child) }
          arg.updated(nil, new_children)
        else
          arg
        end
      end

      def unique_name(name)
        count = (@arg_name_count[name] += 1)
        count > 1 ? :"#{name}_$#{count}" : name
      end
    end
  end
end
