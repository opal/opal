module LangSendSpecs

  def self.fooM0; 100; end
  def self.fooM1(a); [a]; end

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
