require 'spec_helper'
require 'stringio'

describe 'Kernel#warn' do
  before do
    @fake_stderr = StringIO.new
  end

  it 'writes single message to $stderr if $VERBOSE is true' do
    old_verbose = $VERBOSE
    $VERBOSE = true

    captured_stderr {
      warn 'this is a warning message'
    }.should == 'this is a warning message'

    $VERBOSE = old_verbose
  end

  it 'writes multiple messages to $stderr if $VERBOSE is true' do
    old_verbose = $VERBOSE
    $VERBOSE = true

    captured_stderr {
      warn 'this is a warning message', 'this is another'
    }.should == "this is a warning message\nthis is another"

    $VERBOSE = old_verbose
  end

  it 'does not write empty message to $stderr if $VERBOSE is true' do
    old_verbose = $VERBOSE
    $VERBOSE = true

    captured_stderr {
      warn
    }.should be_nil

    $VERBOSE = old_verbose
  end

  it 'does write message to $stderr if $VERBOSE is false' do
    old_verbose = $VERBOSE
    $VERBOSE = false

    captured_stderr {
      warn 'this is a warning message'
    }.should == 'this is a warning message'

    $VERBOSE = old_verbose
  end

  it 'does not write message to $stderr if $VERBOSE is nil' do
    old_verbose = $VERBOSE
    $VERBOSE = nil

    captured_stderr {
      warn 'this is a warning message'
    }.should be_nil

    $VERBOSE = old_verbose
  end

  it 'returns a nil value' do
    old_verbose = $VERBOSE
    $VERBOSE = true

    captured_stderr {
      (warn 'this is a warning message').should be_nil
    }

    $VERBOSE = old_verbose
  end

  def captured_stderr
    original_stderr = $stderr
    $stderr = @fake_stderr
    yield
    @fake_stderr.tap(&:rewind).read
  ensure
    $stderr = original_stderr
  end
end
