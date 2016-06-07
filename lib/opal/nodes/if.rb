require 'opal/nodes/base'

module Opal
  module Nodes
    class IfNode < Base
      handle :if

      children :test, :true_body, :false_body

      def self.s(type, *children)
        ::Parser::AST::Node.new(type, children)
      end

      RUBY_ENGINE_CHECK = s(:send, s(:const, nil, :RUBY_ENGINE),
                              :==, s(:str, "opal"))

      RUBY_ENGINE_CHECK_NOT = s(:send, s(:const, nil, :RUBY_ENGINE),
                              :!=, s(:str, "opal"))

      RUBY_PLATFORM_CHECK = s(:send, s(:const, nil, :RUBY_PLATFORM),
                              :==, s(:str, "opal"))

      RUBY_PLATFORM_CHECK_NOT = s(:send, s(:const, nil, :RUBY_PLATFORM),
                              :!=, s(:str, "opal"))

      def compile
        truthy, falsy = self.truthy, self.falsy

        if skip_check_present?
          falsy = nil
        end

        if skip_check_present_not?
          truthy = nil
        end

        push "if (", js_truthy(test), ") {"

        # skip if-body if no truthy sexp
        indent { line stmt(truthy) } if truthy

        if falsy
          if falsy.type == :if
            line "} else ", stmt(falsy)
          else
            indent do
              line "} else {"
              line stmt(falsy)
            end

            line "}"
          end
        else
          push "}"
        end

        wrap "(function() {", "; return nil; })()" if needs_wrapper?
      end

      # pre-processing only effects falsy blocks. If engine is
      # opal, then falsy block gets generated as normal. Unless
      # engine is opal then that code gets generated as the
      # falsy block
      def skip_check_present?
        test == RUBY_ENGINE_CHECK or test == RUBY_PLATFORM_CHECK
      end

      def skip_check_present_not?
        test == RUBY_ENGINE_CHECK_NOT or test == RUBY_PLATFORM_CHECK_NOT
      end

      def truthy
        needs_wrapper? ? compiler.returns(true_body || s(:nil)) : true_body
      end

      def falsy
        needs_wrapper? ? compiler.returns(false_body || s(:nil)) : false_body
      end

      def needs_wrapper?
        expr? or recv?
      end
    end

    class IFlipFlop < Base
      handle :iflipflop

      def compile
        # Unsupported
        # Always compiles to 'true' to not break generated JS
        push 'true'
      end
    end

    class EFlipFlop < Base
      handle :eflipflop

      def compile
        # Unsupported
        # Always compiles to 'true' to not break generated JS
        push 'true'
      end
    end
  end
end
