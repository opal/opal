require 'lib/spec_helper'
require 'opal/sprockets/erb'

describe Opal::ERB::Processor do
  let(:pathname) { Pathname("/Code/app/mylib/opal/foo.#{ext}") }
  let(:environment) { double('environment',
    cache: nil,
    :[] => nil,
    resolve: pathname.expand_path.to_s,
  ) }
  let(:_context) { double('context',
    logical_path: "foo.#{ext}",
    environment: environment,
    pathname: pathname,
    is_a?: true,
  ) }
  let(:required_assets) { [] }
  let(:template) { described_class.new { |t| %Q{<a href="<%= url %>"><%= name %></a>} } }
  before { _context.stub(:require_asset) {|asset| required_assets << asset } }

  let(:ext) { 'opalerb' }

  it "is registered for '.opalerb' files" do
    expect(Tilt["test.#{ext}"]).to eq(described_class)
  end

  it 'renders the template' do
    expect(template.render(_context)).to include('"<a href=\""')
  end

  it 'implicitly requires "erb"' do
    template.render(_context)
    expect(required_assets).to eq(['erb'])
  end
end
