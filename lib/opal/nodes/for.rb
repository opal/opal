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

          body = if body_sexp
                   if body_sexp.first == :block
                     body_sexp.insert 1, assign
                     body_sexp
                   else
                     s(:block, assign, body_sexp)
                   end
                 else
                   assign
                 end

          iter = s(:iter, s(:lasgn, loop_var), body)
          sexp = s(:call, value, :each, s(:arglist), iter)
          push expr(sexp)
        end
      end
    end
  end
end
