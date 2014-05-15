require 'spec_helper'

module OpalMethodSpec
  class C
    def foo; :C; end
  end

  module M
    def foo; :M; end
    def bar; :M; end
  end

  module N
    def bar; :N; end
  end

  class C
    include M
    include N
  end
end

describe "Including modules in a class with methods already defined in class" do
  it "should always call the method defined in a class first" do
    expect(OpalMethodSpec::C.new.foo).to eq(:C)
  end

  it "should call the method from the last module included unless class defines method" do
    expect(OpalMethodSpec::C.new.bar).to eq(:N)
  end
end
