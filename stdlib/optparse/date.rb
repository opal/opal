# frozen_string_literal: false
require 'optparse'
require 'date'

OptionParser.accept(DateTime) do |s,|
  DateTime.parse(s) if s
rescue ArgumentError
  raise OptionParser::InvalidArgument, s
end
OptionParser.accept(Date) do |s,|
  Date.parse(s) if s
rescue ArgumentError
  raise OptionParser::InvalidArgument, s
end
