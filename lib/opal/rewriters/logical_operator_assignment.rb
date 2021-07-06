# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class LogicalOperatorAssignment < Base
      def self.reset_tmp_counter!
        @@counter = 0
      end

      def self.new_temp
        @@counter ||= 0
        @@counter += 1
        :"$logical_op_recvr_tmp_#{@@counter}"
      end

      GET_SET = ->(get_type, set_type) {
        ->(lhs, rhs, root_type) {
          get_node = lhs.updated(get_type)              # lhs
          condition_node = s(root_type, get_node, rhs)  # lhs || rhs

          if %i[const cvar].include?(get_type) && root_type == :or
            # defined?(lhs)
            defined_node = s(:defined?, get_node)
            # LHS = defined?(LHS) ? (LHS || rhs) : rhs
            condition_node = s(:if, defined_node, s(:begin, condition_node), rhs)
          end

          lhs.updated(set_type, [*lhs, condition_node]) # lhs = lhs || rhs
        }
      }

      # Takes    `lhs ||= rhs`
      # Produces `lhs = lhs || rhs`
      LocalVariableHandler = GET_SET[:lvar, :lvasgn]

      # Takes    `@lhs ||= rhs`
      # Produces `@lhs = @lhs || rhs`
      InstanceVariableHandler = GET_SET[:ivar, :ivasgn]

      # Takes    `LHS ||= rhs`
      # Produces `LHS = defined?(LHS) ? (LHS || rhs) : rhs`
      #
      # Takes    `LHS &&= rhs`
      # Produces `LHS = LHS && rhs`
      ConstantHandler = GET_SET[:const, :casgn]

      # Takes    `$lhs ||= rhs`
      # Produces `$lhs = $lhs || rhs`
      GlobalVariableHandler = GET_SET[:gvar, :gvasgn]

      # Takes    `@@lhs ||= rhs`
      # Produces `@@lhs = defined?(@@lhs) ? (@@lhs || rhs) : rhs`
      #
      # Takes    `@@lhs &&= rhs`
      # Produces `@@lhs = @@lhs && rhs`
      ClassVariableHandler = GET_SET[:cvar, :cvasgn]

      # Takes    `recvr.meth ||= rhs`
      # Produces `recvr.meth || recvr.meth = rhs`
      # (lhs is a recvr.meth)
      class SendHandler < self
        def self.call(lhs, rhs, root_type)
          recvr, reader_method, *args = *lhs

          # If recvr is a complex expression it must be cached.
          # MRI calls recvr in `recvr.meth ||= rhs` only once.
          if recvr && recvr.type == :send
            recvr_tmp = new_temp
            cache_recvr = s(:lvasgn, recvr_tmp, recvr)                         # $tmp = recvr
            recvr = s(:js_tmp, recvr_tmp)
          end

          writer_method = :"#{reader_method}="

          call_reader = lhs.updated(:send, [recvr, reader_method, *args])      # $tmp.meth
          call_writer = lhs.updated(:send, [recvr, writer_method, *args, rhs]) # $tmp.meth = rhs
          get_or_set = s(root_type, call_reader, call_writer)

          if cache_recvr
            s(:begin, cache_recvr, get_or_set)
          else
            get_or_set
          end
        end
      end

      # Takes    `recvr&.meth ||= rhs`
      # Produces `recvr.nil? ? nil : recvr.meth ||= rhs`
      #   NOTE: Later output of this handler gets post-processed by this rewriter again
      #   using SendHandler to `recvr.nil? ? nil : (recvr.meth || recvr.meth = rhs)`
      class ConditionalSendHandler < self
        def self.call(lhs, rhs, root_type)
          root_type = :"#{root_type}_asgn"

          recvr, meth, *args = *lhs

          recvr_tmp = new_temp
          cache_recvr = s(:lvasgn, recvr_tmp, recvr) # $tmp = recvr
          recvr = s(:js_tmp, recvr_tmp)

          recvr_is_nil = s(:send, recvr, :nil?)                 # recvr.nil?
          plain_send = lhs.updated(:send, [recvr, meth, *args]) # recvr.meth
          plain_or_asgn = s(root_type, plain_send, rhs)         # recvr.meth ||= rhs

          s(:begin,
            cache_recvr,
            s(:if, recvr_is_nil,                          # if recvr.nil?
              s(:nil),                                    #   nil
                                                          # else
              plain_or_asgn                               #   recvr.meth ||= rhs
            ),
          )                                               # end
        end
      end

      HANDLERS = {
        lvasgn: LocalVariableHandler,
        ivasgn: InstanceVariableHandler,
        casgn:  ConstantHandler,
        gvasgn: GlobalVariableHandler,
        cvasgn: ClassVariableHandler,
        send:   SendHandler,
        csend:  ConditionalSendHandler
      }.freeze

      # lhs ||= rhs
      def on_or_asgn(node)
        lhs, rhs = *node

        result = HANDLERS
                 .fetch(lhs.type) { error "cannot handle LHS type: #{lhs.type}" }
                 .call(lhs, rhs, :or)

        process(result)
      end

      # lhs &&= rhs
      def on_and_asgn(node)
        lhs, rhs = *node

        result = HANDLERS
                 .fetch(lhs.type) { error "cannot handle LHS type: #{lhs.type}" }
                 .call(lhs, rhs, :and)

        process(result)
      end

      ASSIGNMENT_STRING_NODE = s(:str, 'assignment')

      # Rewrites any or_asgn and and_asgn node like
      #   `defined?(a ||= 1)`
      # and
      #   `defined?(a &&= 1)`
      # to a static "assignment" string node
      def on_defined?(node)
        inner, _ = *node
        if %i[or_asgn and_asgn].include?(inner.type)
          ASSIGNMENT_STRING_NODE
        else
          super(node)
        end
      end
    end
  end
end
