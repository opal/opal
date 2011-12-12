module LangSendSpecs

  def self.makeproc(&b) b end

  def self.yield_now; yield; end

  class ToProc
    def initialize(val)
      @val = val
    end

    def to_proc
      Proc.new { @val }
    end
  end
end
