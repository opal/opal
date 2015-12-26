require 'lib/spec_helper'

describe 'Opal.use_gem' do
  it 'adds require_paths of a gem to Opal paths' do
    begin
      Opal.use_gem 'sprockets'
    rescue 
      skip %(Will fail if GEM_HOME has "sprockets" in the path, that's ok)
    end

    added_sprockets_paths = Opal.paths.grep /sprockets/
    expect(added_sprockets_paths.size).to eq(1)
    expect(added_sprockets_paths.first).to match(%r{/sprockets-[\d\.]+/lib$})
  end
end
