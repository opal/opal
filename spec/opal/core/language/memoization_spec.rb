describe "memoization" do
  it "memoizes a value with complex internal logic" do
    klass = Class.new do
      def memoized_value(dependency: nil)
        @memoized_value ||= begin
                              return nil if dependency.nil?

                              dependency.call
                            end
      end
    end

    expect(klass.new.memoized_value(dependency: proc { :value })).to eq :value
    expect(klass.new.memoized_value).to eq nil
  end
end
