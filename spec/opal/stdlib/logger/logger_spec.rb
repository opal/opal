require 'logger'
require 'stringio'

# Our implementation of Logger only supports StringIO pipes.
# Since we can't portably write a log file, nothing in rubyspec will run.
describe Logger do
  before do
    @pipe = StringIO.new
    @logger = Logger.new @pipe
  end

  describe "level" do
    it "should set the level to DEBUG by default" do
      @logger.level.should == Logger::Severity::DEBUG
    end

    it "should allow the level to be changed using an integer of a known level" do
      @logger.level = Logger::Severity::INFO
      @logger.level.should == Logger::Severity::INFO
    end

    it "should allow the level to be changed to an arbitrary integer value" do
      @logger.level = 1000
      @logger.level.should == 1000
    end

    it "should allow the level to be set using a case-insensitive level name" do
      @logger.level = 'WaRn'
      @logger.level.should == Logger::Severity::WARN
    end

    it "should raise an ArgumentError if the level is set to an unknown name" do
      lambda { @logger.level = 'foobar' }.should raise_error(ArgumentError)
    end

    it "should report when debug level is enabled" do
      @logger.debug?.should == true
    end

    it "should report when debug level is not enabled" do
      @logger.level = Logger::Severity::DEBUG + 1
      @logger.debug?.should == false
    end

    it "should report when info level is enabled" do
      @logger.level = Logger::Severity::INFO
      @logger.info?.should == true
    end

    it "should report when debug level is not enabled" do
      @logger.level = Logger::Severity::INFO + 1
      @logger.info?.should == false
    end

    it "should report when warn level is enabled" do
      @logger.level = Logger::Severity::WARN
      @logger.warn?.should == true
    end

    it "should report when warn level is not enabled" do
      @logger.level = Logger::Severity::WARN + 1
      @logger.warn?.should == false
    end

    it "should report when error level is enabled" do
      @logger.level = Logger::Severity::ERROR
      @logger.error?.should == true
    end

    it "should report when error level is not enabled" do
      @logger.level = Logger::Severity::ERROR + 1
      @logger.error?.should == false
    end

    it "should report when fatal level is enabled" do
      @logger.level = Logger::Severity::FATAL
      @logger.fatal?.should == true
    end

    it "should report when fatal level is not enabled" do
      @logger.level = Logger::Severity::FATAL + 1
      @logger.fatal?.should == false
    end
  end

  describe "add" do
    it "should not add a message to the log output if level is not enabled" do
      @logger.level = Logger::Severity::INFO
      @logger.add(Logger::Severity::DEBUG, 'message').should == true
      @pipe.string.should == ''
    end

    it "should add a message to the log output if level is enabled" do
      @logger.add(Logger::Severity::DEBUG, 'message').should == true
      @pipe.string.should_not == ''
    end

    it "should coerce severity to UNKNOWN if falsy" do
      @logger.level = Logger::Severity::UNKNOWN
      @logger.add(nil, 'message').should == true
      @pipe.string.should_not == ''
    end

    it "should format message using default formatter" do
      @logger.add(Logger::Severity::DEBUG, 'message', 'program').should == true
      @pipe.string.should =~ /^D, \[.+?\] +DEBUG -- program: message\n/
    end

    it "should log debug message if debug level is enabled" do
      @logger.debug('message').should == true
      @pipe.string.should =~ /^D, .*: message\n/
    end

    it "should not log debug message if debug level is not enabled" do
      @logger.level = Logger::Severity::DEBUG + 1
      @logger.debug('message').should == true
      @pipe.string.should == ''
    end

    it "should log info message if info level is enabled" do
      @logger.level = Logger::Severity::INFO
      @logger.info('message').should == true
      @pipe.string.should =~ /^I, .*: message\n/
    end

    it "should not log info message if info level is not enabled" do
      @logger.level = Logger::Severity::INFO + 1
      @logger.info('message').should == true
      @pipe.string.should == ''
    end

    it "should log error message if info level is enabled" do
      @logger.level = Logger::Severity::ERROR
      @logger.error('message').should == true
      @pipe.string.should =~ /^E, .*: message\n/
    end

    it "should not log error message if error level is not enabled" do
      @logger.level = Logger::Severity::ERROR + 1
      @logger.error('message').should == true
      @pipe.string.should == ''
    end

    it "should log fatal message if fatal level is enabled" do
      @logger.level = Logger::Severity::FATAL
      @logger.fatal('message').should == true
      @pipe.string.should =~ /^F, .*: message\n/
    end

    it "should not log fatal message if fatal level is not enabled" do
      @logger.level = Logger::Severity::FATAL + 1
      @logger.fatal('message').should == true
      @pipe.string.should == ''
    end

    it "should log unknown message if unknown level is enabled" do
      @logger.level = Logger::Severity::UNKNOWN
      @logger.unknown('message').should == true
      @pipe.string.should =~ /^U, .*: message\n/
    end

    it "should not log unknown message if unknown level is not enabled" do
      @logger.level = Logger::Severity::UNKNOWN + 1
      @logger.unknown('message').should == true
      @pipe.string.should == ''
    end

    it "should use level name ANY in message if level is not known" do
      @logger.add(1000, 'message', 'program').should == true
      @pipe.string.should =~ /^A, \[.+?\] +ANY -- program: message\n/
    end

    it "should use message from block passed to add if block is given" do
      @logger.add(Logger::Severity::DEBUG, nil, 'program') { 'message' }.should == true
      @pipe.string.should include(' -- program: message')
    end

    it "should only require severity argument when calling add" do
      @logger.add(Logger::Severity::DEBUG).should == true
      @pipe.string.should include('DEBUG -- : nil')
    end

    it "should not require any arguments when calling level method" do
      @logger.debug.should == true
      @pipe.string.should include('DEBUG -- : nil')
    end
  end

  describe "progname" do
    it "should set progname to nil by default" do
      @logger.progname.should be_nil
    end

    it "should leave progname blank in message by default" do
      @logger.add(Logger::Severity::DEBUG, 'message').should == true
      @pipe.string.should include(' DEBUG -- : message')
    end

    it "should allow the progname to be set" do
      @logger.progname = 'program'
      @logger.progname.should == 'program'
    end

    it "should use the progname from the logger in the message" do
      @logger.progname = 'program'
      @logger.add(Logger::Severity::DEBUG, 'message').should == true
      @pipe.string.should include(' DEBUG -- program: message')
    end

    it "should allow the progname to be overridden when using add to log a message" do
      @logger.progname = 'program'
      @logger.add(Logger::Severity::DEBUG, 'message', 'app').should == true
      @pipe.string.should include(' DEBUG -- app: message')
    end

    it "should allow the progname to be overridden when using block form of debug method" do
      @logger.progname = 'program'
      @logger.debug('app') { 'message' }.should == true
      @pipe.string.should include(' DEBUG -- app: message')
    end

    it "should allow the progname to be overridden when using block form of info method" do
      @logger.level = Logger::Severity::INFO
      @logger.progname = 'program'
      @logger.info('app') { 'message' }.should == true
      @pipe.string.should include(' INFO -- app: message')
    end

    it "should allow the progname to be overridden when using block form of warn method" do
      @logger.level = Logger::Severity::WARN
      @logger.progname = 'program'
      @logger.warn('app') { 'message' }.should == true
      @pipe.string.should include(' WARN -- app: message')
    end

    it "should allow the progname to be overridden when using block form of error method" do
      @logger.level = Logger::Severity::ERROR
      @logger.progname = 'program'
      @logger.error('app') { 'message' }.should == true
      @pipe.string.should include(' ERROR -- app: message')
    end

    it "should allow the progname to be overridden when using block form of fatal method" do
      @logger.level = Logger::Severity::FATAL
      @logger.progname = 'program'
      @logger.fatal('app') { 'message' }.should == true
      @pipe.string.should include(' FATAL -- app: message')
    end

    it "should allow the progname to be overridden when using block form of unknown method" do
      @logger.level = Logger::Severity::UNKNOWN
      @logger.progname = 'program'
      @logger.unknown('app') { 'message' }.should == true
      @pipe.string.should include(' UNKNOWN -- app: message')
    end
  end

  describe "formatter" do
    it "should use the default formatter by default" do
      @logger.formatter.should_not be_nil
      @logger.formatter.should be_kind_of(Logger::Formatter)
    end

    it "should allow the formatter to be changed" do
      MyFormatter = Class.new
      @logger.formatter = MyFormatter.new
      @logger.formatter.should be_kind_of(MyFormatter)
    end

    it "should invoke call method on the custom formatter to log a message" do
      @logger.progname = 'app'
      @logger.formatter = proc { |severity, time, progname, msg|
        "#{severity} - #{time.to_i} - #{progname} - #{msg}\n"
      }
      @logger.debug('message').should == true
      @pipe.string.should =~ /^DEBUG - \d+ - app - message\n$/
    end
  end

  describe "message types" do
    it "should allow message to be specified as a Hash" do
      @logger.debug(text: 'message', context: 'account').should == true
      @pipe.string.should include({ text: 'message', context: 'account' }.inspect)
    end

    it "should invoke inspect method to convert object message to string" do
      message = { text: 'message', context: 'account' }
      class << message
        def inspect
          "#{self[:text]} [#{self[:context]}]"
        end
      end
      @logger.debug(message).should == true
      @pipe.string.should include('message [account]')
    end

    it "should convert exception message to string" do
      message = nil
      begin
        raise ArgumentError, 'message'
      rescue => e
        message = e
      end
      @logger.debug(message).should == true
      @pipe.string.should =~ / message \(ArgumentError\)\nArgumentError: message\n  from /
    end
  end
end
