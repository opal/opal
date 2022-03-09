require 'forwardable'
require 'date/infinity'
require 'time'

class Date
  include Comparable
  extend Forwardable

  JULIAN          = Infinity.new
  GREGORIAN       = -Infinity.new
  ITALY           = 2_299_161 # 1582-10-15
  ENGLAND         = 2_361_222 # 1752-09-14
  MONTHNAMES      = [nil] + %w[January February March April May June July August September October November December]
  ABBR_MONTHNAMES = %w[jan feb mar apr may jun jul aug sep oct nov dec]
  DAYNAMES        = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
  ABBR_DAYNAMES   = %w[Sun Mon Tue Wed Thu Fri Sat]

  class << self
    def wrap(native)
      instance = allocate
      `#{instance}.start = #{ITALY}`
      `#{instance}.date = #{native}`
      instance
    end

    def parse(string, comp = true)
      %x{
        var current_date = new Date();

        var current_day = current_date.getDate(),
            current_month = current_date.getMonth(),
            current_year = current_date.getFullYear(),
            current_wday = current_date.getDay(),
            full_month_name_regexp = #{MONTHNAMES.compact.join('|')};

        function match1(match) { return match[1]; }
        function match2(match) { return match[2]; }
        function match3(match) { return match[3]; }
        function match4(match) { return match[4]; }

        // Converts passed short year (0..99)
        // to a 4-digits year in the range (1969..2068)
        function fromShortYear(fn) {
          return function(match) {
            var short_year = fn(match);

            if (short_year >= 69) {
              short_year += 1900;
            } else {
              short_year += 2000;
            }
            return short_year;
          }
        }

        // Converts month abbr (nov) to a month number
        function fromMonthAbbr(fn) {
          return function(match) {
            var abbr = fn(match).toLowerCase();
            return #{ABBR_MONTHNAMES}.indexOf(abbr) + 1;
          }
        }

        function toInt(fn) {
          return function(match) {
            var value = fn(match);
            return parseInt(value, 10);
          }
        }

        // Depending on the 'comp' value appends 20xx to a passed year
        function to2000(fn) {
          return function(match) {
            var value = fn(match);
            if (comp) {
              return value + 2000;
            } else {
              return value;
            }
          }
        }

        // Converts passed week day name to a day number
        function fromDayName(fn) {
          return function(match) {
            var dayname = fn(match),
                wday = #{DAYNAMES.map(&:downcase)}.indexOf(#{`dayname`.downcase});

            return current_day - current_wday + wday;
          }
        }

        // Converts passed month name to a month number
        function fromFullMonthName(fn) {
          return function(match) {
            var month_name = fn(match);
            return #{MONTHNAMES.compact.map(&:downcase)}.indexOf(#{`month_name`.downcase}) + 1;
          }
        }

        var rules = [
          {
            // DD as month day number
            regexp: /^(\d{2})$/,
            year: current_year,
            month: current_month,
            day: toInt(match1)
          },
          {
            // DDD as year day number
            regexp: /^(\d{3})$/,
            year: current_year,
            month: 0,
            day: toInt(match1)
          },
          {
            // MMDD as month and day
            regexp: /^(\d{2})(\d{2})$/,
            year: current_year,
            month: toInt(match1),
            day: toInt(match2)
          },
          {
            // YYDDD as year and day number in 1969--2068
            regexp: /^(\d{2})(\d{3})$/,
            year: fromShortYear(toInt(match1)),
            month: 0,
            day: toInt(match2)
          },
          {
            // YYMMDD as year, month and day in 1969--2068
            regexp: /^(\d{2})(\d{2})(\d{2})$/,
            year: fromShortYear(toInt(match1)),
            month: toInt(match2),
            day: toInt(match3)
          },
          {
            // YYYYDDD as year and day number
            regexp: /^(\d{4})(\d{3})$/,
            year: toInt(match1),
            month: 0,
            day: toInt(match2)
          },
          {
            // YYYYMMDD as year, month and day number
            regexp: /^(\d{4})(\d{2})(\d{2})$/,
            year: toInt(match1),
            month: toInt(match2),
            day: toInt(match3)
          },
          {
            // mmm YYYY
            regexp: /^([a-z]{3})[\s\.\/\-](\d{3,4})$/,
            year: toInt(match2),
            month: fromMonthAbbr(match1),
            day: 1
          },
          {
            // DD mmm YYYY
            regexp: /^(\d{1,2})[\s\.\/\-]([a-z]{3})[\s\.\/\-](\d{3,4})$/i,
            year: toInt(match3),
            month: fromMonthAbbr(match2),
            day: toInt(match1)
          },
          {
            // mmm DD YYYY
            regexp: /^([a-z]{3})[\s\.\/\-](\d{1,2})[\s\.\/\-](\d{3,4})$/i,
            year: toInt(match3),
            month: fromMonthAbbr(match1),
            day: toInt(match2)
          },
          {
            // YYYY mmm DD
            regexp: /^(\d{3,4})[\s\.\/\-]([a-z]{3})[\s\.\/\-](\d{1,2})$/i,
            year: toInt(match1),
            month: fromMonthAbbr(match2),
            day: toInt(match3)
          },
          {
            // YYYY-MM-DD YYYY/MM/DD YYYY.MM.DD
            regexp: /^(\-?\d{3,4})[\s\.\/\-](\d{1,2})[\s\.\/\-](\d{1,2})$/,
            year: toInt(match1),
            month: toInt(match2),
            day: toInt(match3)
          },
          {
            // YY-MM-DD
            regexp: /^(\d{2})[\s\.\/\-](\d{1,2})[\s\.\/\-](\d{1,2})$/,
            year: to2000(toInt(match1)),
            month: toInt(match2),
            day: toInt(match3)
          },
          {
            // DD-MM-YYYY
            regexp: /^(\d{1,2})[\s\.\/\-](\d{1,2})[\s\.\/\-](\-?\d{3,4})$/,
            year: toInt(match3),
            month: toInt(match2),
            day: toInt(match1)
          },
          {
            // ddd
            regexp: new RegExp("^(" + #{DAYNAMES.join('|')} + ")$", 'i'),
            year: current_year,
            month: current_month,
            day: fromDayName(match1)
          },
          {
            // monthname daynumber YYYY
            regexp: new RegExp("^(" + full_month_name_regexp + ")[\\s\\.\\/\\-](\\d{1,2})(th|nd|rd)[\\s\\.\\/\\-](\\-?\\d{3,4})$", "i"),
            year: toInt(match4),
            month: fromFullMonthName(match1),
            day: toInt(match2)
          },
          {
            // monthname daynumber
            regexp: new RegExp("^(" + full_month_name_regexp + ")[\\s\\.\\/\\-](\\d{1,2})(th|nd|rd)", "i"),
            year: current_year,
            month: fromFullMonthName(match1),
            day: toInt(match2)
          },
          {
            // daynumber monthname YYYY
            regexp: new RegExp("^(\\d{1,2})(th|nd|rd)[\\s\\.\\/\\-](" + full_month_name_regexp + ")[\\s\\.\\/\\-](\\-?\\d{3,4})$", "i"),
            year: toInt(match4),
            month: fromFullMonthName(match3),
            day: toInt(match1)
          },
          {
            // YYYY monthname daynumber
            regexp: new RegExp("^(\\-?\\d{3,4})[\\s\\.\\/\\-](" + full_month_name_regexp + ")[\\s\\.\\/\\-](\\d{1,2})(th|nd|rd)$", "i"),
            year: toInt(match1),
            month: fromFullMonthName(match2),
            day: toInt(match3)
          }
        ]

        var rule, i, match;

        for (i = 0; i < rules.length; i++) {
          rule = rules[i];
          match = rule.regexp.exec(string);
          if (match) {
            var year = rule.year;
            if (typeof(year) === 'function') {
              year = year(match);
            }

            var month = rule.month;
            if (typeof(month) === 'function') {
              month = month(match) - 1
            }

            var day = rule.day;
            if (typeof(day) === 'function') {
              day = day(match);
            }

            var result = new Date(year, month, day);

            // an edge case, JS can't handle 'new Date(1)', minimal year is 1970
            if (year >= 0 && year <= 1970) {
              result.setFullYear(year);
            }

            return #{wrap `result`};
          }
        }
      }
      raise ArgumentError, 'invalid date'
    end

    def today
      wrap `new Date()`
    end

    def gregorian_leap?(year)
      `(new Date(#{year}, 1, 29).getMonth()-1) === 0`
    end

    alias civil new
  end

  def initialize(year = -4712, month = 1, day = 1, start = ITALY)
    %x{
      // Because of Gregorian reform calendar goes from 1582-10-04 to 1582-10-15.
      // All days in between end up as 4 october.
      if (year === 1582 && month === 10 && day > 4 && day < 15) {
        day = 4;
      }
    }

    @date = `new Date(year, month - 1, day)`
    @start = start
  end

  attr_reader :start

  def <=>(other)
    %x{
      if (other.$$is_number) {
        return #{jd <=> other}
      }

      if (#{::Date === other}) {
        var a = #{@date}, b = #{other}.date;
        if (!Opal.is_a(#{self}, #{::DateTime})) a.setHours(0, 0, 0, 0);
        if (!Opal.is_a(#{other}, #{::DateTime})) b.setHours(0, 0, 0, 0);

        if (a < b) {
          return -1;
        }
        else if (a > b) {
          return 1;
        }
        else {
          return 0;
        }
      } else {
        return nil;
      }
    }
  end

  def >>(n)
    `if (!n.$$is_number) #{raise ::TypeError}`

    self << -n
  end

  def <<(n)
    `if (!n.$$is_number) #{raise ::TypeError}`

    prev_month(n)
  end

  def clone
    date = Date.wrap(@date.dup)
    `date.start = #{@start}`
    date
  end

  def_delegators :@date, :sunday?, :monday?, :tuesday?, :wednesday?, :thursday?, :friday?, :saturday?,
    :day, :month, :year, :wday, :yday

  alias mday day
  alias mon month

  def jd
    %x{
    //Adapted from http://www.physics.sfasu.edu/astro/javascript/julianday.html

    var mm = #{@date}.getMonth() + 1,
        dd = #{@date}.getDate(),
        yy = #{@date}.getFullYear(),
        hr = 12, mn = 0, sc = 0,
        ggg, s, a, j1, jd;

    hr = hr + (mn / 60) + (sc/3600);

    ggg = 1;
    if (yy <= 1585) {
      ggg = 0;
    }

    jd = -1 * Math.floor(7 * (Math.floor((mm + 9) / 12) + yy) / 4);

    s = 1;
    if ((mm - 9) < 0) {
      s =- 1;
    }

    a = Math.abs(mm - 9);
    j1 = Math.floor(yy + s * Math.floor(a / 7));
    j1 = -1 * Math.floor((Math.floor(j1 / 100) + 1) * 3 / 4);

    jd = jd + Math.floor(275 * mm / 9) + dd + (ggg * j1);
    jd = jd + 1721027 + 2 * ggg + 367 * yy - 0.5;
    jd = jd + (hr / 24);

    return jd;
    }
  end

  def julian?
    `#{@date} < new Date(1582, 10 - 1, 15, 12)`
  end

  def new_start(start)
    new_date = clone
    `new_date.start = start`
    new_date
  end

  def next
    self + 1
  end

  def -(date)
    %x{
      if (date.date) {
        return Math.round((#{@date} - #{date}.date) / (1000 * 60 * 60 * 24));
      }
    }
    prev_day(date)
  end

  def +(date)
    next_day(date)
  end

  def prev_day(n = 1)
    %x{
      if (n.$$is_number) {
        var result = #{clone};
        result.date.setDate(#{@date}.getDate() - n);
        return result;
      }
      else {
        #{raise ::TypeError};
      }
    }
  end

  def next_day(n = 1)
    `if (!n.$$is_number) #{raise ::TypeError}`
    prev_day(-n)
  end

  def prev_month(n = 1)
    %x{
      if (!n.$$is_number) #{raise ::TypeError}
      var result = #{clone}, date = result.date, cur = date.getDate();
      date.setDate(1);
      date.setMonth(date.getMonth() - n);
      date.setDate(Math.min(cur, #{Date._days_in_month(`date.getFullYear()`, `date.getMonth()`)}));
      return result;
    }
  end

  def next_month(n = 1)
    `if (!n.$$is_number) #{raise ::TypeError}`
    prev_month(-n)
  end

  def prev_year(years = 1)
    `if (!years.$$is_number) #{raise ::TypeError}`
    self.class.new(year - years, month, day)
  end

  def next_year(years = 1)
    `if (!years.$$is_number) #{raise ::TypeError}`
    prev_year(-years)
  end

  def strftime(format = '')
    %x{
      if (format == '') {
        return #{to_s};
      }

      return #{@date.strftime(format)}
    }
  end

  def to_s
    %x{
      var d = #{@date}, year = d.getFullYear(), month = d.getMonth() + 1, day = d.getDate();
      if (month < 10) { month = '0' + month; }
      if (day < 10) { day = '0' + day; }
      return year + '-' + month + '-' + day;
    }
  end

  def to_time
    Time.new(year, month, day)
  end

  def to_date
    self
  end

  def to_datetime
    DateTime.new(year, month, day)
  end

  def to_n
    @date
  end

  def step(limit, step = 1, &block)
    steps_count = (limit - self).to_i

    steps = if steps_count * step < 0
              []
            elsif steps_count < 0
              (0..-steps_count).step(step.abs).map(&:-@).reverse
            else
              (0..steps_count).step(step.abs)
            end

    result = steps.map { |i| self + i }


    if block_given?
      result.each { |i| yield(i) }
      self
    else
      result
    end
  end

  def upto(max, &block)
    step(max, 1, &block)
  end

  def downto(min, &block)
    step(min, -1, &block)
  end

  def cwday
    `#{@date}.getDay() || 7`
  end

  def cweek
    %x{
      var d = new Date(#{@date});
      d.setHours(0,0,0);
      d.setDate(d.getDate()+4-(d.getDay()||7));
      return Math.ceil((((d-new Date(d.getFullYear(),0,1))/8.64e7)+1)/7);
    }
  end

  def self._days_in_month(year, month)
    %x{
      var leap = ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0);
      return [31, (leap ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
    }
  end

  alias eql? ==
  alias succ next
end

require 'date/date_time'
require 'date/formatters'
