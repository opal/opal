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

  def >>(n)
    %x{
      if (!n.$$is_number) {
        #{raise TypeError};
      }

      var result = #{clone}, date = result.date, cur = date.getDate();
      date.setDate(1);
      date.setMonth(date.getMonth() + n);
      date.setDate(Math.min(cur, days_in_month(date.getFullYear(), date.getMonth())));
      return result;
    }
  end

  def <<(n)
    %x{
      if (!n.$$is_number) {
        #{raise TypeError};
      }

      return #{self >> `-n`};
    }
  end

  alias eql? ==

  def clone
    Date.wrap(`new Date(#@date.getTime())`)
  end

  def day
    `#@date.getDate()`
  end

  def friday?
    wday == 5
  end

  def monday?
    wday == 1
  end

  def month
    `#@date.getMonth() + 1`
  end

  def next
    self + 1
  end

  def next_day(n=1)
    self + n
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

  def prev_day(n=1)
    self - n
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

  def saturday?
    wday == 6
  end

  def strftime(format = '')
    %x{
      if (format == '') {
        return #{to_s};
      }

      return #@date.$strftime(#{format});
    }
  end

  alias_method :succ, :next

  def sunday?
    wday == 0
  end

  def thursday?
    wday == 4
  end

  def to_s
    %x{
      var d = #@date, year = d.getFullYear(), month = d.getMonth() + 1, day = d.getDate();
      if (month < 10) { month = '0' + month; }
      if (day < 10) { day = '0' + day; }
      return year + '-' + month + '-' + day;
    }
  end

  def tuesday?
    wday == 2
  end

  def wday
    `#@date.getDay()`
  end

  def wednesday?
    wday == 3
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
