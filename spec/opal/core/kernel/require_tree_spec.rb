describe 'Kernel.require_tree' do
  it 'loads all the files in a directory' do
    $ScratchPad = []
    require_tree '../fixtures/require_tree_files'

    $ScratchPad.sort.should == ['file 1', 'file 2', 'file 3', 'file 4', 'file 5',
                                'nested 1', 'nested 2', 'other 1']
  end

  it 'can be used with "."' do
    $ScratchPad = []
    require_relative '../fixtures/require_tree_with_dot/index'

    $ScratchPad[0].should == 'indexpre'
    $ScratchPad[1...-1].sort.should == ['file 1', 'file 2', 'file 3']
    $ScratchPad[-1].should == 'indexpost'
  end
end
