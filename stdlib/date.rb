class Date
  class << self
    alias civil new

    def wrap(native)
      instance = allocate
      `#{instance}.date = #{native}`
      instance
    end

    def parse(string)
      wrap `Date.parse(string)`
    end

    def today
      wrap `new Date()`
    end
  end

  def initialize(year = undefined, month = undefined, day = undefined)
    @date = `new Date(year, month - 1, day)`
  end

  def -(date)
    %x{
      if (date._isNumber) {
        var result = #{clone};
        result.date.setDate(#@date.getDate() - date);
        return result;
      }
      else if (date.date) {
        return Math.round((#@date - #{date}.date) / (1000 * 60 * 60 * 24));
      }
      else {
        #{raise TypeError};
      }
    }
  end

  def +(date)
    %x{
      if (date._isNumber) {
        var result = #{clone};
        result.date.setDate(#@date.getDate() + date);
        return result;
      }
      else {
        #{raise TypeError};
      }
    }
  end

  def <(other)
    %x{
      var a = #@date, b = #{other}.date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return a < b;
    }
  end

  def <=(other)
    %x{
      var a = #@date, b = #{other}.date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return a <= b;
    }
  end

  def >(other)
    %x{
      var a = #@date, b = #{other}.date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return a > b;
    }
  end

  def >=(other)
    %x{
      var a = #@date, b = #{other}.date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return a >= b;
    }
  end

  def ==(other)
    %x{
      var a = #@date, b = other.date;
      return (a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate());
    }
  end

  alias eql? ==

  def clone
    Date.wrap(`new Date(#@date.getTime())`)
  end

  def day
    `#@date.getDate()`
  end

  def month
    `#@date.getMonth() + 1`
  end

  def next
    res = self.clone
    `res.date.setDate(#@date.getDate() + 1)`
    res
  end

  def next_month
    res = self.clone
    `res.date.add({months: 1})`
    res
  end

  def prev
    res = self.clone
    `res.date.setDate(#@date.getDate() - 1)`
    res
  end

  def prev_month
    res = self.clone
    `res.date.add({months: -1})`
    res
  end

  def strftime(format = '')
    `#@date.$strftime(#{format})`
  end

  def to_s
    %x{
      var date = #@date;
      return date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
    }
  end

  def to_json
    to_s.to_json
  end

  def as_json
    to_s
  end

  def wday
    `#@date.getDay()`
  end

  def year
    `#@date.getFullYear()`
  end
end
