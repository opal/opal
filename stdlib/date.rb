class Date
  class << self
    alias civil new

    def wrap(native)
      instance = allocate
      `#{instance}.date = #{native}`
      instance
    end

    def parse(string)
      match = `/^(\d*)-(\d*)-(\d*)/.exec(string)`
      wrap `new Date(parseInt(match[1]), parseInt(match[2]) - 1, parseInt(match[3]))`
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
      if (date.$$is_number) {
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
      if (date.$$is_number) {
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
    %x{
      var result = #{clone}, date = result.date, cur = date.getDate();
      date.setDate(1);
      date.setMonth(date.getMonth() + 1);
      date.setDate(Math.min(cur, days_in_month(date.getFullYear(), date.getMonth())));
      return result;
    }
  end

  def prev
    res = self.clone
    `res.date.setDate(#@date.getDate() - 1)`
    res
  end

  def prev_month
    %x{
      var result = #{clone}, date = result.date, cur = date.getDate();
      date.setDate(1);
      date.setMonth(date.getMonth() - 1);
      date.setDate(Math.min(cur, days_in_month(date.getFullYear(), date.getMonth())));
      return result;
    }
  end

  def strftime(format = '')
    `#@date.$strftime(#{format})`
  end

  def to_s
    %x{
      var d = #@date, year = d.getFullYear(), month = d.getMonth() + 1, day = d.getDate();
      if (month < 10) { month = '0' + month; }
      if (day < 10) { day = '0' + day; }
      return year + '-' + month + '-' + day;
    }
  end

  def wday
    `#@date.getDay()`
  end

  def year
    `#@date.getFullYear()`
  end

  %x{
    function days_in_month(year, month) {
      var leap = ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0);
      return [31, (leap ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]
    }
  }
end
