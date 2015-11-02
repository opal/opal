require 'lib/spec_helper'

describe 'Opal.use_gem' do
  it 'adds require_paths of a gem to Opal paths' do
    Opal.use_gem 'sprockets'
    # Will fail if GEM_HOME has "sprockets" in the path, that's ok.
    added_sprockets_paths = Opal.paths.grep /sprockets/
    expect(added_sprockets_paths.size).to eq(1)
    expect(added_sprockets_paths.first).to match(%r{/sprockets-[\d\.]+/lib$})
  end
end
