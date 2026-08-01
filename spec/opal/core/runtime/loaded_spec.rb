# backtick_javascript: true

describe 'Opal.loaded' do
  before do
    %w[foo bar baz].each do |module_name|
      `delete Opal.require_table[#{module_name}]`
      `Opal.loaded_features.splice(Opal.loaded_features.indexOf(#{module_name}))`
    end
  end

  it 'it works with a single path' do
    `Opal.loaded('bar')`
    `(Opal.require_table.bar === true)`.should == true
  end
end
