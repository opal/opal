require 'lib/spec_helper'
require 'sourcemap'
require 'rack/test'
require 'pry'

describe Opal::Server do
  include Rack::Test::Methods

  def app
    described_class.new { |s|
      s.main = 'opal'
      s.debug = false
      s.append_path File.expand_path('../../fixtures', __FILE__)
      s.sprockets.logger = Logger.new(nil)
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
      expect(expand_path(received_map_path, js_path+'/..')).to eq(map_path)

      get '/assets/source_map/subfolder/other_file.map'
      expect(last_response).to be_ok
    end

    it 'serves map on a subfolder file' do
      js_path = '/assets/source_map/subfolder/other_file.js'
      map_path = '/assets/source_map/subfolder/other_file.map'

      get js_path

      expect(last_response).to be_ok
      received_map_path = extract_linked_map(last_response.body)
      expect(expand_path(received_map_path, js_path+'/..')).to eq(map_path)


      get '/assets/source_map/subfolder/other_file.map'
      expect(last_response).to be_ok
      map = ::SourceMap::Map.from_json(last_response.body)
      expect(map.sources).to include('/assets/source_map/subfolder/other_file.rb')
    end
    
    it 'serves the original source files ending with .js.rb' do
      source_path = '/assets/source_map/source_files/a_file_ending_in_rb.rb'

      get source_path
      
      expect(last_response).to be_ok
      expect(last_response.body).to start_with("#a_file_ending_in_rb")
    end 

    it 'serves the original source files ending with .js.opal' do
      source_path = '/assets/source_map/source_files/a_file_ending_in_opal.rb'
      
      get source_path
      
      expect(last_response).to be_ok
      expect(last_response.body).to start_with("#a_file_ending_in_opal")
    end     
    
      
  end

  def extract_linked_map(body)
    source_map_comment_regexp = %r{//# sourceMappingURL=(.*)$}
    expect(body).to match(source_map_comment_regexp)
    body.scan(source_map_comment_regexp).first.first
  end

  def expand_path(file_name, dir_string)
    path = File.expand_path(file_name, dir_string)
    # Remove Windows letter and colon (eg. C:) from path
    path = path[2..-1] if !(RUBY_PLATFORM =~ /mswin|mingw/).nil?
    path
  end
end
