require 'opal/rewriters/opal_engine_check'

module Opal
  class Rewriter
    LIST = [
      Rewriters::OpalEngineCheck
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
