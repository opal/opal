require 'lib/spec_helper'
require 'opal/repl'

RSpec.describe Opal::REPL do
  describe '#eval_ruby' do
    let(:input_and_output) { {
      'puts 5'          => "5\n=> nil\n",
      'a = 1'           => "=> 1\n",
      'a += 1'          => "=> 2\n",
      'a + 3'           => "=> 5\n",
      'puts a + 3'      => "5\n=> nil\n",
      '"#{a} + 3"'      => "=> \"2 + 3\"\n",
      'puts "#{a} + 3"' => "2 + 3\n=> nil\n",
    } }

    subject(:repl) { described_class.new }

    it 'evaluates user inputs' do
      repl.colorize = false

      repl.load_opal

      input_and_output.each do |input, output|
        expect { repl.eval_ruby(input) }.to output(output).to_stdout
      end

      repl.finish
    end
  end
end
