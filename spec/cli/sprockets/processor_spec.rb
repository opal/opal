require 'cli/spec_helper'
require 'opal/sprockets/processor'

describe Opal::Processor do
  let(:pathname) { Pathname("/Code/app/mylib/opal/foo.#{ext}") }
  let(:_context) { double('_context', :logical_path => "foo.#{ext}", :pathname => pathname) }
  let(:env) { double('env') }

  before do
    env.stub(:resolve) { pathname.expand_path.to_s }
    env.stub(:[])
    _context.stub(:environment) { env }
  end

  %w[rb js.rb opal js.opal].each do |ext|
    let(:ext) { ext }

    describe %Q{with extension ".#{ext}"} do
      it "is registered for '.#{ext}' files" do
        expect(Tilt["test.#{ext}"]).to eq(described_class)
      end

      it "compiles and evaluates the template on #render" do
        template = described_class.new { |t| "puts 'Hello, World!'\n" }
        expect(template.render(_context)).to include('"Hello, World!"')
      end

      it "can be rendered more than once" do
        template = described_class.new(_context) { |t| "puts 'Hello, World!'\n" }
        3.times { expect(template.render(_context)).to include('"Hello, World!"') }
      end
    end
  end

end

describe Opal::Processor::SprocketsPathReader do
  subject(:path_reader) { described_class.new(env, context) }

  let(:env) { Opal::Environment.new }

  # TODO: use stubs and expect calls on #depend_on and #depend_on_asset
  let(:context) { env.context_class.new(env, 'foo', Pathname('bar/baz/foo.js')) }

  let(:logical_path) { 'sprockets_file' }
  let(:fixtures_dir) { File.expand_path('../../fixtures/', __FILE__) }
  let(:full_path) { File.join(fixtures_dir, logical_path+'.js.rb') }

  before { env.append_path fixtures_dir }

  it 'can read stuff from sprockets env' do
    expect(path_reader.read(logical_path)).to eq(File.read(full_path))
  end
end
