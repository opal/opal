require File.expand_path('../spec_helper', __FILE__)
require 'opal/cli'
require 'stringio'

describe Opal::CLI do
  let(:output) { StringIO.new }

  context 'with a file' do
    let(:file) { File.expand_path('../fixtures/opal_file.rb', __FILE__) }
    subject(:cli) { described_class.new(file, :output => output) }

    it 'runs the file' do
      cli.run
      output.rewind
      expect(output.read).to eq("hi from opal!\n")
    end
  end
end
