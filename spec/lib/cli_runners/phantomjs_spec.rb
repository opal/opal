require 'lib/spec_helper'
require 'opal/cli_runners/phantomjs'
require 'stringio'

describe Opal::CliRunners::Phantomjs do
  # FIXME: Unfotunately there are some issues on jruby and 1.9.3, probably
  #        related to IO.pipe and process spawning in general.
  before { pending if RUBY_PLATFORM == 'java' or RUBY_VERSION == '1.9.3' }

  it 'accepts arguments' do
    expect(output_of(%{
      var ARGV = JSON.parse(callPhantom(['argv']));
      callPhantom(['stdout', JSON.stringify(ARGV)]);
      callPhantom(['exit', 0]);
    }, ['foo', 'bar'])).to eq('["foo","bar"]')
  end

  it 'sets env' do
    ENV['FOO'] = 'BAR'
    expect(output_of(%{
      var ENV = JSON.parse(callPhantom(['env']));
      callPhantom(['stdout', JSON.stringify(ENV)]);
      callPhantom(['exit', 0]);
    }, [])).to include(%{"FOO":"BAR"})
  end


  private

  def output_of(*args)
    read, write = IO.pipe
    runner = described_class.new(output: write)

    runner.run(*args)
    write.close

    return read.read
  end
end
