class Logger
  module Severity
    DEBUG = 0
    INFO = 1
    WARN = 2
    ERROR = 3
    FATAL = 4
    UNKNOWN = 5
  end
  include Severity

  SEVERITY_LABELS = Severity.constants.map { |s| [(Severity.const_get s), s.to_s] }.to_h

  class Formatter
    MESSAGE_FORMAT = "%s, [%s] %5s -- %s: %s\n"
    DATE_TIME_FORMAT = '%Y-%m-%dT%H:%M:%S.%6N'

    def call(severity, time, progname, msg)
      format(MESSAGE_FORMAT, severity.chr, time.strftime(DATE_TIME_FORMAT), severity, progname, message_as_string(msg))
    end

    def message_as_string(msg)
      case msg
      when ::String
        msg
      when ::Exception
        "#{msg.message} (#{msg.class})\n" + (msg.backtrace || []).join("\n")
      else
        msg.inspect
      end
    end
  end

  attr_reader :level
  attr_accessor :progname
  attr_accessor :formatter

  def initialize(pipe)
    @pipe = pipe
    @level = DEBUG
    @formatter = Formatter.new
  end

  def level=(severity)
    if ::Integer === severity
      @level = severity
    elsif (level = SEVERITY_LABELS.key(severity.to_s.upcase))
      @level = level
    else
      raise ArgumentError, "invalid log level: #{severity}"
    end
  end

  def info(progname = nil, &block)
    add INFO, nil, progname, &block
  end

  def debug(progname = nil, &block)
    add DEBUG, nil, progname, &block
  end

  def warn(progname = nil, &block)
    add WARN, nil, progname, &block
  end

  def error(progname = nil, &block)
    add ERROR, nil, progname, &block
  end

  def fatal(progname = nil, &block)
    add FATAL, nil, progname, &block
  end

  def unknown(progname = nil, &block)
    add UNKNOWN, nil, progname, &block
  end

  def info?
    @level <= INFO
  end

  def debug?
    @level <= DEBUG
  end

  def warn?
    @level <= WARN
  end

  def error?
    @level <= ERROR
  end

  def fatal?
    @level <= FATAL
  end

  def add(severity, message = nil, progname = nil, &block)
    return true if (severity ||= UNKNOWN) < @level
    progname ||= @progname
    unless message
      if block_given?
        message = yield
      else
        message = progname
        progname = @progname
      end
    end
    @pipe.write(@formatter.call(SEVERITY_LABELS[severity] || 'ANY', ::Time.now, progname, message))
    true
  end
end
