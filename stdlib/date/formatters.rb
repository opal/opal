class Date
  def self.def_formatter(*args, **kwargs)
    Time.def_formatter(*args, **kwargs, on: self)
  end

  def_formatter :asctime, '%c'
  alias ctime asctime
  def_formatter :iso8601, '%F'
  alias xmlschema iso8601
  def_formatter :rfc3339, '%FT%T%:z'
  def_formatter :rfc2822, '%a, %-d %b %Y %T %z'
  alias rfc822 rfc2822
  def_formatter :httpdate, '%a, %d %b %Y %T GMT', utc: true
  def_formatter :jisx0301, '%J'

  alias to_s iso8601
end

class DateTime < Date
  def_formatter :xmlschema, '%FT%T', fractions: true, tz_format: '%:z'
  alias iso8601 xmlschema
  alias rfc3339 xmlschema
  def_formatter :jisx0301, '%JT%T', fractions: true, tz_format: '%:z'

  alias to_s xmlschema

  def_formatter :zone, '%:z'
end
