# backtick_javascript: true

describe 'Opal.block_length' do
  # A JS minifier is free to drop trailing unused parameters, which shrinks the
  # function's `length`. `$$arity` survives that, so it is used as a lower bound.
  it 'falls back to $$arity when the function length under-reports' do
    block = proc { |x, *| x }
    minified = `function(x) { return #{block}.apply(null, arguments) }`
    `#{minified}.$$arity = #{block}.$$arity`

    `Opal.block_length(#{minified})`.should == 2
  end

  it 'prefers the function length when it exceeds the absolute arity' do
    # `{ |a=1, b=2| }` has an arity of -1 but declares two parameters.
    `Opal.block_length(#{proc { |_a = 1, _b = 2| }})`.should == 2
  end

  it 'reports a single parameter for a lone splat' do
    `Opal.block_length(#{proc { |*a| a }})`.should == 1
  end

  it 'auto-splats a yielded array for a block with a trailing bare splat' do
    [[1, 2], [3, 4]].collect { |x, *| x }.should == [1, 3]
  end
end
