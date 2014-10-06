require 'lib/spec_helper'
require 'rack/test'

describe Opal::Server do
  include Rack::Test::Methods

  def app
    described_class.new { |s|
      s.main = 'opal'
      s.debug = false
      s.sprockets.logger = Logger.new('/dev/null')
    }
  end

  it 'serves assets from /assets' do
    get '/assets/opal.js'
    expect(last_response).to be_ok
  end

end
