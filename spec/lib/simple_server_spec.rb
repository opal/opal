require 'lib/spec_helper'
require 'rack/test'

RSpec.describe Opal::SimpleServer do
  include Rack::Test::Methods

  attr_accessor :app

  # Ensure that each `get` call leads to a new rack session.
  def get(path)
    rack_test_session(nil).get(path)
  end

  shared_examples "simple server" do
    before do
      Opal.append_path "#{__dir__}/fixtures"
      self.app = described_class.new(main: 'console')
    end

    it 'serves opal assets' do
      response = get "/assets/console.#{ext}#{sub_console}"
      expect(response.body).to include('self["native"].trace()')
    end

    it 'serves index for all non opal paths' do
      %w[/ /foo /foo/bar/baz].each do |path|
        response = get path
        expect(response.body).to include('<html>')
        expect(response.body).to include('<script')
        expect(response.body).to include("src=\"/assets/console.#{ext}#{index}\"")
        expect(response.body).to include('type="module"') if esm?
        expect(response.body).not_to include('type="module"') unless esm?
        expect(response.headers['Content-type']).to eq('text/html')
      end
    end

    it 'serves the source map as data uri' do
      response = get "/assets/console.#{ext}#{sub_console}"
      if directory?
        expect(response.body).to include("\n//# sourceMappingURL=./console.map")
        source_map = get("/assets/console.mjs/opal/#{Opal::VERSION_MAJOR_MINOR}/console.map").body
        expect(source_map).to include("../../opal/src")
        expect(source_map).to include("console.rb")
      else
        expect(response.body).to include("\n//# sourceMappingURL=data:application/json;base64,")
        base64_map = response.body.split("\n//# sourceMappingURL=data:application/json;base64,").last
        expect(Base64.decode64(base64_map)).to eq(Opal::Builder.build('console').source_map.to_json)
      end
    end

    it 'takes a :prefix option to set the assets prefix' do
      self.app = described_class.new(main: 'opal', prefix: 'foo')
      expect(get("/foo/console.#{ext}#{sub_console}").body).to include('self["native"].trace()')
      self.app = described_class.new(main: 'opal', prefix: '/foo')
      expect(get("/foo/console.#{ext}#{sub_console}").body).to include('self["native"].trace()')
    end

    it 'takes a :main option to set the main asset' do
      self.app = described_class.new(main: 'opal_file')
      expect(get('/').body).to include("src=\"/assets/opal_file.#{ext}")
    end

    it 'respects config set in Opal::Config' do
      Opal::Config.arity_check_enabled = false
      self.app = described_class.new(main: 'console')
      expect(get("/assets/console.#{ext}#{sub_console}").body).not_to include('$$parameters: []')

      Opal::Config.arity_check_enabled = true
      self.app = described_class.new(main: 'console')
      expect(get("/assets/console.#{ext}#{sub_console}").body).to include('$$parameters: []')
    end

    it 'supports a custom Builder' do
      builder = Opal::Builder.new
      builder.build('console')
      builder.build_str('1312312313', '(test)')
      self.app = described_class.new(main: 'console', builder: builder)
      expect(get("/assets/console.#{ext}#{sub_console}").body).to include('self["native"].trace()')
      expect(get("/assets/console.#{ext}#{sub_test}").body).to include('1312312313')
    end

    it 'supports a custom Builder given as a proc' do
      pr = ->() do
        builder = Opal::Builder.new
        builder.build('console')
        builder.build_str('1312312313', '(test)')
        builder
      end
      self.app = described_class.new(main: 'console', builder: pr)
      expect(get("/assets/console.#{ext}#{sub_console}").body).to include('self["native"].trace()')
      expect(get("/assets/console.#{ext}#{sub_test}").body).to include('1312312313')
    end
  end

  context "in non-directory, non-ESM mode" do
    before(:each) do
      Opal::Config.esm = false
      Opal::Config.directory = false
    end

    let(:ext) { "js" }
    let(:index) { "" }
    let(:sub_console) { "" }
    let(:sub_test) { "" }
    let(:directory?) { false }
    let(:esm?) { false }

    include_examples "simple server"
  end

  context "in directory, ESM mode" do
    before(:each) do
      Opal::Config.esm = true
      Opal::Config.directory = true
    end

    let(:ext) { "mjs" }
    let(:index) { "/index.mjs" }
    let(:sub_console) { "/opal/#{Opal::VERSION_MAJOR_MINOR}/console.mjs" }
    let(:sub_test) { "/opal/#{Opal::VERSION_MAJOR_MINOR}/(test).mjs" }
    let(:directory?) { true }
    let(:esm?) { true }

    include_examples "simple server"
  end
end
