date_constructor = `Date`

class Date
  def self.today
    %x{
      var date = #{new};
      date._date = new date_constructor();
      return date;
    }
  end

  def initialize(year, month, day)
    `#{self}._date = new date_constructor(year, month - 1, day)`
  end

  def day
    `#{self}._date.getDate()`
  end

  def month
    `#{self}._date.getMonth() + 1`
  end

  def to_s
    %x{
      var d = #{self}._date;
      return '' + d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
    }
  end

  def year
    `#{self}._date.getFullYear()`
  end
end
