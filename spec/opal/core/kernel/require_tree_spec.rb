describe 'Kernel.require_tree' do
  it 'loads all the files in a directory' do
    $ScratchPad = []
    require_tree '../fixtures/require_tree_files'

    $ScratchPad.sort.should == ['file 1.rb', 'file 2.rb', 'file 3.rb', 'file 4.rb', 'file 5.rb',
                                'nested 1.rb', 'nested 2.rb', 'other 1.rb']
  end

  it 'can be used with "."' do
    $ScratchPad = []
    require_relative '../fixtures/require_tree_with_dot/index'

    $ScratchPad[0].should == 'index.rb-pre'
    $ScratchPad[1...-1].sort.should == ['file 1.rb', 'file 2.rb', 'file 3.rb']
    $ScratchPad[-1].should == 'index.rb-post'
  end
end
