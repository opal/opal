require 'opal/rewriters/opal_engine_check'
require 'opal/rewriters/explicit_writer_return'
require 'opal/rewriters/js_reserved_words'
require 'opal/rewriters/block_to_iter'
require 'opal/rewriters/dot_js_syntax'

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
    end

    use Rewriters::OpalEngineCheck
    use Rewriters::BlockToIter
    use Rewriters::DotJsSyntax
    use Rewriters::ExplicitWriterReturn
    use Rewriters::JsReservedWords

    def initialize(sexp)
      @sexp = sexp
    end

    def process
      self.class.list.each do |rewriter_class|
        rewriter = rewriter_class.new
        @sexp = rewriter.process(@sexp)
      end

      @sexp
    end
  end
end
