describe 'Kernel.require_tree' do
  before { ScratchPad.record [] }
  after  { ScratchPad.clear }

  it 'loads all the files in a directory' do
    # require_tree '../fixtures/require_tree_files'
    require_tree '.'
    ScratchPad.recorded.should == 'asdf'
  end
end
