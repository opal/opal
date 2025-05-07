# frozen_string_literal: true

module Opal
  module Nodes
    # This module takes care of providing information about the
    # closure stack that we have for the nodes during compile time.
    # This is not a typical node.
    #
    # Also, while loops are not closures per se, this module also
    # takes a note about them.
    #
    # Then we can use this information for control flow like
    # generating breaks, nexts, returns.
    class Closure
      NONE = 0

      @types = {}

      def self.add_type(name, value)
        const_set(name, value)
        @types[name] = value
      end

      def self.type_inspect(type)
        @types.reject do |_name, value|
          (type & value) == 0
        end.map(&:first).join("|")
      end

      add_type(:JS_FUNCTION,     1 <<  0) # everything that generates an IIFE
      add_type(:JS_LOOP,         1 <<  1) # exerything that generates a JS loop
      add_type(:JS_LOOP_INSIDE,  1 <<  2) # everything that generates an inside of a loop

      add_type(:DEF,             1 <<  3) # def
      add_type(:LAMBDA,          1 <<  4) # lambda
      add_type(:ITER,            1 <<  5) # iter, lambda
      add_type(:MODULE,          1 <<  6)
      add_type(:LOOP,            1 <<  7) # for building a catcher outside a loop
      add_type(:LOOP_INSIDE,     1 <<  8) # for building a catcher inside a loop
      add_type(:SEND,            1 <<  9) # to generate a break catcher after send with a block
      add_type(:TOP,             1 << 10)
      add_type(:RESCUE_RETRIER,  1 << 11) # a virtual loop to catch a retrier
      add_type(:RETRY_CONTAINER, 1 << 12) # a loop or inside loop that contains a retry

      ANY = 0xffffffff

      def initialize(node, type, parent)
        @node, @type, @parent = node, type, parent
        @catchers = []
        @throwers = {}
      end

      def register_catcher(type = :return)
        @catchers << type unless @catchers.include? type

        "$t_#{type}"
      end

      def register_thrower(type, id)
        @throwers[type] = id
      end

      def is?(type)
        (@type & type) != 0
      end

      def inspect
        "#<Closure #{Closure.type_inspect(type)} #{@node.class}>"
      end

      attr_accessor :node, :type, :parent, :catchers, :throwers

      module NodeSupport
        def push_closure(type = JS_FUNCTION)
          closure = Closure.new(self, type, select_closure)
          @compiler.closure_stack << closure
          @closure = closure
        end

        attr_accessor :closure

        def pop_closure
          compile_catcher
          @compiler.closure_stack.pop
          last = @compiler.closure_stack.last
          @closure = last if last&.node == self
        end

        def in_closure(type = JS_FUNCTION)
          closure = push_closure(type)
          out = yield closure
          pop_closure
          out
        end

        def select_closure(type = ANY, break_after: NONE)
          @compiler.closure_stack.reverse.find do |i|
            break if (i.type & break_after) != 0
            (i.type & type) != 0
          end
        end

        def generate_thrower(type, closure, value)
          id = closure.register_catcher(type)
          closure.register_thrower(type, id)
          push id, '.$throw(', expr_or_nil(value), ', ', scope.identify!, '.$$is_lambda)'
          id
        end

        def generate_thrower_without_catcher(type, closure, value)
          helper :thrower

          if closure.throwers.key? type
            id = closure.throwers[type]
          else
            id = compiler.unique_temp('t_')
            parent_scope = closure.node.scope&.parent || top_scope
            parent_scope.add_scope_temp("#{id} = $thrower('#{type}')")
            closure.register_thrower(type, id)
          end
          push id, '.$throw(', expr_or_nil(value), ', ', scope.identify!, '.$$is_lambda)'
          id
        end

        def thrower(type, value = nil)
          case type
          when :return
            thrower_closure = select_closure(DEF, break_after: MODULE | TOP)
            last_closure = select_closure(JS_FUNCTION)

            if !thrower_closure
              iter_closure = select_closure(ITER, break_after: DEF | MODULE | TOP)
              if iter_closure
                generate_thrower_without_catcher(:return, iter_closure, value)
              elsif compiler.eval?
                push 'Opal.t_eval_return.$throw(', expr_or_nil(value), ', false)'
              else
                error 'Invalid return'
              end
            elsif thrower_closure == last_closure
              push 'return ', expr_or_nil(value)
            else
              id = generate_thrower(:return, thrower_closure, value)
              # Additionally, register our thrower on the surrounding iter, if present
              iter_closure = select_closure(ITER, break_after: DEF | MODULE | TOP)
              iter_closure.register_thrower(:return, id) if iter_closure
            end
          when :eval_return
            thrower_closure = select_closure(DEF | LAMBDA, break_after: MODULE | TOP)

            if thrower_closure
              thrower_closure.register_catcher(:eval_return)
            end
          when :next, :redo
            thrower_closure = select_closure(ITER | LOOP_INSIDE, break_after: DEF | MODULE | TOP)
            last_closure = select_closure(JS_FUNCTION | JS_LOOP_INSIDE)

            if !thrower_closure
              error 'Invalid next'
            elsif thrower_closure == last_closure
              if thrower_closure.is? RETRY_CONTAINER
                generate_thrower(:next, thrower_closure, value)
              elsif thrower_closure.is? LOOP_INSIDE
                push 'continue'
              elsif thrower_closure.is? ITER | LAMBDA
                push 'return ', expr_or_nil(value)
              end
            else
              generate_thrower(:next, thrower_closure, value)
            end
          when :break
            thrower_closure = select_closure(SEND | LAMBDA | LOOP, break_after: DEF | MODULE | TOP)
            last_closure = select_closure(JS_FUNCTION | JS_LOOP)

            if !thrower_closure
              iter_closure = select_closure(ITER, break_after: DEF | MODULE | TOP)
              if iter_closure
                generate_thrower_without_catcher(:break, iter_closure, value)
              else
                error 'Invalid break'
              end
            elsif thrower_closure == last_closure
              if thrower_closure.is? RETRY_CONTAINER
                generate_thrower(:break, thrower_closure, value)
              elsif thrower_closure.is? JS_FUNCTION | LAMBDA
                push 'return ', expr_or_nil(value)
              elsif thrower_closure.is? LOOP
                push 'break'
              end
            else
              generate_thrower(:break, thrower_closure, value)
            end
          when :retry
            thrower_closure = select_closure(RESCUE_RETRIER, break_after: DEF | MODULE | TOP)
            last_closure = select_closure(JS_LOOP_INSIDE)

            if !thrower_closure
              error 'Invalid retry'
            elsif thrower_closure == last_closure
              push 'continue'
            else
              generate_thrower(:retry, thrower_closure, value)
            end
          end
        end

        def closure_is?(type)
          @closure.is?(type)
        end

        # Generate a catcher if thrower has been used
        def compile_catcher
          catchers = @closure.catchers

          return if catchers.empty?

          helper :thrower

          catchers_without_eval_return = catchers.grep_v(:eval_return)

          push "} catch($e) {"
          indent do
            catchers.each do |type|
              case type
              when :eval_return
                line "if ($e === Opal.t_eval_return) return $e.$v;"
              else
                line "if ($e === $t_#{type}) return $e.$v;"
              end
            end
            line "throw $e;"
          end
          line "}"

          unless catchers_without_eval_return.empty?
            push " finally {", *catchers_without_eval_return.map { |type| "$t_#{type}.is_orphan = true;" }, "}"
          end

          unshift "return " if closure_is? SEND

          unless catchers_without_eval_return.empty?
            unshift "var ", catchers_without_eval_return.map { |type| "$t_#{type} = $thrower('#{type}')" }.join(", "), "; "
          end
          unshift "try { "

          unless closure_is? JS_FUNCTION
            if scope.await_encountered
              wrap "(await (async function(){", "})())"
            else
              wrap "(function(){", "})()"
            end
          end
        end
      end

      module CompilerSupport
        def closure_stack
          @closure_stack ||= []
        end
      end
    end
  end
end
