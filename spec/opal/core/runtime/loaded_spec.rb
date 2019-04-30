describe 'Opal.loaded' do
  before do
    %w[foo bar baz].each do |module_name|
      `delete Opal.require_table[#{module_name}]`
      `Opal.loaded_features.splice(Opal.loaded_features.indexOf(#{module_name}))`
    end
  end

  it 'it works with multiple paths' do
    `Opal.loaded(['bar'])`
    `(Opal.require_table.foo == null)`.should == true
    `(Opal.require_table.bar === true)`.should == true
    `(Opal.require_table.baz == null)`.should == true

    `Opal.loaded(['foo', 'bar', 'baz'])`
    `(Opal.require_table.foo === true)`.should == true
    `(Opal.require_table.bar === true)`.should == true
    `(Opal.require_table.baz === true)`.should == true
  end
end
