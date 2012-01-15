module LangSendSpecs

  def self.fooM0; 100; end
  def self.fooM1(a); [a]; end
  def self.fooM2(a,b); [a,b]; end
  def self.fooM3(a,b,c); [a,b,c]; end
  def self.fooM4(a,b,c,d); [a,b,c,d]; end
  def self.fooM5(a,b,c,d,e); [a,b,c,d,e]; end
  def self.fooM0O1(a=1); [a]; end
  def self.fooM1O1(a,b=1); [a,b]; end
  def self.fooM2O1(a,b,c=1); [a,b,c]; end
  def self.fooM3O1(a,b,c,d=1); [a,b,c,d]; end
  def self.fooM4O1(a,b,c,d,e=1); [a,b,c,d,e]; end
  def self.fooM0O2(a=1,b=2); [a,b]; end
  def self.fooM0R(*r); r; end
  def self.fooM1R(a, *r); [a, r]; end
  def self.fooM0O1R(a=1, *r); [a, r]; end
  def self.fooM1O1R(a, b=1, *r); [a, b, r]; end

  def self.one(a); a; end
  def self.oneb(a,&b); [a,yield(b)]; end

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
