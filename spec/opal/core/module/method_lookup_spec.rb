require File.expand_path('../fixtures/classes', __FILE__)

describe 'Method lookup for instances of Module' do
  it 'takes own method, not the one defined on the Class' do
    Module.new.test_method_overlapping_module_method.should == :module
  end
end

describe 'Method lookup for instances of Class' do
  it 'takes own method, not the one defined on the Module' do
    Class.new.test_method_overlapping_module_method.should == :class
  end
end
