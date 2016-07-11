require 'opal/rewriters/opal_engine_check'
require 'opal/rewriters/explicit_writer_return'

module Opal
  class Rewriter
    LIST = [
      Rewriters::OpalEngineCheck,
      Rewriters::ExplicitWriterReturn,
    ]

    def initialize(sexp)
      @sexp = sexp
    end

    def process
      LIST.each do |rewriter_class|
        rewriter = rewriter_class.new
        @sexp = rewriter.process(@sexp)
      end

      @sexp
    end
  end
end
