require 'opal/version'
describe 'Opal::VERSION' do
  let(:version) { Opal::VERSION }
  it 'is reported as the RUBY_ENGINE_VERSION internally' do
    expect(Opal::Builder.new.build('corelib/variables').to_s).to match(/RUBY_ENGINE_VERSION', #{version.inspect}/)
  end
end
