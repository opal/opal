require 'lib/spec_helper'
require 'opal/cli_runners'
require 'rack/test'

RSpec.describe Opal::CliRunners::Server do
  include Rack::Test::Methods

  def app
    @app
  end

  it 'starts a server for the given code' do
    expect(Rack::Server).to receive(:start) do |options|
      @app = options[:app]
      expect(options[:Port]).to eq(1234)
    end

    builder = Opal::Builder.new
    builder.build_str("puts 123", "app.rb")
    described_class.call(builder: builder, options: {port: 1234})

    get '/cli_runner.js'
    expect(last_response.body).to include("[Opal.s.$puts](123)")
  end
end
