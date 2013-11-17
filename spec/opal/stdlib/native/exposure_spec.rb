require 'native'

describe 'Native exposure' do
  describe Class do
    describe '#native_alias' do
      it 'exposes a method to javascript' do
        c = Class.new do
          def ruby_method
            :ruby
          end

          native_alias :rubyMethod, :ruby_method
        end

        `#{c.new}.rubyMethod()`.should == :ruby
      end
    end

    describe '#native_class' do
      it 'exposes a Class on the JS global object' do
        c = Class.new do
          def self.name
            'Pippo'
          end

          native_class
        end

        `Pippo`.should == c
      end
    end
  end
end
