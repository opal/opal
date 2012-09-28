require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe 'Class definition returning its last value' do
  it 'with a number' do
    value = class Klass1
      def hello; 'hello again'; end
      123
    end

    value.should == 123
  end

  it 'with a string' do
    value = class Klass2
      def hello; 'hello again'; end
      'hi!'
    end

    value.should == 'hi!'
  end

  it 'with a method' do
    value = class Klass2
      def hello; 'hello again'; end
    end

    value.should == nil
  end

  it 'with a class method' do
    value = class Klass3
      def self.hello; 'hello again'; end
    end

    value.should == nil
  end

  it 'with nothing' do
    value = class Klass4; end
    value.should == nil
  end

  it 'with attr_*' do
    value = class Klass5
      attr_accessor :my_attribute
    end
    value.should == nil
  end

  it 'with a nested class/module' do
    value = class Klass6
      class Klass
        123
      end
    end
    value.should == 123
  end

  it 'with a ' do
    value = class Klass7
      class Klass
        123
      end
    end
    value.should == 123
  end
end
