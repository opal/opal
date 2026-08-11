# backtick_javascript: true

describe 'Opal.load' do
  before do
    @path = 'opal/spec/fake_loaded_module'
    `Opal.global.OPAL_SPEC_LOAD_RUNS = 0`
    `Opal.modules[#{@path}] = function(Opal) { Opal.global.OPAL_SPEC_LOAD_RUNS++ }`
  end

  after do
    `delete Opal.modules[#{@path}]`
    `delete Opal.require_table[#{@path}]`
    `delete Opal.global.OPAL_SPEC_LOAD_RUNS`
    index = `Opal.loaded_features.indexOf(#{@path})`
    `Opal.loaded_features.splice(#{index}, 1)` if index >= 0
  end

  def runs
    `Opal.global.OPAL_SPEC_LOAD_RUNS`
  end

  it 'runs the module every time it is called' do
    `Opal.load(#{@path})`
    runs.should == 1

    `Opal.load(#{@path})`
    runs.should == 2
  end

  it 'does not mark the file as required' do
    `Opal.load(#{@path})`
    `(Opal.require_table[#{@path}] == null)`.should == true
  end

  it 'leaves a later Opal.require free to run the module again' do
    `Opal.load(#{@path})`
    `Opal.require(#{@path})`
    runs.should == 2
  end

  it 'marks the file as required once Opal.require has run it' do
    `Opal.require(#{@path})`
    `(Opal.require_table[#{@path}] === true)`.should == true

    `Opal.require(#{@path})`
    runs.should == 1
  end
end
