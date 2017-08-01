require 'lib/spec_helper'

describe 'Opal.use_gem' do
  # Coverage probably should be improved

  it 'adds require_paths of a gem to Opal paths' do
    begin
      Opal.use_gem 'rake'
    rescue Opal::GemNotFound => e
      raise(e) unless e.gem_name == 'rake'
      skip %(Will fail if GEM_HOME has "rake" in the path, that's ok)
    end

    added_rake_paths = Opal.paths.grep(/rake/)
    expect(added_rake_paths.size).to eq(1)
    expect(added_rake_paths.first).to match(%r{/rake-[\d\.]+/lib$})
  end
end
