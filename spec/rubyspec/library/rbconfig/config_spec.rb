require 'rbconfig'

describe 'RbConfig' do
  it 'should define a module RbConfig' do
    Object.const_defined?(:RbConfig).should == true
    RbConfig.class.should be_kind_of(Module)
  end

  it 'should define a hash-like constant CONFIG' do
    RbConfig.const_defined?(:CONFIG).should == true
    RbConfig::CONFIG.respond_to?(:[]).should == true
  end
end

describe 'RbConfig::CONFIG' do
  it 'should contain the key ruby_version set to the RUBY_VERSION' do
    RbConfig::CONFIG['ruby_version'].should == RUBY_VERSION
  end

  it 'should contain the key MAJOR set to the first position in RUBY_VERSION' do
    RbConfig::CONFIG['MAJOR'].should == RUBY_VERSION.split('.')[0]
  end

  it 'should contain the key MAJOR set to the second position in RUBY_VERSION' do
    RbConfig::CONFIG['MINOR'].should == RUBY_VERSION.split('.')[1]
  end

  it 'should contain the key TEENY set to the first position in RUBY_VERSION' do
    RbConfig::CONFIG['TEENY'].should == RUBY_VERSION.split('.')[2]
  end

  it 'should contain the key TEENY set to the first position in RUBY_VERSION' do
    RbConfig::CONFIG['TEENY'].should == RUBY_VERSION.split('.')[2]
  end

  it 'should contain the key RUBY equal to the RUBY_ENGINE' do
    RbConfig::CONFIG['RUBY'].should == RUBY_ENGINE
  end

  it 'should contain the key RUBY_INSTALL_NAME equal to the RUBY_ENGINE' do
    RbConfig::CONFIG['RUBY_INSTALL_NAME'].should == RUBY_ENGINE
  end

  it 'should contain the key RUBY_SO_NAME equal to the RUBY_ENGINE' do
    RbConfig::CONFIG['RUBY_SO_NAME'].should == RUBY_ENGINE
  end
end
