class DefineMethodByProcScope
  in_scope = true
  method_proc = proc { in_scope }

  define_singleton_method(:proc_test, &method_proc)
end

describe "Kernel#define_singleton_method" do
  it "defines a new singleton method for objects" do
    s = Object.new
    s.define_singleton_method(:test) { "world!" }
    expect(s.test).to eq("world!")
    expect {
      Object.new.test
    }.to raise_error(NoMethodError)
  end

  it "maintains the Proc's scope" do
    expect(DefineMethodByProcScope.proc_test).to eq(true)
  end
end