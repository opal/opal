describe 'Regexp interpolation' do
  it 'can interpolate other regexps' do
    a = /a/

    /#{a}/.should =~ 'aaa'
    /a+/.should =~ 'aaa'
    /#{a}+/.should =~ 'aaa'
    /aa/.should =~ 'aaa'
    /#{a}a/.should =~ 'aaa'
  end

  it 'can interpolate objects' do
    a = Object.new
    def a.to_s; 'a'; end

    /#{a}/.should =~ 'aaa'
    /a+/.should =~ 'aaa'
    /#{a}+/.should =~ 'aaa'
    /aa/.should =~ 'aaa'
    /#{a}a/.should =~ 'aaa'
  end

  it 'can interpolate strings' do
    a = 'a'

    /#{a}/.should =~ 'aaa'
    /a+/.should =~ 'aaa'
    /#{a}+/.should =~ 'aaa'
    /aa/.should =~ 'aaa'
    /#{a}a/.should =~ 'aaa'
  end

  it 'can interpolate string literals' do
    /#{'a'}/.should =~ 'aaa'
    /a+/.should =~ 'aaa'
    /#{'a'}+/.should =~ 'aaa'
    /aa/.should =~ 'aaa'
    /#{'a'}a/.should =~ 'aaa'
  end
end
