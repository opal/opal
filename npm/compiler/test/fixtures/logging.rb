require 'logger'

module Asciidoctor
class NullLogger < ::Logger
  attr_reader :max_severity

  def initialize; end

  def add severity, message = nil, progname = nil
    if (severity ||= UNKNOWN) > (@max_severity ||= severity)
      @max_severity = severity
    end
    true
  end
end
end
