describe 'Kernel.require_tree' do
  it 'loads all the files in a directory' do
    $ScratchPad = []
    require_tree '../fixtures/require_tree_files'
    $ScratchPad.should == ['file 1', 'file 2', 'file 3', 'file 4', 'file 5']
  end
end
