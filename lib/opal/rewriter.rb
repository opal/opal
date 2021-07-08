# frozen_string_literal: true

require 'opal/rewriters/opal_engine_check'
require 'opal/rewriters/for_rewriter'
require 'opal/rewriters/explicit_writer_return'
require 'opal/rewriters/js_reserved_words'
require 'opal/rewriters/block_to_iter'
require 'opal/rewriters/dot_js_syntax'
require 'opal/rewriters/logical_operator_assignment'
require 'opal/rewriters/binary_operator_assignment'
require 'opal/rewriters/hashes/key_duplicates_rewriter'
require 'opal/rewriters/dump_args'
require 'opal/rewriters/mlhs_args'
require 'opal/rewriters/inline_args'
require 'opal/rewriters/numblocks'
require 'opal/rewriters/returnable_logic'
require 'opal/rewriters/forward_args'

module Opal
  class Rewriter
    class << self
      def list
        @list ||= []
      end

      def use(rewriter)
        list << rewriter
      end

      def delete(rewriter)
        list.delete(rewriter)
      end

      def disable
        @disabled = true
        yield
      ensure
        @disabled = false
      end

      def disabled?
        @disabled if defined?(@disabled)
      end
    end

    use Rewriters::LogicalOperatorAssignment
    use Rewriters::BinaryOperatorAssignment
    use Rewriters::ReturnableLogic
    use Rewriters::OpalEngineCheck
    use Rewriters::ForRewriter
    use Rewriters::Numblocks
    use Rewriters::ForwardArgs
    use Rewriters::BlockToIter
    use Rewriters::DotJsSyntax
    use Rewriters::JsReservedWords
    use Rewriters::ExplicitWriterReturn
    use Rewriters::Hashes::KeyDuplicatesRewriter
    use Rewriters::DumpArgs
    use Rewriters::MlhsArgs
    use Rewriters::InlineArgs

    def initialize(sexp)
      @sexp = sexp
    end

    def process
      return @sexp if self.class.disabled?

      self.class.list.each do |rewriter_class|
        rewriter = rewriter_class.new
        @sexp = rewriter.process(@sexp)
      end

      @sexp
    end
  end
end
