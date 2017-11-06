require 'lib/spec_helper'
require 'opal/deprecations'

RSpec.describe Opal::Deprecations do
  subject { Object.new.extend described_class }

  it 'defaults to warn' do
    expect(subject).to receive(:warn)
    subject.deprecation "there's a new api!"
  end

  it 'can be set to raise' do
    subject.raise_on_deprecation = true
    expect(subject).to receive(:raise)
    subject.deprecation "there's a new api!"
  end
end
