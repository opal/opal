module KernelSpecs
  class Foo
    def bar
      'done'
    end

    def self.baz
      'class done'
    end
  end
end

describe "Kernel#method" do
  it "returns a method object for a valid method" do
    m = KernelSpecs::Foo.new.method(:bar)
    expect(m).to be_kind_of(Method)
    expect(m.call).to eq('done')
  end

  it "returns a method object for a valid singleton method" do
    m = KernelSpecs::Foo.method(:baz)
    expect(m).to be_kind_of Method
    expect(m.call).to eq('class done')
  end

  it "raises a NameError for an invalid method name" do
    expect {
      KernelSpecs::Foo.new.method(:invalid_and_silly_method_name)
    }.to raise_error(NameError)
  end
end