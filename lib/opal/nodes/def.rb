require 'opal/nodes/node_with_args'

module Opal
  module Nodes
    # FIXME: needs rewrite
    class DefNode < NodeWithArgs
      handle :def

      children :recvr, :mid, :args, :stmts

      def block_arg
        @block_arg ||= args[1..-1].find { |arg| arg.first == :blockarg }
      end

      def argc
        return @argc if @argc

        @argc = args.length - 1
        @argc -= 1 if block_arg
        @argc -= 1 if rest_arg
        @argc -= keyword_args.size

        @argc
      end

      def compile
        params = nil
        scope_name = nil

        # block name (&block)
        if block_arg
          block_name = variable(block_arg[1]).to_sym
        end

        if compiler.arity_check?
          arity_code = arity_check(args, opt_args, rest_arg, keyword_args, block_name, mid)
        end

        in_scope do
          scope.mid = mid
          scope.defs = true if recvr

          if block_name
            scope.uses_block!
            scope.add_arg block_name
          end

          scope.block_name = block_name || '$yield'

          params = process(args)
          stmt_code = stmt(compiler.returns(stmts))

          add_temp 'self = this'

          compile_rest_arg
          compile_opt_args
          compile_keyword_args

          # must do this after opt args incase opt arg uses yield
          scope_name = scope.identity

          compile_block_arg

          if rest_arg
            scope.locals.delete(rest_arg[1])
          end

          if scope.uses_zuper
            add_local '$zuper'
            add_local '$zuper_index'
            add_local '$zuper_length'

            line "$zuper = [];"
            line
            line "for($zuper_index = 0; $zuper_index < arguments.length; $zuper_index++) {"
            line "  $zuper[$zuper_index] = arguments[$zuper_index];"
            line "}"
          end

          unshift "\n#{current_indent}", scope.to_vars

          line arity_code if arity_code

          line stmt_code

          if scope.catch_return
            unshift "try {\n"
            line "} catch ($returner) { if ($returner === Opal.returner) { return $returner.$v }"
            push " throw $returner; }"
          end
        end

        unshift ") {"
        unshift(params)
        unshift "function #{function_name(mid)}("
        unshift "#{scope_name} = " if scope_name
        line "}"

        if recvr
          unshift 'Opal.defs(', recv(recvr), ", '$#{mid}', "
          push ')'
        elsif scope.iter?
          wrap "Opal.def(self, '$#{mid}', ", ')'
        elsif scope.module? || scope.class?
          wrap "Opal.defn(self, '$#{mid}', ", ')'
        elsif scope.sclass?
          if scope.defs
            unshift "Opal.defs(self, '$#{mid}', "
          else
            unshift "Opal.defn(self, '$#{mid}', "
          end
          push ')'
        elsif compiler.eval?
          unshift "Opal.def(self, '$#{mid}', "
          push ')'
        elsif scope.top?
          unshift "Opal.defn(Opal.Object, '$#{mid}', "
          push ')'
        else
          raise "Unsupported use of `def`; please file a bug at https://github.com/opal/opal reporting this message."
        end

        wrap '(', ", nil) && '#{mid}'" if expr?
      end

      # Returns code used in debug mode to check arity of method call
      def arity_check(args, opt, splat, kwargs, block_name, mid)
        meth = mid.to_s.inspect

        arity = args.size - 1
        arity -= (opt.size)

        arity -= 1 if splat

        arity -= (kwargs.size)

        arity -= 1 if block_name
        arity = -arity - 1 if !opt.empty? or !kwargs.empty? or splat

        # $arity will point to our received arguments count
        aritycode = "var $arity = arguments.length;"

        if arity < 0 # splat or opt args
          min_arity = -(arity + 1)
          max_arity = args.size - 1
          max_arity -= 1 if block_name
          checks = []
          checks << "$arity < #{min_arity}" if min_arity > 0
          checks << "$arity > #{max_arity}" if max_arity and not(splat)
          aritycode + "if (#{checks.join(' || ')}) { Opal.ac($arity, #{arity}, this, #{meth}); }" if checks.size > 0
        else
          aritycode + "if ($arity !== #{arity}) { Opal.ac($arity, #{arity}, this, #{meth}); }"
        end
      end
    end

    # def args list
    class ArgsNode < Base
      handle :args

      def compile
        done_kwargs = false
        have_rest   = false
        first_arg = true

        children.each_with_index do |child, idx|
          case child.first
          when :kwarg, :kwoptarg, :kwrestarg
            if have_rest
              scope.args_after_rest_args << child
            elsif !done_kwargs
              done_kwargs = true
              push ', ' unless first_arg
              first_arg = false
              scope.add_arg '$kwargs'
              push '$kwargs'
            end

          when :blockarg
            # we ignore it because we don't need it

          when :restarg
            have_rest = true

            if idx == children.length - 1
              push ', ' unless first_arg
              push '$restarg'
            end
          when :mlhs

            if have_rest
              scope.args_after_rest_args << child
            else
              tmp = scope.next_temp
              scope.add_arg tmp
              push ', ' unless first_arg
              first_arg = false
              push tmp
              scope.mlhs_mapping[child] = tmp

              child.children.each do |child|
                # No support for nested mlhs yet
                if child.type != :mlhs
                  scope.add_temp variable(child.last)
                end
              end
            end

          else
            if have_rest
              # to handle cases like
              # def m(a, *b, c, d: 1) -> function(a) { // extracting args manually }
              scope.args_after_rest_args << child
            else
              child = child[1].to_sym
              push ', ' unless first_arg
              first_arg = false
              child = variable(child.to_sym)
              scope.add_arg child.to_sym
              push child.to_s
            end
          end
        end
      end
    end
  end
end
