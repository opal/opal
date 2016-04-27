require 'opal/nodes/base'

module Opal
  module Nodes
    class ForNode < Base
      handle :for

      children :value, :args_sexp, :body_sexp

      def compile
        with_temp do |loop_var|
          if args_sexp.type == :array
            assign = s(:masgn, args_sexp)
            assign << s(:to_ary, s(:js_tmp, loop_var))
          else
            assign = args_sexp << s(:js_tmp, loop_var)
          end

          if body_sexp
            if body_sexp.first == :block
              body_sexp.insert 1, assign
              assign = body_sexp
            else
              assign = s(:block, assign, body_sexp)
            end
          end

          assign.children.each do |sexp|
            case sexp.type
            when :lasgn
              add_local sexp[1]
            when :masgn
              if sexp[1].type == :array
                sexp[1][1].each do |sexp|
                  add_local sexp[1] if sexp.type == :lasgn
                end
              end
            end
          end

          iter = s(:iter, s(:lasgn, loop_var), assign)
          sexp = s(:send, value, :each, s(:arglist), iter)
          push expr(sexp)
        end
      end
    end
  end
end
