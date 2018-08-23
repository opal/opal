require 'lib/spec_helper'
require 'rack/test'

RSpec.describe Opal::SimpleServer do
  include Rack::Test::Methods

  attr_accessor :app

  before do
    Opal.append_path "#{__dir__}/fixtures"
    self.app = described_class.new(main: 'console')
  end

  it 'serves opal assets' do
    response = get '/assets/console.js'
    expect(response.body).to start_with(Opal::Builder.build('console').to_s)
  end

  it 'serves index for all non opal paths' do
    %w[/ /foo /foo/bar/baz].each do |path|
      response = get path
      expect(response.body).to include('<html>')
      expect(response.body).to include('<script')
      expect(response.body).to include('src="/assets/console.js')
      expect(response.headers['Content-type']).to eq('text/html')
    end
  end

  it 'serves the source map as data uri' do
    response = get '/assets/console.js'
    expect(response.body).to include("\n//# sourceMappingURL=data:application/json;base64,")
    base64_map = response.body.split("\n//# sourceMappingURL=data:application/json;base64,").last
    expect(Base64.decode64(base64_map)).to eq(Opal::Builder.build('console').source_map.to_json)
  end

  it 'takes a :prefix option to set the assets prefix' do
    self.app = described_class.new(main: 'opal', prefix: 'foo')
    expect(get('/foo/console.js').body).to start_with(Opal::Builder.build('console').to_s)
    self.app = described_class.new(main: 'opal', prefix: '/foo')
    expect(get('/foo/console.js').body).to start_with(Opal::Builder.build('console').to_s)
  end

  it 'takes a :main option to set the main asset' do
    self.app = described_class.new(main: 'foo')
    expect(get('/').body).to include('src="/assets/foo.js')
  end

  it 'respects config set in Opal::Config' do
    Opal::Config.arity_check_enabled = false
    expect(get('/assets/console.js').body).not_to include('TMP_Console_clear_1.$$parameters = []')

    Opal::Config.arity_check_enabled = true
    self.app = described_class.new(main: 'console')
    expect(get('/assets/console.js').body).to include('TMP_Console_clear_1.$$parameters = []')
  end
end
