describe "Keyword arguments" do
  it 'works with keys that are reserved words in JS' do
    o = Object.new
    def o.foo(default:)
      default
    end
    o.foo(default: :bar).should == :bar
  end
end
