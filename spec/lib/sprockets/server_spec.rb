require 'lib/spec_helper'
require 'sourcemap'
require 'rack/test'

describe Opal::Server do
  include Rack::Test::Methods

  def app
    described_class.new { |s|
      s.main = 'opal'
      s.debug = false
      s.append_path "#{__dir__}/../fixtures"
      s.sprockets.logger = Logger.new('/dev/null')
    }
  end

  it 'serves assets from /assets' do
    get '/assets/opal.js'
    expect(last_response).to be_ok
  end

  describe 'source maps' do
    it 'serves map on a top level file' do
      get '/assets/source_map.js'
      expect(last_response).to be_ok

      get '/assets/source_map.map'
      expect(last_response).to be_ok
    end

    it 'serves map on a subfolder file' do
      js_path = '/assets/source_map/subfolder/other_file.js'
      map_path = '/assets/source_map/subfolder/other_file.map'

      get js_path

      expect(last_response).to be_ok
      received_map_path = extract_linked_map(last_response.body)
      expect(File.expand_path(received_map_path, js_path+'/..')).to eq(map_path)

      get '/assets/source_map/subfolder/other_file.map'
      expect(last_response).to be_ok
    end

    it 'serves map on a subfolder file' do
      js_path = '/assets/source_map/subfolder/other_file.js'
      map_path = '/assets/source_map/subfolder/other_file.map'

      get js_path

      expect(last_response).to be_ok
      received_map_path = extract_linked_map(last_response.body)
      expect(File.expand_path(received_map_path, js_path+'/..')).to eq(map_path)


      get '/assets/source_map/subfolder/other_file.map'
      expect(last_response).to be_ok
      map = ::SourceMap::Map.from_json(last_response.body)
      expect(map.sources).to include('/assets/source_map/subfolder/other_file.rb')
    end
  end

  def extract_linked_map(body)
    source_map_comment_regexp = %r{//# sourceMappingURL=(.*)$}
    expect(body).to match(source_map_comment_regexp)
    body.scan(source_map_comment_regexp).first.first
  end
end
