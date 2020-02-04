# frozen_string_literal: true

module Opal
  module Nodes
    class XStringNode < Base
      handle :xstr

      def compile
        @should_add_semicolon = false
        unpacked_children = unpack_return(children)
        stripped_children = strip_empty_children(unpacked_children)

        if single_line?(stripped_children)
          # If it's a single line we'll try to:
          #
          # - strip empty lines
          # - remove a trailing `;`
          # - detect an embedded `return`
          # - prepend a `return` when needed
          # - append a `;` when needed
          # - warn the user not to use the semicolon in single-line x-strings
          compile_single_line(stripped_children)
        else
          # Here we leave to the user the responsibility to add
          # a return where it's due.
          unpacked_children.each { |c| compile_child(c) }
        end

        wrap '(', ')' if recv?
        push ';' if @should_add_semicolon
      end


      private

      def compile_child(child)
        case child.type
        when :str
          value = child.loc.expression.source
          push Fragment.new(value, scope, child)
        when :begin, :gvar, :ivar, :nil, :lvar
          push expr(child)
        else
          raise "Unsupported xstr part: #{child.type}"
        end
      end

      def compile_single_line(children)
        has_embeded_return = false

        first_child  = children.shift
        single_child = children.empty?

        first_child ||= s(:nil)

        if first_child.type == :str
          first_value = first_child.loc.expression.source.strip
          has_embeded_return = first_value =~ /^return\b/
        end

        push('return ') if @returning && !has_embeded_return

        last_child = children.pop || first_child
        last_value = extract_last_value(last_child) if last_child.type == :str

        unless single_child
          # assuming there's an interpolation somewhere (type != :str)
          @should_add_semicolon = false
          compile_child(first_child)
          children.each { |c| compile_child(c) }
        end

        if last_child.type == :str
          push Fragment.new(last_value, scope, last_child)
        else
          compile_child(last_child)
        end
      end

      # Will drop the trailing semicolon if all conditions are met
      def extract_last_value(last_child)
        last_value = last_child.loc.expression.source.rstrip

        if (@returning || expr?) && last_value.end_with?(';')
          compiler.warning(
            'Removed semicolon ending x-string expression, interpreted as unintentional',
            last_child.line,
          )
          last_value = last_value[0..-2]
        end

        @should_add_semicolon = true if @returning

        last_value
      end

      # Check if there's only one child or if they're all part of
      # the same line (e.g. because of interpolations)
      def single_line?(children)
        (children.size == 1) || children.none? do |c|
          c.type == :str && c.loc.expression.source.end_with?("\n")
        end
      end

      # A case for manually created :js_return statement in Compiler#returns
      # Since we need to take original source of :str we have to use raw source
      # so we need to combine "return" with "raw_source"
      def unpack_return(children)
        first_child = children.first
        @returning  = false

        if first_child.type == :js_return
          @returning = true
          children = first_child.children
        end

        children
      end

      # Will remove empty :str lines coming from cosmetic newlines in x-strings
      #
      # @example
      #   # this will generate two additional empty
      #   # children before and after `foo()`
      #   %x{
      #     foo()
      #   }
      def strip_empty_children(children)
        children = children.dup
        empty_line = ->(child) { child.nil? || (child.type == :str && child.loc.expression.source.rstrip.empty?) }

        children.shift while children.any? && empty_line[children.first]
        children.pop while children.any? && empty_line[children.last]

        children
      end
    end
  end
end
