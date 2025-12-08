# backtick_javascript: true
# helpers: coerce_to, str
require 'benchmark/ips'

s = "𝌆a𝌆"
short_string = "𝌆"
medi_string = s * 10

pri = `medi_string.valueOf()`
obj = `new String(medi_string)`

class String
  def add_before(other)
    other = `$coerce_to(#{other}, Opal.String, 'to_str')`
    %x{
      if (other.length === 0 && self.$$class === Opal.String) return self;
      if (self.length === 0 && other.$$class === Opal.String) return other;
      return $str(self + other, self.encoding);
    }
  end

  def add_vo(other)
    other = `$coerce_to(#{other}, Opal.String, 'to_str')`
    %x{
      if (other.length === 0 && self.$$class === Opal.String) return self;
      if (self.length === 0 && other.$$class === Opal.String) return other;
      return $str(self.valueOf() + other.valueOf(), self.encoding);
    }
  end

  def add_tvo(other)
    other = `$coerce_to(#{other}, Opal.String, 'to_str')`
    %x{
      if (other.length === 0 && self.$$class === Opal.String) return self;
      if (self.length === 0 && other.$$class === Opal.String) return other;
      return $str((typeof self === "string" ? self : self.valueOf()) + (typeof other === "string" ? other : other.valueOf()), self.encoding);
    }
  end
end

# The loop is silly, but its purpose is, to make it harder for v8 to optimize
# in the mixed cases. To be fair for all cases, the silly loop is there in all cases.

Benchmark.ips do |x|

  x.report("native, string pri") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          return pri + pri;
        } else {
          return pri + pri;
        }
      }
    end
  end

  x.report("native, string obj") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          return obj + obj;
        } else {
          return obj + obj;
        }
      }
    end
  end

  x.report("native, str pri.vO") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          return pri.valueOf() + pri.valueOf();
        } else {
          return pri.valueOf() + pri.valueOf();
        }
      }
    end
  end

  x.report("native, str obj.vO") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          return obj.valueOf() + obj.valueOf();
        } else {
          return obj.valueOf() + obj.valueOf();
        }
      }
    end
  end

  x.report("native, string mix") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          return pri + obj;
        } else {
          return obj + pri;
        }
      }
    end
  end

  x.report("string primitive") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_before(pri)}
        } else {
          #{pri.add_before(pri)}
        }
      }
    end
  end

  x.report("string object") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{obj.add_before(obj)}
        } else {
          #{obj.add_before(obj)}
        }
      }
    end
  end

  x.report("string mixed arg") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_before(pri)}
        } else {
          #{pri.add_before(obj)}
        }
      }
    end
  end

  # This time also changing the receiver
  x.report("string mixed rec") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_before(pri)}
        } else {
          #{obj.add_before(pri)}
        }
      }
    end
  end

  # This time also changing the receiver and arg
  x.report("string mixed r+a") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_before(obj)}
        } else {
          #{obj.add_before(pri)}
        }
      }
    end
  end


  # add with valueOf

  x.report("string pri vo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_vo(pri)}
        } else {
          #{pri.add_vo(pri)}
        }
      }
    end
  end

  x.report("string obj vo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{obj.add_vo(obj)}
        } else {
          #{obj.add_vo(obj)}
        }
      }
    end
  end

  x.report("string mix a vo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_vo(pri)}
        } else {
          #{pri.add_vo(obj)}
        }
      }
    end
  end

  x.report("string mix r vo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_vo(pri)}
        } else {
          #{obj.add_vo(pri)}
        }
      }
    end
  end

  x.report("string mix ra vo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_vo(obj)}
        } else {
          #{obj.add_vo(pri)}
        }
      }
    end
  end

  # add type checked valueOf

  x.report("string pri tvo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_tvo(pri)}
        } else {
          #{pri.add_tvo(pri)}
        }
      }
    end
  end

  x.report("string obj tvo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{obj.add_tvo(obj)}
        } else {
          #{obj.add_tvo(obj)}
        }
      }
    end
  end

  x.report("string mix a tvo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_tvo(pri)}
        } else {
          #{pri.add_tvo(obj)}
        }
      }
    end
  end

  x.report("string mix r tvo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_tvo(pri)}
        } else {
          #{obj.add_tvo(pri)}
        }
      }
    end
  end

  x.report("string mix ra tvo") do
    1..1000.times do |i|
      %x{
        if (i % 2 === 0) {
          #{pri.add_tvo(obj)}
        } else {
          #{obj.add_tvo(pri)}
        }
      }
    end
  end

  x.compare!
end
