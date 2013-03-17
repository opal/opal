native_date = `Date`

class Date
  def self.wrap(native)
    instance = allocate
    `#{instance}._date = #{native}`
    instance
  end

  def self.parse(string)
    wrap `native_date.parse(string)`
  end

  def self.today
    %x{
      var date = #{new};
      date._date = new native_date();
      return date;
    }
  end

  def initialize(year = undefined, month = undefined, day = undefined)
    `#{self}._date = new native_date(year, month - 1, day)`
  end

  def -(date)
    `Math.round((#{self}._date - #{date}._date) / (1000 * 60 * 60 * 24))`
  end

  def <(other)
    %x{
      var a = #{self}._date, b = #{other}._date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return a < b;
    }
  end

  def <=(other)
    %x{
      var a = #{self}._date, b = #{other}._date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return a <= b;
    }
  end

  def >(other)
    %x{
      var a = #{self}._date, b = #{other}._date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return a > b;
    }
  end

  def >=(other)
    %x{
      var a = #{self}._date, b = #{other}._date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return a >= b;
    }
  end

  def ==(other)
    %x{
      var a = #{self}._date, b = #{other}._date;
      a.setHours(0, 0, 0, 0);
      b.setHours(0, 0, 0, 0);
      return (a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate());
    }
  end

  def clone
    Date.wrap(`new native_date(#{self}._date.getTime())`)
  end

  def day
    `#{self}._date.getDate()`
  end

  def month
    `#{self}._date.getMonth() + 1`
  end

  def next
    res = self.clone
    `res._date.setDate(#{self}._date.getDate() + 1)`
    res
  end

  def next_month
    res = self.clone
    `res._date.add({months: 1})`
    res
  end

  def prev
    res = self.clone
    `res._date.setDate(#{self}._date.getDate() - 1)`
    res
  end

  def prev_month
    res = self.clone
    `res._date.add({months: -1})`
    res
  end

  def strftime(format = '')
    `#{self}._date.$strftme(#{format})`
  end

  def to_s
    %x{
      var date = #{self}._date;
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
    `#{self}._date.getDay()`
  end

  def year
    `#{self}._date.getFullYear()`
  end
end
