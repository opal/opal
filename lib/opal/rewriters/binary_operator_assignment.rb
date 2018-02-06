# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class BinaryOperatorAssignment < Base
      def self.reset_tmp_counter!
        @@counter = 0
      end

      def self.new_temp
        @@counter ||= 0
        @@counter += 1
        :"$binary_op_recvr_tmp_#{@@counter}"
      end

      GET_SET = ->(get_type, set_type) {
        ->(lhs, op, rhs) {
          get_node = lhs.updated(get_type) # lhs
          set_node = s(:send, get_node, op, rhs) # lhs + rhs

          lhs.updated(set_type, [*lhs, set_node]) # lhs = lhs + rhs
        }
      }

      # Takes    `lhs += rhs`
      # Produces `lhs = lhs + rhs`
      LocalVariableHandler = GET_SET[:lvar, :lvasgn]

      # Takes    `@lhs += rhs`
      # Produces `@lhs = @lhs + rhs`
      InstanceVariableHandler = GET_SET[:ivar, :ivasgn]

      # Takes    `LHS += rhs`
      # Produces `LHS = LHS + rhs`
      ConstantHandler = GET_SET[:const, :casgn]

      # Takes    `$lhs += rhs`
      # Produces `$lhs = $lhs + rhs`
      GlobalVariableHandler = GET_SET[:gvar, :gvasgn]

      # Takes    `@@lhs += rhs`
      # Produces `@@lhs = @@lhs + rhs`
      ClassVariableHandler = GET_SET[:cvar, :cvasgn]

      # Takes    `recvr.meth += rhs`
      # Produces `recvr.meth = recvr.meth + rhs`
      # (lhs is a recvr.meth, op is :+)
      class SendHandler < self
        def self.call(lhs, op, rhs)
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
          call_op = s(:send, call_reader, op, rhs) # $tmp.meth + rhs
          call_writer = lhs.updated(:send, [recvr, writer_method, *args, call_op]) # $tmp.meth = $tmp.meth + rhs

          if cache_recvr
            s(:begin, cache_recvr, call_writer)
          else
            call_writer
          end
        end
      end

      # Takes    `recvr.meth += rhs`
      # Produces `recvr.nil? ? nil : recvr.meth += rhs`
      #   NOTE: Later output of this handler gets post-processed by this rewriter again
      #   using SendHandler to `recvr.nil? ? nil : (recvr.meth = recvr.meth + rhs)`
      class ConditionalSendHandler < self
        def self.call(lhs, op, rhs)
          recvr, meth, *args = *lhs

          recvr_tmp = new_temp
          cache_recvr = s(:lvasgn, recvr_tmp, recvr)          # $tmp = recvr
          recvr = s(:js_tmp, recvr_tmp)

          recvr_is_nil = s(:send, recvr, :nil?)                 # recvr.nil?
          plain_send = lhs.updated(:send, [recvr, meth, *args]) # recvr.meth
          plain_op_asgn = s(:op_asgn, plain_send, op, rhs)      # recvr.meth += rhs

          s(:begin,
            cache_recvr,
            s(:if, recvr_is_nil,                          # if recvr.nil?
              s(:nil),                                    #   nil
                                                          # else
              plain_op_asgn))                             #   recvr.meth ||= rhs
                                                          # end
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
      }

      # lhs += rhs
      def on_op_asgn(node)
        lhs, op, rhs = *node

        result = HANDLERS
          .fetch(lhs.type) { raise NotImplementedError }
          .call(lhs, op, rhs)

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
        if inner.type == :op_asgn
          ASSIGNMENT_STRING_NODE
        else
          super(node)
        end
      end
    end
  end
end
