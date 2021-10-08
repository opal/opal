# frozen_string_literal: false
require 'optparse'
require 'time'

OptionParser.accept(Time) do |s,|
  if s
    (begin
       Time.httpdate(s)
     rescue
       Time.parse(s)
     end)
  end
rescue
  raise OptionParser::InvalidArgument, s
end
